#' Encapsulation of CEU Mass Mediator batch search API
#'
#' \code{batch_search} returns a dataframe with the results from the database search.
#' Use the following code to install required dependencies:
#' install.packages(c("httr", "progress", "RJSONIO", "cli"))
#'
#' @param cmm_url A URL string for the CEU Mass Mediator or a local API endpoint.
#' @param metabolites_type Search metabolites type: "all-except-peptides", "only-lipids", or "all-including-peptides".
#' @param databases A JSON array of databases to search: e.g., "all", "HMDB", "LipidMaps", etc.
#' @param masses_mode Masses mode: "neutral" or "mz".
#' @param ion_mode Ionization mode: "positive" or "negative".
#' @param adducts A JSON array of adducts to include in the search, e.g., '["M+H", "M+Na"]'.
#' @param tolerance A numeric tolerance value (range: 0-100).
#' @param tolerance_mode Tolerance mode: "ppm" or "mDa".
#' @param unique_mz A numeric vector of unique m/z values for the search.
#'
#' @return A dataframe containing search results.
#' @examples
#' \dontrun{
#' df_pos <- batch_search('https://ceumass.eps.uspceu.es/api/v3/batch',
#'                        'all-except-peptides',
#'                        '["all-except-mine"]',
#'                        'mz',
#'                        'positive',
#'                        '["M+H","M+Na"]',
#'                        10,
#'                        'ppm',
#'                        c(670.4623, 1125.2555, 602.6180))
#' }
#' @export
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
    "molecular_weight", "error_ppm", "ionizationScore", "finalScore",
    "kegg_compound", "kegg_uri", "hmdb_compound", "hmdb_uri",
    "lipidmaps_compound", "lipidmaps_uri", "metlin_compound", "metlin_uri",
    "pubchem_compound", "pubchem_uri"
  )

  columns_to_name <- c(
    "identifier", "experimental_mass", "name", "formula", "adduct",
    "molecular_weight", "error_ppm", "ionization_score", "final_score",
    "Kegg", "Kegg_URI", "HMDB", "HMDB_URI", "LipidMaps", "LipidMaps_URI",
    "Metlin", "Metlin_URI", "PubChem", "PubChem_URI"
  )

  body <- create_batch_body(metabolites_type, databases, masses_mode, ion_mode, adducts, tolerance, tolerance_mode, unique_mz)

  cli::cli_alert_info("Connecting to the {cmm_url} API...")

  r <- httr::POST(url = cmm_url, body = body, httr::content_type("application/json"))

  if (r$status_code == 200) {
    cli::cli_alert_success("API request successful (Status: {r$status_code}).")

    json_file <- RJSONIO::fromJSON(httr::content(r, "text", encoding = "UTF-8"))$results
    if (length(json_file) == 0) {
      cli::cli_alert_warning("No compounds found in the database search.")
      return("No compounds found in the database search.")
    }

    pb <- progress::progress_bar$new(
      format = "  Parsing database search results [:bar] :percent in :elapsed",
      total = length(json_file) - 1,
      clear = FALSE,
      width = 100
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

    cli::cli_alert_success("Database search results parsed successfully.")
    return(df)

  } else {
    cli::cli_alert_danger("Failed to connect to the API service (Status: {r$status_code}).")
  }
}
