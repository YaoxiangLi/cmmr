# CMMR - CEU Mass Mediator API

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/cmmr)](https://cran.r-project.org/package=cmmr)
[![Travis build status](https://travis-ci.org/lzyacht/cmmr.svg?branch=master)](https://travis-ci.org/lzyacht/cmmr)
<!-- badges: end -->

CEU Mass Mediator RESTful API

Thank you @albertogilf for your kindness and help!

Please find the CEU Mass Mediator source code repository:
[CEU Mass Mediator source code on GitHub](https://github.com/albertogilf/ceuMassMediator)

The CEU Mass Mediator Website:
[CEU Mass Mediator](http://ceumass.eps.uspceu.es/)

## API Endpoint

Batch search
http://ceumass.eps.uspceu.es/mediator/api/v3/batch

Advanced search
http://ceumass.eps.uspceu.es/mediator/api/v3/advancedbatch

MS/MS search
http://ceumass.eps.uspceu.es/mediator/api/msmssearch

## About

CEU Mass Mediator is an online tool that aides researchers in identifying 
metabolites from mass spectrometry experiments. It is currently 
available as a web interface and a RESTful API. CMMR is a RESTful API implemented
for R. This makes it easy to access CEU Mass Mediator programatically in R, integrating
search results seamlessly into users custom pipelines and workflows.

## Installation

```r
install.packages("cmmr")
```

## Development version

To get a bug fix, or use a feature from the development version, you can install cmmr from GitHub.
```r
# install.packages("devtools")
devtools::install_github("lzyacht/cmmr")
```

## Example

### Batch search

Batch search all result in positive mode

```r
library(cmmr)

batch_df_pos <- batch_search('http://ceumass.eps.uspceu.es/mediator/api/v3/batch',
                             'all-except-peptides',
                             '["all-except-mine"]',
                             'mz',
                             'positive',
                             '["M+H","M+Na"]',
                             100,
                             'ppm',
                             c(670.4623, 1125.2555, 602.6180))


head(batch_df_pos)
str(batch_df_pos)
```

Batch search all result in negative mode

```r
library(cmmr)

batch_df_neg <- batch_search('http://ceumass.eps.uspceu.es/mediator/api/v3/batch',
                             'all-except-peptides',
                             '["all-except-mine"]',
                             'mz',
                             'negative',
                             '["M-H","M+Cl"]',
                             100,
                             'ppm',
                             c(670.4623, 1125.2555, 602.6180))
                             
head(batch_df_neg)
str(batch_df_neg)
```

### Providing external *.csv files for search

You may want to load your own list of m/zs from a csv or excel file to search the database.

```r
unique_mz_file <- system.file("extdata", "unique_mz.csv", package = "cmmr")
unique_mz <- read.table(unique_mz_file, sep = ",", stringsAsFactors = FALSE, header = FALSE)
unique_mz <- as.array(unique_mz[, 1])

batch_df_neg <- batch_search('http://ceumass.eps.uspceu.es/mediator/api/v3/batch',
                             'all-except-peptides',
                             '["all-except-mine"]',
                             'mz',
                             'negative',
                             '["M-H","M+Cl"]',
                             10,
                             'ppm',
                             unique_mz)

```

And save it as a *.csv to the same folder or some other specified folder
```r

# Save to the same folder of the unique_mz.csv
write.table(batch_df_neg, sub(".csv", "_db_search.csv", unique_mz_file),
                               sep = ",", row.names = FALSE)
```

Save to current working directory
```r
write.table(batch_df_neg, "batch_df_neg.csv", sep = ",", row.names = FALSE)                          
```

### Advanced batch search

```r
library(cmmr)

advanced_batch_df <- advanced_batch_search(
  cmm_url             = paste0(
    'http://ceumass.eps.uspceu.es/mediator/api/v3/',
    'advancedbatch'),
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
))

head(advanced_batch_df)
str(advanced_batch_df)
```

### MSMS Search

```r
library(cmmr)

ms_ms_peaks <- matrix(
  c(40.948, 0.174,
    56.022, 0.424,
    84.37, 53.488,
    101.50, 8.285,
    102.401, 0.775,
    129.670, 100.000,
    146.966, 20.070),
  ncol = 2,
  byrow = TRUE)

ms2_df <- msms_search(ion_mass = 147, ms_ms_peaks = ms_ms_peaks, ion_mode = 'positive')

head(ms2_df)
str(ms2_df)
```