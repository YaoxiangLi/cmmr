.onAttach <- function(libname, pkgname) {
  packageStartupMessage(paste0(
    "\nThis is cmmr version ",
    utils::packageVersion("cmmr"),
    ". Please cite the CEU Mass Mediator paper:",
    "\nGil-de-la-Fuente A, Godzien J, Saugar S, et al. CEU Mass Mediator 3.0: A Metabolite Annotation Tool. J Proteome Res. 2019;18(2):797-802. doi:10.1021/acs.jproteome.8b00720"
  ))
}
