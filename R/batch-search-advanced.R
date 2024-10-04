#' Advanced Batch Search using CEU Mass Mediator API
#'
#' \code{advanced_batch_search} performs an advanced batch search on the CEU Mass Mediator API
#' and returns a dataframe of search results.
#'
#' @param cmm_url A character string specifying the CEU Mass Mediator API endpoint.
#'   Default is \code{"https://ceumass.eps.uspceu.es/api/v3/advancedbatch"}.
#' @param chemical_alphabet A character string specifying the chemical alphabet to use.
#'   Options are \code{"CHNOPS"}, \code{"CHNOPSCL"}, or \code{"ALL"}.
#' @param modifiers_type A character string specifying the modifier type.
#'   Options are \code{"none"}, \code{"NH3"}, \code{"HCOO"}, \code{"CH3COO"}, \code{"HCOONH3"}, or \code{"CH3COONH3"}.
#' @param metabolites_type A character string specifying the metabolites type.
#'   Options are \code{"all-except-peptides"}, \code{"only-lipids"}, or \code{"all-including-peptides"}.
#' @param databases A JSON-formatted character string specifying the databases to search.
#'   Examples include \code{'["all"]'}, \code{'["HMDB"]'}, \code{'["LipidMaps"]'}.
#' @param masses_mode A character string specifying the masses mode. Options are \code{"neutral"} or \code{"mz"}.
#' @param ion_mode A character string specifying the ionization mode. Options are \code{"positive"}, \code{"negative"}, or \code{"neutral"}.
#' @param adducts A JSON-formatted character string specifying the adducts to include in the search.
#'   Examples include \code{'["M+H","M+Na"]'} for positive mode.
#' @param deuterium A logical value indicating whether to consider deuterium substitutions. \code{TRUE} or \code{FALSE}.
#' @param tolerance A numeric value specifying the mass tolerance (Range: \code{0} to \code{100}).
#' @param tolerance_mode A character string specifying the tolerance mode. Options are \code{"ppm"} or \code{"mDa"}.
#' @param masses A numeric vector of masses to search.
#' @param all_masses A JSON-formatted character string representing an array of mass arrays.
#' @param retention_times A numeric vector of retention times corresponding to the masses.
#' @param all_retention_times A JSON-formatted character string representing an array of retention time arrays.
#' @param composite_spectra A JSON-formatted character string representing composite spectra.
#'
#' @return A dataframe containing the search results from the CEU Mass Mediator API.
#' @examples
#' \donttest{
#' df <- advanced_batch_search(
#'   cmm_url = "https://ceumass.eps.uspceu.es/api/v3/advancedbatch",
#'   chemical_alphabet = "ALL",
#'   modifiers_type = "none",
#'   metabolites_type = "all-except-peptides",
#'   databases = '["HMDB"]',
#'   masses_mode = "mz",
#'   ion_mode = "positive",
#'   adducts = '["all"]',
#'   deuterium = FALSE,
#'   tolerance = 7.5,
#'   tolerance_mode = "ppm",
#'   masses = c(400.3432, 288.2174),
#'   all_masses = "[]",
#'   retention_times = c(18.842525, 4.021555),
#'   all_retention_times = "[]",
#'   composite_spectra = paste0(
#'     '[ [ { "mz": 400.3, "intensity": 307034.9 },',
#'     '   { "mz": 311.2, "intensity": 400.1 } ] ]'
#'   )
#' )
#' }

#' @export
advanced_batch_search <- function(
    cmm_url = "https://ceumass.eps.uspceu.es/api/v3/advancedbatch",
    chemical_alphabet = "ALL",
    modifiers_type = "none",
    metabolites_type = "all-except-peptides",
    databases = '["HMDB"]',
    masses_mode = "mz",
    ion_mode = "positive",
    adducts = '["all"]',
    deuterium = FALSE,
    tolerance = 7.5,
    tolerance_mode = "ppm",
    masses = NULL,
    all_masses = "[]",
    retention_times = NULL,
    all_retention_times = "[]",
    composite_spectra = NULL) {
  post_body <- create_advanced_batch_body(
    chemical_alphabet, modifiers_type,
    metabolites_type, databases, masses_mode, ion_mode, adducts, deuterium,
    tolerance, tolerance_mode, masses, all_masses, retention_times,
    all_retention_times, composite_spectra
  )

  cli::cli_alert_info("Connecting to the CEU Mass Mediator API at {cmm_url}...")

  r <- httr::POST(url = cmm_url, body = post_body, httr::content_type("application/json"))

  if (r$status_code == 200) {
    cli::cli_alert_success("API request successful (Status: {r$status_code}).")

    json_file <- RJSONIO::fromJSON(httr::content(r, "text", encoding = "UTF-8"))$results
    if (length(json_file) == 0) {
      cli::cli_alert_warning("No compounds found in the database search.")
      return(NULL)
    }

    pb <- progress::progress_bar$new(
      format = "  Parsing database search results [:bar] :percent in :elapsed",
      total  = length(json_file),
      clear  = FALSE,
      width  = 100
    )

    columns_to_save <- c(
      "RT", "adductRelationScore", "RTscore",
      "identifier", "EM", "name", "formula", "adduct",
      "molecular_weight", "error_ppm", "ionizationScore", "finalScore",
      "kegg_compound", "kegg_uri", "hmdb_compound", "hmdb_uri",
      "lipidmaps_compound", "lipidmaps_uri", "metlin_compound", "metlin_uri",
      "pubchem_compound", "pubchem_uri"
    )

    columns_to_name <- c(
      "retention_time", "adduct_relation_score", "RT_score",
      "identifier", "experimental_mass", "name", "formula", "adduct",
      "molecular_weight", "error_ppm", "ionization_score", "final_score",
      "KEGG", "KEGG_URI", "HMDB", "HMDB_URI", "LipidMaps", "LipidMaps_URI",
      "Metlin", "Metlin_URI", "PubChem", "PubChem_URI"
    )

    df_list <- lapply(seq_along(json_file), function(i) {
      pb$tick()
      record <- json_file[[i]]
      as.data.frame(record[names(record) %in% columns_to_save], stringsAsFactors = FALSE)
    })

    df <- do.call(rbind, df_list)
    df <- df[, columns_to_save]
    colnames(df) <- columns_to_name

    cli::cli_alert_success("Database search results parsed successfully.")
    return(df)
  } else {
    cli::cli_alert_danger("Failed to connect to the API service (Status: {r$status_code}).")
    return(NULL)
  }
}
