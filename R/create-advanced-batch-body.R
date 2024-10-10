#' Create POST request Body for advanced batch search
#'
#' \code{create_advanced_batch_body} creates a list for the advanced batch search POST request.
#'
#' @param chemical_alphabet A string for the chemical alphabet: "CHNOPS", "CHNOPSCL", "ALL".
#' @param modifiers_type A string for the modifier type: "none", "NH3", "HCOO", etc.
#' @param metabolites_type A string for metabolites type: "all-except-peptides", "only-lipids", etc.
#' @param databases A vector of databases to search: e.g., list("HMDB").
#' @param masses_mode A string specifying masses mode: "neutral" or "mz".
#' @param ion_mode A string for the ionization mode: "positive", "negative", etc.
#' @param adducts A vector of adducts to include in the search, e.g., list("M+H", "M+Na").
#' @param deuterium Logical value: whether to consider deuterium substitutions (TRUE or FALSE).
#' @param tolerance Numeric value specifying the tolerance.
#' @param tolerance_mode A string for the tolerance mode: "ppm" or "mDa".
#' @param masses Numeric vector of masses to search.
#' @param all_masses Empty array for all masses (optional).
#' @param retention_times Numeric vector of retention times.
#' @param all_retention_times Empty array for retention times (optional).
#' @param composite_spectra Empty array for composite spectra.
#' @param all_composite_spectra A list for all composite spectra (optional)
#'
#' @return A properly formatted JSON body for the POST request.
#'
#' @export
create_advanced_batch_body <- function(
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
  # Create the body as a list
  body <- list(
    chemical_alphabet = chemical_alphabet,
    modifiers_type = modifiers_type,
    metabolites_type = metabolites_type,
    databases = databases,
    masses_mode = masses_mode,
    ion_mode = ion_mode,
    adducts = adducts,
    deuterium = deuterium,
    tolerance = tolerance,
    tolerance_mode = tolerance_mode,
    masses = masses,
    all_masses = all_masses,
    retention_times = retention_times,
    all_retention_times = all_retention_times,
    composite_spectra = composite_spectra,
    all_composite_spectra = all_composite_spectra
  )

  jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE)
}