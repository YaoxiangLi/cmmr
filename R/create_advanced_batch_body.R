#' Create POST request Body for batch search
#'
#' \code{create_advanced_batch_body} returns a string of advanced search POST request body.
#'
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
#'
#' @author Yaoxiang Li \email{yl814@georgetown.edu}
#'
#' Georgetown University, USA
#'
#' License: GPL (>= 3)
#' @export
#'
create_advanced_batch_body <- function(
  chemical_alphabet   = 'all',
  modifiers_type      = 'none',
  metabolites_type    = 'all-except-peptides',
  databases           = '["hmdb"]',
  masses_mode         = 'mz',
  ion_mode            = 'positive',
  adducts             = '["all"]',
  deuterium           = 'false',
  tolerance           = '7.5',
  tolerance_mode      = 'ppm',
  masses              = '[400.3432, 288.2174]',
  all_masses          = '[]',
  retention_times     = '[18.842525, 4.021555]',
  all_retention_times = '[]',
  composite_spectra   = paste0(
    '[[{ "mz": 400.3432, "intensity": 307034.88 }, ',
    '{ "mz": 311.20145, "intensity": 400.03336 }]]'
  )) {

  post_body <- paste0('{"chemical_alphabet": "' , chemical_alphabet,
                      '","modifiers_type": "'   , modifiers_type,
                      '","metabolites_type": "' , metabolites_type,
                      '","databases": '         , databases,
                      ',"masses_mode": "'       , masses_mode,
                      '","ion_mode": "'         , ion_mode,
                      '","adducts": '           , adducts,
                      ',"deuterium": '          , deuterium,
                      ',"tolerance": '          , as.character(tolerance),
                      ',"tolerance_mode":"'     , tolerance_mode,
                      '","masses": '            , masses,
                      ',"all_masses": '         , all_masses,
                      ',"retention_times": '    , retention_times,
                      ',"all_retention_times": ', all_retention_times,
                      ',"composite_spectra": '  , composite_spectra,
                      '}')

}
