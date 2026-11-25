test_that("the bundled crosswalk is well formed", {
  cw <- antibiotic_crosswalk
  expect_s3_class(cw, "data.frame")
  expect_true(all(c("bnf_chemical_code", "bnf_name", "ab", "ab_name", "atc") %in% names(cw)))
  expect_false(anyDuplicated(cw$bnf_chemical_code) > 0)
  expect_true(all(nchar(cw$bnf_chemical_code) == 9L))
  expect_false(anyNA(cw$ab))
  expect_true(all(cw$bnf_section == substr(cw$bnf_chemical_code, 1, 4)))
})

test_that("crosswalk AMR codes exist in the installed AMR package", {
  skip_if_not_installed("AMR")
  expect_true(all(antibiotic_crosswalk$ab %in% as.character(AMR::antimicrobials$ab)))
})

test_that("ab_to_bnf resolves AMR codes, names and ATC codes without the AMR package", {
  r <- ab_to_bnf(c("AMX", "amoxicillin", "J01CA04", "Co-amoxiclav"), use_amr = FALSE)
  expect_equal(unique(r$ab[r$input == "AMX"]), "AMX")
  expect_setequal(r$bnf_chemical_code[r$input == "amoxicillin"], c("0501013B0", "0501013C0"))
  expect_setequal(r$bnf_chemical_code[r$input == "J01CA04"], c("0501013B0", "0501013C0"))
  expect_equal(r$bnf_chemical_code[r$input == "Co-amoxiclav"], "0501013K0")
  expect_true(all(r$via == "bundled table"))
})

test_that("ATC prefixes and AMR group names select whole classes", {
  expect_setequal(ab_to_bnf("J01MA", output = "codes"),
                  c("0501120L0", "0501120P0", "0501120Q0", "0501120X0", "0501120Y0"))
  expect_true(all(c("0501040H0", "0501040U0") %in% ab_to_bnf("Aminoglycosides", output = "codes")))
})

test_that("scope controls topical and ophthalmic products", {
  sys <- ab_to_bnf("chloramphenicol", output = "codes", use_amr = FALSE)
  all <- ab_to_bnf("chloramphenicol", scope = "all", output = "codes", use_amr = FALSE)
  expect_equal(sys, "0501070F0")
  expect_gt(length(all), 1L)
  expect_true(any(!startsWith(all, "05")))
})

test_that("unresolvable and unmapped inputs warn and are kept as NA rows", {
  expect_warning(r <- ab_to_bnf("zzzzqq", use_amr = FALSE), "Could not resolve")
  expect_true(is.na(r$bnf_chemical_code))
  skip_if_not_installed("AMR")
  expect_warning(r2 <- ab_to_bnf("amikacin"), "no BNF chemical")
  expect_true(is.na(r2$bnf_chemical_code))
  expect_equal(r2$ab, "AMK")
})

test_that("AMR::as.ab resolves brand names and the via column says so", {
  skip_if_not_installed("AMR")
  r <- ab_to_bnf("Amoxil")
  expect_true(all(r$via == "AMR::as.ab"))
  expect_true("0501013B0" %in% r$bnf_chemical_code)
})

test_that("bnf_to_ab truncates long codes and expands prefixes", {
  r <- bnf_to_ab(c("0501013B0", "0501013B0AAAAAA"))
  expect_equal(r$ab, c("AMX", "AMX"))
  expect_setequal(bnf_to_ab("050112", output = "ab"), c("CIP", "OFX", "NOR", "LVX", "MFX"))
  expect_warning(x <- bnf_to_ab("99ZZ"), "Not in the crosswalk")
  expect_true(is.na(x$ab))
})

test_that("round trip: every systemic chemical maps to its agent and back", {
  cw <- antibiotic_crosswalk[antibiotic_crosswalk$bnf_chapter == "05", ]
  for (i in seq(1, nrow(cw), by = 7)) {
    ab <- bnf_to_ab(cw$bnf_chemical_code[i], output = "ab")
    back <- ab_to_bnf(ab, output = "codes", use_amr = FALSE)
    expect_true(cw$bnf_chemical_code[i] %in% back)
  }
})

test_that("atc_to_bnf and bnf_to_atc agree", {
  expect_true("0501130R0" %in% atc_to_bnf("J01XE01", output = "codes"))
  a <- bnf_to_atc(c("0501013B0", "0501130R0"))
  expect_equal(unname(a), c("J01CA04", "J01XE01"))
  expect_equal(names(a), c("0501013B0", "0501130R0"))
})

test_that("op_antibiotics filters by section and group", {
  q <- op_antibiotics(section = "050112")
  expect_true(all(startsWith(q$bnf_chemical_code, "050112")))
  expect_true(all(q$bnf_class == "Quinolones"))
  expect_setequal(op_antibiotics(ab_group = "Carbapenems")$ab, c("MEM", "ETP"))
})

test_that("input validation", {
  expect_error(ab_to_bnf(1), "character vector")
  expect_error(bnf_to_ab(character()), "non-empty")
})
