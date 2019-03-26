.onAttach <- function(libname, pkgname) {
  packageStartupMessage(paste(
    "\nThis is cmmr version",
    utils::packageVersion("cmmr")
  ))
}
