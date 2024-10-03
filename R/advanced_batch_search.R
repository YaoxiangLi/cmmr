#' Encapsulation of CEU Mass Mediator advanced batch search API.
#'
#' \code{advanced_batch_search} returns the body string of a POST request.
#'   using the following code to install the dependencies:
#'   install.packages(c("httr", "progress", "RJSONIO"))
#'
#' @param cmm_url 'http://ceumass.eps.uspceu.es/mediator/api/v3/advancedbatch' or your local one
#' @param chemical_alphabet "CHNOPS", "CHNOPSCL", "ALL"
#' @param modifiers_type "none", "NH3", "HCOO", "CH3COO", "HCOONH3", "CH3COONH3"
#' @param metabolites_type "all-except-peptides", "only-lipids", "all-including-peptides"
#' @param databases "all", "all-except-mine", "HMDB", "LipidMaps", "Metlin", "Kegg", "in-house", "mine"
#' @param masses_mode "neutral", "mz"
#' @param ion_mode "positive", "negative"
#' @param adducts for positive mode ["M+H", "M+2H", "M+Na", "M+K", "M+NH4", "M+H-H2O"] for negative mode ["M-H", "M+Cl", "M+FA-H", "M-H-H2O"], for neutral ["M"]
#' @param deuterium boolean 'true' 'false'
#' @param tolerance double (Range: [0..100])
#' @param tolerance_mode "ppm", "mDa"
#' @param masses double
#' @param all_masses array of doubles
#' @param retention_times double
#' @param all_retention_times array of doubles
#' @param composite_spectra array of arrays of spectra_object
#'
#' @return If all inputs are all correctly formatted, a dataframe will be returned for the result.
#' @examples df <- advanced_batch_search(
#'   cmm_url = paste0(
#'     "http://ceumass.eps.uspceu.es/mediator/api/v3/",
#'     "advancedbatch"
#'   ),
#'   chemical_alphabet = "all",
#'   modifiers_type = "none",
#'   metabolites_type = "all-except-peptides",
#'   databases = '["hmdb"]',
#'   masses_mode = "mz",
#'   ion_mode = "positive",
#'   adducts = '["all"]',
#'   deuterium = "false",
#'   tolerance = "7.5",
#'   tolerance_mode = "ppm",
#'   masses = "[400.3432, 288.2174]",
#'   all_masses = "[]",
#'   retention_times = "[18.842525, 4.021555]",
#'   all_retention_times = "[]",
#'   composite_spectra = paste0(
#'     '[[{ "mz": 400.3432, "intensity": 307034.88 }, ',
#'     '{ "mz": 311.20145, "intensity": 400.03336 }]]'
#'   )
#' )
#' @export
#'
advanced_batch_search <- function(
    cmm_url = paste0(
      "http://ceumass.eps.uspceu.es/mediator/api/v3/",
      "advancedbatch"
    ),
    chemical_alphabet = "all",
    modifiers_type = "none",
    metabolites_type = "all-except-peptides",
    databases = '["hmdb"]',
    masses_mode = "mz",
    ion_mode = "positive",
    adducts = '["all"]',
    deuterium = "false",
    tolerance = "7.5",
    tolerance_mode = "ppm",
    masses = "[400.3432, 288.2174]",
    all_masses = "[]",
    retention_times = "[18.842525, 4.021555]",
    all_retention_times = "[]",
    composite_spectra = paste0(
      '[[{ "mz": 400.3432, "intensity": 307034.88 }, ',
      '{ "mz": 311.20145, "intensity": 400.03336 }]]'
    )) {
  post_body <- create_advanced_batch_body(
    chemical_alphabet, modifiers_type,
    metabolites_type, databases, masses_mode, ion_mode, adducts, deuterium,
    tolerance, tolerance_mode, masses, all_masses, retention_times,
    all_retention_times, composite_spectra
  )

  if (cmm_url == "http://ceumass.eps.uspceu.es/mediator/api/v3/advancedbatch") {
    cat("Using the CEU Mass Mediator server API.\n")
  } else {
    cat("Using the local/3rd party server API:\n")
    cat(paste0(cmm_url, "\n"))
  }

  r <- httr::POST(url = cmm_url, body = post_body, httr::content_type("application/json"))


  if (r$status_code == 200) {
    columns_to_save <- c(
      "RT", "adductRelationScore", "RTscore",
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
      "RT", "adductRelationScore", "RTscore",
      "Identifier", "Experimental.mass", "Name", "Formula", "Adduct",
      "Molecular.Weight", "PPM.Error",
      "Ionization.Score", "Final.Score",
      "Kegg", "Kegg_URI",
      "HMDB", "HMDB_URI",
      "LipidMaps", "LipidMaps_URI",
      "Metlin", "Metlin_URI",
      "PubChem", "PubChem_URI"
    )

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
    return(df)
  } else {
    cat(paste0("Status: ", r$status_code, ", Fail to connect the API service!\n"))
    cat(paste0("Date: ", r$date, "\n"))
  }
}
