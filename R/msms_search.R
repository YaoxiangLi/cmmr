#' Encapsulation of CEU Mass Mediator batch search API.
#'
#' \code{batch_search} returns the dataframe of all the database search results.
#'   using the following code to install the dependencies:
#'   install.packages(c("httr", "progress", "RJSONIO"))
#'
#' @param ion_mass ion_mass
#' @param ms_ms_peaks ms_ms_peaks
#' @param precursor_ion_tolerance precursor_ion_tolerance
#' @param precursor_ion_tolerance_mode precursor_ion_tolerance_mode
#' @param precursor_mz_tolerance precursor_mz_tolerance
#' @param precursor_mz_tolerance_mode precursor_mz_tolerance_mode
#' @param ion_mode ion_mode
#' @param ionization_voltage ionization_voltage
#' @param spectra_types spectra_types
#' @param cmm_url "http://ceumass.eps.uspceu.es/mediator/api/msmssearch" or your local one
#'
#' @return If all inputs are all correctly formatted, a dataframe will be returned for the result.
#' @examples ms_ms_peaks <- matrix(
#'   c(
#'     40.948, 0.174,
#'     56.022, 0.424,
#'     84.37, 53.488,
#'     101.50, 8.285,
#'     102.401, 0.775,
#'     129.670, 100.000,
#'     146.966, 20.070
#'   ),
#'   ncol = 2,
#'   byrow = TRUE
#' )
#'
#' msms_search(ion_mass = 147, ms_ms_peaks = ms_ms_peaks, ion_mode = "positive")
#'
#' @export
#'
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
  if (cmm_url == "https://ceumass.eps.uspceu.es/api/msmssearch") {
    print("Using the CEU Mass Mediator server API.")
  } else {
    print("Using the local/3rd party server API.")
  }

  r <- httr::POST(url = cmm_url, body = body, httr::content_type("application/json"))

  if (r$status_code == 200) {
    cat(paste0("Status: ", r$status_code, ", Success!\n"))
    cat(paste0("Date: ", r$date, "\n"))
    json_file <- RJSONIO::fromJSON(httr::content(r, "text", encoding = "UTF-8"))$results
    if (length(json_file) == 0) {
      print("No validation found in MS/MS search.")
      return("No validation found in MS/MS search")
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
