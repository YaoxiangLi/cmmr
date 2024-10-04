#' Encapsulation of CEU Mass Mediator batch search API
#'
#' \code{batch_search} returns the dataframe of all the database search results.
#'   using the following code to install the dependencies:
#'   install.packages(c("httr", "progress", "RJSONIO"))
#'
#' @param cmm_url 'https://ceumass.eps.uspceu.es/api/v3/batch' or your local API Endpoint
#' @param metabolites_type "all-except-peptides", "only-lipids", "all-including-peptides"
#' @param databases "all", "all-except-mine", "HMDB", "LipidMaps", "Metlin", "Kegg", "in-house", "mine"
#' @param masses_mode "neutral", "mz"
#' @param ion_mode "positive", "negative"
#' @param adducts for positive mode [M+H, M+2H, M+Na, M+K,M+NH4, M+H-H2O]
#'
#' @param tolerance double (Range: [0..100])
#' @param tolerance_mode "ppm", "mDa"
#' @param unique_mz An array of unique m/zs
#'
#' @return dataframe for search results
#' @examples
#'
# df_pos <- batch_search('https://ceumass.eps.uspceu.es/api/v3/batch',
#                        'all-except-peptides',
#                        '["all-except-mine"]',
#                        'mz',
#                        'positive',
#                        '["M+H","M+Na"]',
#                        10,
#                        'ppm',
#                        c(670.4623, 1125.2555, 602.6180))
#'
# df_neg <- batch_search('https://ceumass.eps.uspceu.es/api/v3/batch',
#                        'all-except-peptides',
#                        '["all-except-mine"]',
#                        'mz',
#                        'negative',
#                        '["M-H","M+Cl"]',
#                        10,
#                        'ppm',
#                        c(670.4623, 1125.2555, 602.6180))
#'
#' \dontrun{
#' batch_search(c(670.4623, 1125.2555, 602.6180))
#' }
#' @export
#'
batch_search <- function(cmm_url = "https://ceumass.eps.uspceu.es/api/v3/batch",
                         metabolites_type = "all-except-peptides",
                         databases = '["all-except-mine"]',
                         masses_mode = "mz",
                         ion_mode = "positive",
                         adducts = '["M+H","M+Na"]',
                         tolerance = 10,
                         tolerance_mode = "ppm",
                         unique_mz) {
  columns_to_save <- c(
    "identifier", "EM", "name", "formula", "adduct",
    "molecular_weight", "error_ppm",
    "ionizationScore", "finalScore",
    "kegg_compound", "kegg_uri",
    "hmdb_compound", "hmdb_uri",
    "lipidmaps_compound", "lipidmaps_uri",
    "metlin_compound", "metlin_uri",
    "pubchem_compound", "pubchem_uri"
  )

  columns_to_name <- c(
    "identifier", "experimental_mass", "name", "formula", "adduct",
    "molecular_weight", "error_ppm",
    "ionization_score", "final_score",
    "Kegg", "Kegg_URI",
    "HMDB", "HMDB_URI",
    "LipidMaps", "LipidMaps_URI",
    "Metlin", "Metlin_URI",
    "PubChem", "PubChem_URI"
  )

  body <- create_batch_body(metabolites_type, databases, masses_mode, ion_mode, adducts, tolerance, tolerance_mode, unique_mz)

  if (cmm_url == "https://ceumass.eps.uspceu.es/api/v3/batch") {
    cat("Using the CEU Mass Mediator server API.\n")
  } else {
    cat("Using the local/3rd party server API.\n")
    cat(paste0(cmm_url, "\n"))
  }

  r <- httr::POST(url = cmm_url, body = body, httr::content_type("application/json"))

  if (r$status_code == 200) {
    cat(paste0("Status: ", r$status_code, ", Success!\n"))
    cat(paste0("Date: ", r$date, "\n"))
    json_file <- RJSONIO::fromJSON(httr::content(r, "text", encoding = "UTF-8"))$results
    if (length(json_file) == 0) {
      cat("No compounds found in the database search.\n")
      return("No compounds found in the database search.")
    }

    pb <- progress::progress_bar$new(
      format = "  Parsing database search results [:bar] :percent in :elapsed",
      total  = length(json_file) - 1,
      clear  = FALSE,
      width  = 100
    )

    df <- json_file[[1]]
    df <- as.data.frame(df[names(df) %in% columns_to_save])
    if (length(json_file) > 1) {
      for (i in 2:length(json_file)) {
        pb$tick()
        dfi <- json_file[[i]]
        dfi <- as.data.frame(dfi[names(dfi) %in% columns_to_save])
        df <- rbind(df, dfi)
      }
    }


    df <- df[, columns_to_save]
    colnames(df) <- columns_to_name

    # if (ion_mode == "positive"){
    #   utils::write.table(df, sub(".csv", "_pos_db_search.csv", unique_mz_file),
    #                      sep = ",", row.names = FALSE)
    #   print("Please find the database search result file in the following path:")
    #   print(sub(".csv", "_pos_db_search.csv", unique_mz_file))
    # } else if (ion_mode == "negative"){
    #   utils::write.table(df, sub(".csv", "_neg_db_search.csv", unique_mz_file),
    #                      sep = ",", row.names = FALSE)
    #   print("Please find the database search result file in the following path:")
    #   print(sub(".csv", "_neg_db_search.csv", unique_mz_file))
    # }
    return(df)
  } else {
    cat(paste0("Status: ", r$status_code, ", Fail to connect the API service!\n"))
    cat(paste0("Date: ", r$date, "\n"))
  }
}
