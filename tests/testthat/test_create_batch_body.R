context("Create POST request Body for batch search")

test_that("Batch search POST request Body is correctly created in positive mode", {
  expect_equal(create_batch_body('all-except-peptides',
                                 '["all-except-mine"]',
                                 'mz',
                                 'positive',
                                 '["M+H","M+Na"]',
                                 10,
                                 'ppm',
                                 c(670.4623, 1125.2555, 602.6180)),
               "{\"metabolites_type\":\"all-except-peptides\",\"databases\":[\"all-except-mine\"],\"masses_mode\":\"mz\",\"ion_mode\":\"positive\",\"adducts\":[\"M+H\",\"M+Na\"],\"tolerance\":10,\"tolerance_mode\":\"ppm\",\"masses\":[670.4623,1125.2555,602.618]}")
})


test_that("Batch search POST request Body is correctly created in negative mode", {
  expect_equal(create_batch_body('all-except-peptides',
                                 '["all-except-mine"]',
                                 'mz',
                                 'negative',
                                 '["M-H","M+Cl"]',
                                 10,
                                 'ppm',
                                 c(670.4623, 1125.2555, 602.6180)),
               "{\"metabolites_type\":\"all-except-peptides\",\"databases\":[\"all-except-mine\"],\"masses_mode\":\"mz\",\"ion_mode\":\"negative\",\"adducts\":[\"M-H\",\"M+Cl\"],\"tolerance\":10,\"tolerance_mode\":\"ppm\",\"masses\":[670.4623,1125.2555,602.618]}")
})


