test_that("bnf_level identifies hierarchy levels", {
  expect_equal(bnf_level(c("05", "0501", "050101", "0501013", "0501013B0", "0501013B0AA", "0501013B0AAAAAA")),
               c("chapter", "section", "paragraph", "subparagraph", "chemical", "product", "presentation"))
  expect_true(is.na(bnf_level("050")))
})

test_that("bnf_parent truncates and returns NA when too short", {
  expect_equal(bnf_parent("0501013K0", "paragraph"), "050101")
  expect_equal(bnf_parent("0501013K0AAAAAA", "chemical"), "0501013K0")
  expect_true(is.na(bnf_parent("0501", "chemical")))
})

test_that("bnf_class gives antibacterial class labels", {
  expect_equal(bnf_class(c("0501013B0", "0501120L0", "0501130R0")),
               c("Penicillins", "Quinolones", "Urinary-tract infections"))
  expect_equal(bnf_class("0501013B0", at = "section"), "Antibacterial drugs")
})
