
# CMMR - CEU Mass Mediator API

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/cmmr)](https://cran.r-project.org/package=cmmr)
<!-- badges: end -->

**CMMR** provides a programmatic interface in R to interact with the **CEU Mass Mediator RESTful API**, facilitating automated metabolomics data analysis from mass spectrometry experiments. 

The package integrates batch searches, advanced searches, and MS/MS spectral searches, allowing seamless incorporation into R-based metabolomics workflows. Users can leverage this package to process mass spectrometry data efficiently, without manual intervention through the web interface.

For further details on the CEU Mass Mediator platform, visit the [CEU Mass Mediator](https://ceumass.eps.uspceu.es/) website.

## Special Thanks

This package was built on top of the CEU Mass Mediator API by [Albert Gil](https://github.com/albertogilf/ceuMassMediator). Special thanks to @albertogilf for his contributions!

## API Endpoints

The package interacts with the following API endpoints:

- **Batch Search**: [https://ceumass.eps.uspceu.es/api/v3/batch](https://ceumass.eps.uspceu.es/api/v3/batch)
- **Advanced Search**: [https://ceumass.eps.uspceu.es/api/v3/advancedbatch](https://ceumass.eps.uspceu.es/api/v3/advancedbatch)
- **MS/MS Search**: [https://ceumass.eps.uspceu.es/api/msmssearch](https://ceumass.eps.uspceu.es/api/msmssearch)

## Installation

### CRAN Version

To install the stable version from CRAN, run:

```r
install.packages("cmmr")
```

### Development Version

To install the development version, which may include bug fixes or experimental features, use:

```r
# install.packages("devtools")
devtools::install_github("YaoxiangLi/cmmr")
```

## Usage Examples

### Batch Search

Perform a batch search in **positive ion mode**:

```r
library(cmmr)

batch_df_pos <- batch_search(
  cmm_url = 'https://ceumass.eps.uspceu.es/api/v3/batch',
  metabolites_type = 'all-except-peptides',
  databases = '["all-except-mine"]',
  masses_mode = 'mz',
  ion_mode = 'positive',
  adducts = '["M+H","M+Na"]',
  tolerance = 10,
  tolerance_mode = 'ppm',
  unique_mz = c(178.1219, 243.9134, 977.6763)
)

head(batch_df_pos)
str(batch_df_pos)
```

Perform a batch search in **negative ion mode**:

```r
library(cmmr)

batch_df_neg <- batch_search(
  cmm_url = 'https://ceumass.eps.uspceu.es/api/v3/batch',
  metabolites_type = 'all-except-peptides',
  databases = '["all-except-mine"]',
  masses_mode = 'mz',
  ion_mode = 'negative',
  adducts = '["M-H","M+Cl"]',
  tolerance = 100,
  tolerance_mode = 'ppm',
  unique_mz = c(670.4623, 1125.2555, 602.6180)
)

head(batch_df_neg)
str(batch_df_neg)
```

### Batch Search with External Files

Load a list of m/z values from a CSV file and use it in the batch search:

```r
# Load unique m/z values from CSV
unique_mz_file <- system.file("extdata", "unique_mz.csv", package = "cmmr")
unique_mz <- read.table(unique_mz_file, sep = ",", stringsAsFactors = FALSE, header = FALSE)
unique_mz <- as.array(unique_mz[, 1])

# Perform batch search using the loaded m/z values
batch_df_neg <- batch_search(
  cmm_url = 'https://ceumass.eps.uspceu.es/api/v3/batch',
  metabolites_type = 'all-except-peptides',
  databases = '["all-except-mine"]',
  masses_mode = 'mz',
  ion_mode = 'negative',
  adducts = '["M-H","M+Cl"]',
  tolerance = 10,
  tolerance_mode = 'ppm',
  unique_mz = unique_mz
)
```

Save the results:

```r
# Save the results in the same folder as the original CSV
write.table(batch_df_neg, sub(".csv", "_db_search.csv", unique_mz_file), sep = ",", row.names = FALSE)

# Save to the current working directory
write.table(batch_df_neg, "batch_df_neg.csv", sep = ",", row.names = FALSE)
```

### Advanced Batch Search

```r
library(cmmr)

advanced_batch_df <- advanced_batch_search(
  cmm_url = 'https://ceumass.eps.uspceu.es/mediator/api/v3/advancedbatch',
  chemical_alphabet = 'all',
  modifiers_type = 'none',
  metabolites_type = 'all-except-peptides',
  databases = '["hmdb"]',
  masses_mode = 'mz',
  ion_mode = 'positive',
  adducts = '["all"]',
  deuterium = FALSE,
  tolerance = 7.5,
  tolerance_mode = 'ppm',
  masses = c(400.3432, 288.2174),
  all_masses = '[]',
  retention_times = c(18.842525, 4.021555),
  all_retention_times = '[]',
  composite_spectra = paste0(
    '[ [ { "mz": 400.3432, "intensity": 307034.88 },',
    ' { "mz": 311.20145, "intensity": 400.03336 } ] ]'
  )
)

head(advanced_batch_df)
str(advanced_batch_df)
```

### MS/MS Search

```r
library(cmmr)

# Define MS/MS peaks (m/z and intensity)
ms_ms_peaks <- matrix(
  c(40.948, 0.174,
    56.022, 0.424,
    84.370, 53.488,
    101.500, 8.285,
    102.401, 0.775,
    129.670, 100.000,
    146.966, 20.070),
  ncol = 2,
  byrow = TRUE
)

# Perform MS/MS search
ms2_df <- msms_search(
  ion_mass = 147, 
  ms_ms_peaks = ms_ms_peaks, 
  ion_mode = 'positive'
)

head(ms2_df)
str(ms2_df)
```

## Contribution Guidelines

If you'd like to contribute to the development of **CMMR**, please follow the [tidyverse style guide](https://style.tidyverse.org/). Below are a few key conventions to adhere to:

- Write **roxygen2** comments as complete sentences, starting with a capital letter and ending with a period.
- Keep comments brief and to the point. For example, prefer "Calculates standard deviation" over "This function calculates and returns the standard deviation of a given set of numbers."
- Ensure code is formatted and styled consistently with the guidelines.
