cw <- antibiotic_crosswalk

test_that("crosswalk codes and columns follow the BNF and ATC formats", {
  expect_true(all(grepl("^[0-9]{7}[0-9A-Z]{2}$", cw$bnf_chemical_code)))
  expect_true(all(cw$bnf_chapter == substr(cw$bnf_chemical_code, 1, 2)))
  expect_true(all(cw$bnf_paragraph == substr(cw$bnf_chemical_code, 1, 6)))
  atc <- stats::na.omit(cw$atc)
  expect_true(all(grepl("^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$", atc)))
  # the primary ATC is always one of the agent's ATC codes
  ok <- mapply(function(a, all) is.na(a) || a %in% strsplit(all, "|", fixed = TRUE)[[1]], cw$atc, cw$atc_all)
  expect_true(all(ok))
  expect_false(anyNA(cw$ab_name))
  expect_true(all(cw$match_method %in% c("AMR::as.ab", "manual")))
})

test_that("crosswalk chapter-5 rows are anti-infectives and systemic codes prefer J", {
  sys <- cw[cw$bnf_chapter == "05", ]
  expect_true(all(substr(sys$bnf_chemical_code, 1, 4) %in% c("0501", "0502", "0504")))
  j <- sys[!is.na(sys$atc) & grepl("^J", sys$atc_all), ]
  expect_true(all(startsWith(j$atc, "J")))
})

test_that("known mappings are correct (spot checks against BNF and WHO ATC)", {
  key <- c("0501013B0" = "AMX", "0501013K0" = "AMC", "0501130R0" = "NIT", "0501080W0" = "TMP",
           "0501080D0" = "SXT", "0501030I0" = "DOX", "0501120L0" = "CIP", "0501070I0" = "COL",
           "0501021H0" = "CAZ", "0501090H0" = "ETH", "0501070U0" = "VAN", "0501011P0" = "PHN")
  got <- cw$ab[match(names(key), cw$bnf_chemical_code)]
  expect_equal(got, unname(key))
  expect_equal(cw$atc[cw$bnf_chemical_code == "0501013K0"], "J01CR02")
  expect_equal(cw$atc[cw$bnf_chemical_code == "0501130R0"], "J01XE01")
})

test_that("no salt-word false positives survive (regression)", {
  bad <- cw[cw$ab %in% c("SDA", "CLA") | grepl("^(Sodium|Calcium) (citrate|bicarbonate|valproate)", cw$bnf_name), ]
  expect_equal(nrow(bad), 0L)
})

test_that("every antibacterial in BNF 5.1 except the combination products is covered", {
  # BNF 5.1 chemicals in the EPD months used for the build, minus "Rifampicin combined preparations"
  expect_equal(sum(startsWith(cw$bnf_chemical_code, "0501")), 68L)
  expect_false("0501090S0" %in% cw$bnf_chemical_code)
})

test_that("op_example is a complete, plausible monthly series", {
  ex <- op_example
  months <- seq(min(ex$date), max(ex$date), by = "month")
  expect_equal(sort(unique(ex$date)), months)
  expect_true(all(format(ex$date, "%d") == "01"))
  expect_false(anyDuplicated(ex[, c("ab", "date")]) > 0)
  expect_true(all(ex$items > 0) && all(ex$actual_cost >= 0))
  # every code in op_example is a crosswalk chemical
  codes <- unique(unlist(strsplit(ex$code, "+", fixed = TRUE)))
  expect_true(all(codes %in% cw$bnf_chemical_code))
  # national antibacterial items per month are in the low millions
  tot <- tapply(ex$items, ex$date, sum)
  expect_true(all(tot > 1.5e6 & tot < 5e6))
  # winter peak: December 2022 (Strep A) is the largest amoxicillin month
  amx <- ex[ex$ab == "AMX", ]
  expect_equal(format(amx$date[which.max(amx$items)], "%Y-%m"), "2022-12")
})

test_that("op_example has the same columns as op_spending_ab output", {
  expect_equal(names(op_example), c("date", "org_type", "org_id", "org_name", "ab", "ab_name", "atc", "code",
                                    "items", "quantity", "actual_cost"))
})
