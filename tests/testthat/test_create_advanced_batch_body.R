context("Create POST request Body for advanced batch search")

test_that("Batch search POST request Body is correctly created in positive mode", {
  expect_equal(create_advanced_batch_body(
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
    composite_spectra   = '[[{ "mz": 400.3432, "intensity": 307034.88 }, { "mz": 311.20145, "intensity": 400.03336 }]]'
  ),
  "{\"chemical_alphabet\": \"all\",\"modifiers_type\": \"none\",\"metabolites_type\": \"all-except-peptides\",\"databases\": [\"hmdb\"],\"masses_mode\": \"mz\",\"ion_mode\": \"positive\",\"adducts\": [\"all\"],\"deuterium\": false,\"tolerance\": 7.5,\"tolerance_mode\":\"ppm\",\"masses\": [400.3432, 288.2174],\"all_masses\": [],\"retention_times\": [18.842525, 4.021555],\"all_retention_times\": [],\"composite_spectra\": [[{ \"mz\": 400.3432, \"intensity\": 307034.88 }, { \"mz\": 311.20145, \"intensity\": 400.03336 }]]}")
})
