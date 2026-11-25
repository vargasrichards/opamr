test_that("as_op_date accepts YYYY-MM, YYYY-MM-DD and Date, and deduplicates", {
  expect_equal(as_op_date("2025-03"), "2025-03-01")
  expect_equal(as_op_date(c("2025-03-01", "2025-03")), "2025-03-01")
  expect_equal(as_op_date(as.Date(c("2024-12-01", "2025-01-01"))), c("2024-12-01", "2025-01-01"))
  expect_null(as_op_date(NULL))
  expect_warning(d <- as_op_date("2025-03-17"), "first of the month")
  expect_equal(d, "2025-03-01")
  expect_error(as_op_date("March 2025"), "Could not parse")
})

test_that("clean_codes upper-cases, trims and deduplicates", {
  expect_equal(clean_codes(c(" 0501013b0 ", "0501013B0", "0501")), c("0501013B0", "0501"))
  expect_error(clean_codes(NA_character_), "without NA")
  expect_error(clean_codes(c(" ", "")), "is empty")
  expect_error(clean_codes(5), "character vector")
})

test_that("organisation types are validated and translated for each endpoint", {
  expect_equal(check_org_type("sicbl"), "sicbl")
  expect_error(check_org_type("ccg"), "must be one of")
  expect_error(check_org_type(c("sicbl", "icb")), "must be one of")
  expect_null(api_org_type("national"))
  expect_equal(api_org_type("sicbl"), "sicbl")
  expect_equal(unname(api_org_type("sicbl", legacy = TRUE)), "ccg")
  expect_equal(unname(api_org_type("icb", legacy = TRUE)), "stp")
  expect_equal(api_org_type("practice", legacy = TRUE), "practice")
})

test_that("col_or_na fills missing columns", {
  df <- data.frame(a = 1:2)
  expect_equal(col_or_na(df, "a"), 1:2)
  expect_equal(col_or_na(df, "b"), c(NA_character_, NA_character_))
  expect_equal(col_or_na(df, "b", NA_real_), c(NA_real_, NA_real_))
})

test_that("%||% returns the fallback only for NULL", {
  expect_equal(NULL %||% 2, 2)
  expect_equal(1 %||% 2, 1)
  expect_true(is.na(NA %||% 2))
})
