#' Create POST request Body for batch search
#'
#' \code{create_batch_body} returns a string of a POST request body.
#'
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
#' @return If all inputs are all correctly formatted, a string of a POST request will be returned for the result.
#' @examples
#'
#' batch_body <- create_batch_body('all-except-peptides',
#'                                 '["all-except-mine"]',
#'                                 'mz',
#'                                 'positive',
#'                                 '["M+H","M+Na"]',
#'                                 10,
#'                                 'ppm',
#'                                 c(670.4623, 1125.2555, 602.6180))
#'
#' batch_body <- create_batch_body('all-except-peptides',
#'                                 '["all-except-mine"]',
#'                                 'mz',
#'                                 'negative',
#'                                 '["M-H","M+Cl"]',
#'                                 10,
#'                                 'ppm',
#'                                 c(670.4623, 1125.2555, 602.6180))
#'
#' \dontrun{
#' create_batch_body(c(670.4623, 1125.2555, 602.6180))
#' }
#'
#' @author Yaoxiang Li \email{yl814@georgetown.edu}
#'
#' Georgetown University, USA
#'
#' License: GPL (>= 3)
#' @export
#'
create_batch_body <- function(metabolites_type = 'all-except-peptides',
                              databases        = '["all-except-mine"]',
                              masses_mode      = 'mz',
                              ion_mode         = 'positive',
                              adducts          = '["M+H","M+Na"]',
                              tolerance        = 10,
                              tolerance_mode   = 'ppm',
                              unique_mz) {

  masses    <- paste(unique_mz, collapse = ",")
  tolerance <- as.character(tolerance)
  post_body <- paste0(
    '{"metabolites_type":"' , metabolites_type,
    '","databases":'        , databases,
    ',"masses_mode":"'      , masses_mode,
    '","ion_mode":"'        , ion_mode,
    '","adducts":'          , adducts,
    ',"tolerance":'         , tolerance,
    ',"tolerance_mode":"'   , tolerance_mode,
    '","masses":['          , masses,
    ']}')
}
