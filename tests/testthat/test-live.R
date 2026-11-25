# Tests against the live OpenPrescribing API. Off by default (network, rate limits, changing data).
# Run with:  Sys.setenv(OPAMR_LIVE_TESTS = "true"); devtools::test(filter = "live")
skip_if(!identical(Sys.getenv("OPAMR_LIVE_TESTS"), "true"), "Set OPAMR_LIVE_TESTS=true to run live API tests")
skip_on_cran()
skip_if_offline("openprescribing.net")
withr::local_options(opamr.cache = FALSE, opamr.rate = 1)
skip_if_not(suppressMessages(op_check_api()), "OpenPrescribing API not reachable from this network")

test_that("live national spending has the documented layout and plausible values", {
  x <- op_spending("0501013B0")
  expect_gt(nrow(x), 36L)
  expect_equal(names(x)[1:8], c("date", "org_type", "org_id", "org_name", "code", "items", "quantity", "actual_cost"))
  expect_true(all(x$items > 1e5))                 # England amoxicillin: hundreds of thousands per month
})

test_that("live Sub-ICB spending, list sizes and rate join", {
  u <- op_antibiotic_use("nitrofurantoin", org_type = "sicbl", org = "02P")
  expect_equal(unique(u$org_id), "02P")
  expect_true(all(is.finite(u$rate[u$date >= as.Date("2023-01-01")])))
  expect_true(all(u$rate > 0 & u$rate < 50, na.rm = TRUE))
})

test_that("live lookups return the documented columns", {
  b <- op_bnf_search("0501130R0", exact = TRUE)
  expect_true(all(c("type", "id", "name") %in% names(b)))
  o <- op_org_search("Barnsley", "sicbl")
  expect_true(all(c("id", "name") %in% names(o)))
})
