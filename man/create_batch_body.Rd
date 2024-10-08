% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create-batch-body.R
\name{create_batch_body}
\alias{create_batch_body}
\title{Create POST request Body for batch search}
\usage{
create_batch_body(
  metabolites_type = "all-except-peptides",
  databases = "[\\"all-except-mine\\"]",
  masses_mode = "mz",
  ion_mode = "positive",
  adducts = "[\\"M+H\\",\\"M+Na\\"]",
  tolerance = 10,
  tolerance_mode = "ppm",
  unique_mz
)
}
\arguments{
\item{metabolites_type}{"all-except-peptides", "only-lipids", "all-including-peptides"}

\item{databases}{"all", "all-except-mine", "HMDB", "LipidMaps", "Metlin", "Kegg", "in-house", "mine"}

\item{masses_mode}{"neutral", "mz"}

\item{ion_mode}{"positive", "negative"}

\item{adducts}{for positive mode [M+H, M+2H, M+Na, M+K,M+NH4, M+H-H2O]}

\item{tolerance}{double (Range: [0..100])}

\item{tolerance_mode}{"ppm", "mDa"}

\item{unique_mz}{An array of unique m/zs}
}
\value{
If all inputs are all correctly formatted, a string of a POST request will be returned for the result.
}
\description{
\code{create_batch_body} returns a string of a POST request body.
}
\examples{

batch_body <- create_batch_body(
  "all-except-peptides",
  '["all-except-mine"]',
  "mz",
  "positive",
  '["M+H","M+Na"]',
  10,
  "ppm",
  c(670.4623, 1125.2555, 602.6180)
)

batch_body <- create_batch_body(
  "all-except-peptides",
  '["all-except-mine"]',
  "mz",
  "negative",
  '["M-H","M+Cl"]',
  10,
  "ppm",
  c(670.4623, 1125.2555, 602.6180)
)

\dontrun{
create_batch_body(c(670.4623, 1125.2555, 602.6180))
}
}
