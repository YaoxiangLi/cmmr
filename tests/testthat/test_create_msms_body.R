context("Create POST request Body for MS/MS search")

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


test_that("Batch search POST request Body is correctly created in positive mode", {
  expect_equal(create_msms_body(
    147,
    ms_ms_peaks,
    precursor_ion_tolerance      = 500.0,
    precursor_ion_tolerance_mode = "mDa",
    precursor_mz_tolerance       = 1000.0,
    precursor_mz_tolerance_mode  = "mDa",
    ion_mode                     = "positive",
    ionization_voltage           = "all",
    spectra_types                = "experimental"),
    "{\"ion_mass\":147,\"ms_ms_peaks\":[{\"mz\":40.948,\"intensity\":0.174},{\"mz\":56.022,\"intensity\":0.424},{\"mz\":84.37,\"intensity\":53.488},{\"mz\":101.5,\"intensity\":8.285},{\"mz\":102.401,\"intensity\":0.775},{\"mz\":129.67,\"intensity\":100},{\"mz\":146.966,\"intensity\":20.07}],\"precursor_ion_tolerance\":500,\"precursor_ion_tolerance_mode\":\"mDa\",\"precursor_mz_tolerance\":1000,\"precursor_mz_tolerance_mode\":\"mDa\",\"ion_mode\":\"positive\",\"ionization_voltage\":\"all\",\"spectra_types\":[\"experimental\",\"predicted\"]}")
})

# msms_search(ion_mass = 147, ms_ms_peaks = ms_ms_peaks, ion_mode = 'positive')
