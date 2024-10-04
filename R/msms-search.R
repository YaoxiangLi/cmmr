#' MS/MS Search using CEU Mass Mediator API
#'
#' \code{msms_search} performs an MS/MS search on the CEU Mass Mediator API
#' and returns a dataframe with the search results.
#'
#' @param ion_mass Numeric. Mass of the ion to search for.
#' @param ms_ms_peaks Matrix. The MS/MS peaks, with two columns representing mass and intensity.
#' @param precursor_ion_tolerance Numeric. Tolerance for the precursor ion (default: 100.0).
#' @param precursor_ion_tolerance_mode Character. Tolerance mode for precursor ion: \code{"ppm"} or \code{"mDa"} (default: "mDa").
#' @param precursor_mz_tolerance Numeric. Tolerance for the m/z (default: 500.0).
#' @param precursor_mz_tolerance_mode Character. Tolerance mode for precursor m/z: \code{"ppm"} or \code{"mDa"} (default: "mDa").
#' @param ion_mode Character. Ionization mode: \code{"positive"} or \code{"negative"}.
#' @param ionization_voltage Character. Ionization voltage to use (default: "all").
#' @param spectra_types Character. Spectra types: \code{"experimental"} or other supported types.
#' @param cmm_url Character. URL for the CEU Mass Mediator API (default: "https://ceumass.eps.uspceu.es/api/msmssearch").
#'
#' @return A dataframe containing the search results from the CEU Mass Mediator API.
#' @examples
#' \donttest{
#' ms_ms_peaks <- matrix(
#'   c(
#'     40.948, 0.174,
#'     56.022, 0.424,
#'     84.370, 53.488,
#'     101.500, 8.285,
#'     102.401, 0.775,
#'     129.670, 100.000,
#'     146.966, 20.070
#'   ),
#'   ncol = 2,
#'   byrow = TRUE
#' )
#'
#' df <- msms_search(
#'   ion_mass = 147,
#'   ms_ms_peaks = ms_ms_peaks,
#'   ion_mode = "positive"
#' )
#' }
#' @export
msms_search <- function(ion_mass,
                        ms_ms_peaks,
                        precursor_ion_tolerance = 100.0,
                        precursor_ion_tolerance_mode = "mDa",
                        precursor_mz_tolerance = 500.0,
                        precursor_mz_tolerance_mode = "mDa",
                        ion_mode,
                        ionization_voltage = "all",
                        spectra_types = "experimental",
                        cmm_url = "https://ceumass.eps.uspceu.es/api/msmssearch") {
  columns_to_save <- c(
    "spectral_display_tools",
    "identifier",
    "hmdb_compound",
    "name",
    "formula",
    "mass",
    "score"
  )

  columns_to_name <- c(
    "Spectral_display_tools",
    "Identifier",
    "HMDB_ID",
    "Name",
    "Formula",
    "Mass",
    "Score"
  )

  body <- create_msms_body(
    ion_mass, ms_ms_peaks,
    precursor_ion_tolerance, precursor_ion_tolerance_mode,
    precursor_mz_tolerance, precursor_mz_tolerance_mode,
    ion_mode, ionization_voltage, spectra_types
  )

  cli::cli_alert_info("Connecting to the CEU Mass Mediator API at {cmm_url}...")

  r <- httr::POST(url = cmm_url, body = body, httr::content_type("application/json"))

  if (r$status_code == 200) {
    cli::cli_alert_success("API request successful (Status: {r$status_code}).")

    json_file <- RJSONIO::fromJSON(httr::content(r, "text", encoding = "UTF-8"))$results
    if (length(json_file) == 0) {
      cli::cli_alert_warning("No validation found in MS/MS search.")
      return(NULL)
    }

    pb <- progress::progress_bar$new(
      format = "  Parsing database search results [:bar] :percent in :elapsed",
      total = length(json_file),
      clear = FALSE,
      width = 100
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
