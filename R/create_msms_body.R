#' Create MS/MS search POST request body
#'
#' \code{create_msms_body} returns a string of a POST request body.
#'
#' @param ion_mass ion_mass
#' @param ms_ms_peaks ms_ms_peaks
#' @param precursor_ion_tolerance precursor_ion_tolerance
#' @param precursor_ion_tolerance_mode precursor_ion_tolerance_mode
#' @param precursor_mz_tolerance precursor_mz_tolerance
#' @param precursor_mz_tolerance_mode precursor_mz_tolerance_mode
#' @param ion_mode ion_mode
#' @param ionizationVoltage ionizationVoltage
#' @param spectra_types spectra_types
#'
#' @return If all inputs are all correctly formatted, a string of a POST request will be returned for the result.
#' @author Yaoxiang Li \email{yl814@georgetown.edu}
#'
#' Georgetown University, USA
#'
#' License: GPL (>= 3)
#' @export
#'
create_msms_body = function(ion_mass,
                            ms_ms_peaks,
                            precursor_ion_tolerance      = 500.0,
                            precursor_ion_tolerance_mode = "mDa",
                            precursor_mz_tolerance       = 1000.0,
                            precursor_mz_tolerance_mode  = "mDa",
                            ion_mode                     = "positive",
                            ionizationVoltage            = "all",
                            spectra_types                = "experimental") {

  ms_ms_peaks_vector <- c()
  for (i in 1:nrow(ms_ms_peaks)) {
    v <- paste0('{"mz":', ms_ms_peaks[i, 1],',"intensity":', ms_ms_peaks[i, 2],'}')
    ms_ms_peaks_vector <- c(ms_ms_peaks_vector, v)
  }
  ms_ms_peaks_vector <- paste(ms_ms_peaks_vector, collapse = ",")
  post_body <- paste0('{',
                     '"ion_mass":', as.character(ion_mass), ',',
                     '"ms_ms_peaks":[', ms_ms_peaks_vector, '],',
                     '"precursor_ion_tolerance":', as.character(precursor_ion_tolerance), ',',
                     '"precursor_ion_tolerance_mode":"', precursor_ion_tolerance_mode, '",',
                     '"precursor_mz_tolerance":', as.character(precursor_mz_tolerance), ',',
                     '"precursor_mz_tolerance_mode":"', precursor_mz_tolerance_mode, '",',
                     '"ion_mode":"', ion_mode, '",',
                     '"ionizationVoltage":"',ionizationVoltage, '",',
                     '"spectra_types":["experimental","predicted"]',
                     '}')
}

