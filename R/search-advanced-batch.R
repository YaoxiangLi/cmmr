#' Advanced Batch Search using CEU Mass Mediator API
#'
#' \code{advanced_batch_search} performs an advanced batch search on the CEU Mass Mediator API
#' and returns a dataframe of search results.
#'
#' @param cmm_url A character string specifying the CEU Mass Mediator API endpoint.
#' @param chemical_alphabet A character string specifying the chemical alphabet to use.
#' @param modifiers_type A character string specifying the modifier type.
#' @param metabolites_type A character string specifying the metabolites type.
#' @param databases A list specifying the databases to search.
#' @param masses_mode A character string specifying the masses mode.
#' @param ion_mode A character string specifying the ionization mode.
#' @param adducts A list specifying the adducts to include in the search.
#' @param deuterium Logical value indicating whether to consider deuterium substitutions.
#' @param tolerance A numeric value specifying the mass tolerance.
#' @param tolerance_mode A character string specifying the tolerance mode.
#' @param masses A numeric vector of masses to search.
#' @param all_masses A list for arrays of masses (optional).
#' @param retention_times A numeric vector of retention times corresponding to the masses.
#' @param all_retention_times A list for retention times arrays (optional).
#' @param composite_spectra A list for composite spectra (optional).
#' @param all_composite_spectra A list for all composite spectra (optional)
#'
#' @return A dataframe containing the search results from the CEU Mass Mediator API.
#'
#' @examples
#' \donttest{
#' df <- advanced_batch_search(
#' cmm_url = "https://ceumass.eps.uspceu.es/mediator/api/v3/advancedbatch",
#' chemical_alphabet = "all",
#' modifiers_type = "none",
#' metabolites_type = "all-except-peptides",
#' databases = list("hmdb"),
#' masses_mode = "mz",
#' ion_mode = "positive",
#' adducts = list("all"),
#' deuterium = FALSE,
#' tolerance = 10.0,
#' tolerance_mode = "ppm",
#' masses = c(399.3367, 421.31686, 315.2424, 337.2234, 280.2402),
#' all_masses = list(),
#' retention_times = c(18.842525, 18.842525, 8.144917, 8.144917, 28.269503, 4.021555),
#' all_retention_times = list(),
#' composite_spectra = list(),
#' all_composite_spectra = list()
#' )
#'
#' head(df)
#'
#' }
#'
#'
#' @export
advanced_batch_search <- function(
    cmm_url = "https://ceumass.eps.uspceu.es/mediator/api/v3/advancedbatch",
    chemical_alphabet = "all",
    modifiers_type = "none",
    metabolites_type = "all-except-peptides",
    databases = list("hmdb"), # Ensure this is a list
    masses_mode = "mz",
    ion_mode = "positive",
    adducts = list("all"), # Ensure this is a list
    deuterium = FALSE,
    tolerance = 10.0,
    tolerance_mode = "ppm",
    masses = c(399.3367, 421.3169, 315.2424, 337.2234, 280.2402),
    all_masses = list(), # Empty list for all_masses
    retention_times = c(18.8425, 18.8425, 8.1449, 8.1449, 28.2695, 4.0216),
    all_retention_times = list(), # Empty list for retention times
    composite_spectra = list(), # Empty list for composite spectra
    all_composite_spectra = list() # Empty list for all composite spectra
) {
  # Create the body for the POST request
  post_body <- create_advanced_batch_body(
    chemical_alphabet, modifiers_type,
    metabolites_type, databases, masses_mode, ion_mode, adducts, deuterium,
    tolerance, tolerance_mode, masses, all_masses, retention_times,
    all_retention_times, composite_spectra, all_composite_spectra
  )

  cli::cli_alert_info("Connecting to the CEU Mass Mediator API at {cmm_url}...")

  # Send POST request
  response <- httr::POST(
    url = cmm_url,
    body = post_body,
    encode = "json",
    httr::content_type("application/json"),
    config = httr::config(ssl_verifypeer = FALSE)  # Disable SSL verification
  )

  # Handle response
  if (response$status_code == 200) {
    cli::cli_alert_success("API request successful (Status: {response$status_code}).")

    # Parse the results
    json_data <- httr::content(response, as = "parsed", type = "application/json")
    results <- json_data$results
    if (length(results) == 0) {
      cli::cli_alert_warning("No compounds found in the database search.")
      return(NULL)
    }

    # Define columns to save and their names
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

    # Convert results into a dataframe
    df_list <- lapply(results, function(record) {
      as.data.frame(record[names(record) %in% columns_to_save], stringsAsFactors = FALSE)
    })

    df <- do.call(rbind, df_list)
    colnames(df) <- columns_to_name

    cli::cli_alert_success("Database search results parsed successfully.")
    return(df)
  } else {
    cli::cli_alert_danger("Failed to connect to the API service (Status: {response$status_code}).")
    return(NULL)
  }
}