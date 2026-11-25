# Visual regression tests (vdiffr). Snapshots live in tests/testthat/_snaps/plots-snapshots/.
# vdiffr skips these on CRAN; if a deliberate design change alters a figure, review the SVG diff with
# testthat::snapshot_review() and accept it.
skip_if_not_installed("vdiffr")

ex6 <- op_example[op_example$ab_name %in% c("Amoxicillin", "Doxycycline", "Nitrofurantoin",
                                            "Flucloxacillin", "Trimethoprim", "Amoxicillin/clavulanic acid"), ]

test_that("trend figure is stable", {
  vdiffr::expect_doppelganger("trend-six-agents", op_plot_trend(ex6, y = "items", source = FALSE))
  vdiffr::expect_doppelganger("trend-log-highlight",
    op_plot_trend(op_example, y = "items", log = TRUE, highlight = c("Amoxicillin", "Cefalexin"), source = FALSE))
  vdiffr::expect_doppelganger("trend-facets", op_plot_trend(ex6, y = "items", facet = "ab_name", source = FALSE))
})

test_that("seasonal figure is stable", {
  vdiffr::expect_doppelganger("seasonal-two-agents",
    op_plot_seasonal(ex6[ex6$ab %in% c("AMX", "NIT"), ], y = "items", years = 2022:2026, source = FALSE))
})

test_that("heatmap figure is stable", {
  vdiffr::expect_doppelganger("heatmap-ratio", op_plot_heatmap(ex6, y = "items", source = FALSE))
})

test_that("distribution figure is stable", {
  set.seed(7)
  sim <- expand.grid(date = seq(as.Date("2024-01-01"), by = "month", length.out = 18),
                     org_id = sprintf("S%02d", 1:25), stringsAsFactors = FALSE)
  sim$rate <- 40 + 5 * sin(as.integer(format(sim$date, "%m"))) + stats::rnorm(nrow(sim), 0, 3)
  vdiffr::expect_doppelganger("distribution", op_plot_distribution(sim, y = "rate", highlight = "S03", source = FALSE))
})
