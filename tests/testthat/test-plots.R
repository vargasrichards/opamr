ex <- op_example[op_example$ab_name %in% c("Amoxicillin", "Nitrofurantoin", "Doxycycline", "Trimethoprim",
                                           "Amoxicillin/clavulanic acid", "Flucloxacillin"), ]

# text of all geom_text layers after building the plot
built_text <- function(p) {
  b <- ggplot2::ggplot_build(p)
  unlist(lapply(b$data, function(d) if ("label" %in% names(d)) as.character(d$label)))
}
n_layers_of <- function(p, geom) sum(vapply(p$layers, function(l) inherits(l$geom, geom), logical(1)))

test_that("example data are complete and plausible", {
  expect_equal(length(unique(op_example$date)), 68L)
  expect_false(anyDuplicated(op_example[, c("ab", "date")]) > 0)
  expect_true(all(op_example$items[op_example$ab == "AMX"] > 2e5))
})

test_that("op_palette is the colour-blind safe Okabe-Ito set", {
  expect_length(op_palette(), 8L)
  expect_equal(op_palette(2), c("#0072B2", "#D55E00"))
  expect_warning(op_palette(9), "recycled")
})

test_that("op_plot_trend builds cleanly and labels every coloured series once", {
  p <- op_plot_trend(ex, y = "items")
  expect_s3_class(p, "ggplot")
  expect_no_warning(ggplot2::ggplot_build(p))
  expect_setequal(gsub("/\n", "/", built_text(p), fixed = TRUE), unique(ex$ab_name))
  # no legend, as direct labels identify the series
  expect_equal(p$theme$legend.position, "none")
})

test_that("op_plot_trend draws one connected line per series (regression: merged lines)", {
  p <- op_plot_trend(ex, y = "items")
  b <- ggplot2::ggplot_build(p)
  line_data <- b$data[[which(vapply(p$layers, function(l) inherits(l$geom, "GeomLine"), logical(1)))[1]]]
  expect_equal(length(unique(line_data$group)), length(unique(ex$ab_name)))
  expect_equal(length(unique(line_data$colour)), length(unique(ex$ab_name)))
})

test_that("highlight greys out the rest and keeps labels to highlighted groups", {
  p <- op_plot_trend(op_example, y = "items", highlight = c("Amoxicillin", "Nitrofurantoin"), log = TRUE)
  expect_setequal(built_text(p), c("Amoxicillin", "Nitrofurantoin"))
  expect_no_warning(ggplot2::ggplot_build(p))
  # without highlight, at most max_groups series are coloured
  p2 <- op_plot_trend(op_example, y = "items", max_groups = 5)
  expect_length(built_text(p2), 5L)
})

test_that("facet without group gives single-colour panels and no direct labels", {
  p <- op_plot_trend(ex, y = "items", facet = "ab_name")
  expect_length(built_text(p), 0L)
  b <- ggplot2::ggplot_build(p)
  expect_equal(length(unique(b$data[[1]]$colour)), 1L)
  expect_equal(length(unique(b$layout$layout$PANEL)), length(unique(ex$ab_name)))
})

test_that("labels stay inside the y range (regression: labels pushed below zero)", {
  p <- op_plot_trend(ex, y = "items")
  b <- ggplot2::ggplot_build(p)
  lab_layer <- b$data[[length(b$data)]]
  expect_true(all(lab_layer$y >= 0))
  expect_no_warning(ggplot2::ggplot_build(p))
  expect_equal(nrow(lab_layer), length(unique(ex$ab_name)))
})

test_that("spread_labels separates, preserves order, and respects bounds", {
  y <- c(10, 10.2, 10.4, 50)
  s <- spread_labels(y, 2, lower = 0, upper = 60)
  expect_true(all(diff(sort(s)) >= 2 - 1e-9))
  expect_equal(order(s), order(y))
  s2 <- spread_labels(c(0.1, 0.2, 0.3), 5, lower = 0, upper = 100)
  expect_true(min(s2) >= 0)
  s3 <- spread_labels(c(99, 99.5, 100), 5, lower = 0, upper = 100)
  expect_true(max(s3) <= 100)
})

test_that("axis breaks stay inside the data range (regression: empty future years)", {
  p <- op_plot_trend(ex, y = "items")
  b <- ggplot2::ggplot_build(p)
  brk <- b$layout$panel_params[[1]]$x$get_breaks()
  brk <- as.Date(brk[!is.na(brk)], origin = "1970-01-01")
  expect_true(all(brk <= max(ex$date)))
})

test_that("rate plots take their axis label from the rate definition", {
  x <- ex[ex$ab == "AMX", ]
  x$total_list_size <- 6e7
  r <- op_rate(x, x[, c("date", "org_id", "total_list_size")])
  p <- op_plot_trend(r, y = "rate")
  expect_match(gsub("\\s+", " ", p$labels$y), "Items per 1,000 registered patients")
})

test_that("events are drawn as a vertical line with a label", {
  p <- op_plot_trend(ex, y = "items", events = data.frame(date = "2022-12-01", label = "Strep A surge"))
  expect_equal(n_layers_of(p, "GeomVline"), 1L)
  expect_true("Strep A surge" %in% built_text(p))
})

test_that("op_plot_trend validates input", {
  expect_error(op_plot_trend(ex, y = "nope"), "not found")
  expect_error(op_plot_trend(ex[0, ]), "non-empty")
  expect_error(op_plot_trend(ex, highlight = "zzz"), "matches no group")
})

test_that("op_plot_seasonal builds, labels years, and rejects duplicated series", {
  one <- ex[ex$ab == "AMX", ]
  p <- op_plot_seasonal(one, y = "items", years = 2022:2025)
  expect_no_warning(ggplot2::ggplot_build(p))
  expect_setequal(built_text(p), as.character(2022:2025))
  dup <- rbind(one, one)
  expect_error(op_plot_seasonal(dup, y = "items"), "More than one value")
  p2 <- op_plot_seasonal(ex, y = "items", years = 2022:2025)
  expect_equal(length(unique(ggplot2::ggplot_build(p2)$layout$layout$PANEL)), length(unique(ex$ab)))
})

test_that("op_plot_distribution draws bands, median and labelled highlights", {
  set.seed(42)
  sim <- expand.grid(date = seq(as.Date("2024-01-01"), by = "month", length.out = 12), org_id = as.character(1:30),
                     stringsAsFactors = FALSE)
  sim$rate <- stats::rnorm(nrow(sim), 50, 5)
  p <- op_plot_distribution(sim, y = "rate", highlight = "3")
  expect_no_warning(ggplot2::ggplot_build(p))
  expect_equal(n_layers_of(p, "GeomRibbon"), 2L)
  txt <- built_text(p)
  expect_true("Median" %in% txt); expect_true("3" %in% txt)
  expect_error(op_plot_distribution(sim, y = "rate", min_orgs = 100), "at least 100")
  expect_error(op_plot_distribution(sim, y = "rate", highlight = "999"), "matches no organisation")
})

test_that("op_plot_heatmap centres the diverging scale at the row median", {
  p <- op_plot_heatmap(ex, y = "items")
  expect_no_warning(ggplot2::ggplot_build(p))
  fill_scale <- p$scales$get_scales("fill")
  lim <- fill_scale$get_limits()
  expect_equal(lim[1], -lim[2])
  b <- ggplot2::ggplot_build(p)
  med_ratio <- tapply(b$plot$data$.fill, b$plot$data$.r, stats::median)
  expect_true(all(abs(med_ratio) < 0.05))           # log2(median/median) is about 0 for every row
  p2 <- op_plot_heatmap(ex, y = "items", scale = "none")
  expect_no_warning(ggplot2::ggplot_build(p2))
})

test_that("op_save writes files at journal widths", {
  p <- op_plot_trend(ex, y = "items")
  f <- tempfile(fileext = ".png")
  expect_equal(op_save(p, f, "single"), f)
  expect_gt(file.size(f), 5000)
  f2 <- tempfile(fileext = ".pdf")
  op_save(p, f2, "double", height = 70)
  expect_gt(file.size(f2), 2000)
  expect_error(op_save("not a plot", f), "ggplot")
})

test_that("theme_op sets the three-step type scale", {
  th <- theme_op(8)
  expect_equal(th$axis.title$size, 8)
  expect_equal(th$legend.text$size, 7)
  expect_equal(th$axis.text$size, 6)
})

test_that("a single agent whose BNF code label changes is one series (regression)", {
  amx <- op_example[op_example$ab == "AMX", ]
  expect_gt(length(unique(amx$code)), 1L)              # the data really do have two code labels
  p <- op_plot_trend(amx, y = "items")
  b <- ggplot2::ggplot_build(p)
  expect_equal(length(unique(b$data[[1]]$group)), 1L)
  expect_length(built_text(p), 0L)                     # no direct label for a single series
})

test_that("long y-axis titles are wrapped to fit a single column (regression)", {
  p <- op_plot_trend(op_example[op_example$ab == "AMX", ], y = "items",
                     ylab = "Items per 1,000 registered patients per month (simulated)")
  expect_match(p$labels$y, "\n", fixed = TRUE)
  expect_true(all(nchar(strsplit(p$labels$y, "\n", fixed = TRUE)[[1]]) <= 36))
})

test_that("a partial final year is labelled at its own line end, not spread with December (regression)", {
  tmp <- op_example[op_example$ab == "TMP", ]
  p <- op_plot_seasonal(tmp, y = "items", years = 2024:2026)
  b <- ggplot2::ggplot_build(p)
  lab <- b$data[[length(b$data)]]
  y26 <- lab$y[lab$label == "2026"]
  last26 <- tmp$items[tmp$date == max(tmp$date)]
  expect_equal(y26, last26)                            # sole label at its x position: not moved
  expect_equal(lab$x[lab$label == "2026"], as.integer(format(max(tmp$date), "%m")) + 0.15)   # label nudge
})

test_that("the source caption is wrapped and can be replaced or removed", {
  p <- op_plot_trend(ex, y = "items")
  expect_match(gsub("\\s+", " ", p$labels$caption), "Open Government Licence v3.0", fixed = TRUE)
  expect_true(all(nchar(strsplit(p$labels$caption, "\n", fixed = TRUE)[[1]]) <= 80))
  expect_null(op_plot_trend(ex, y = "items", source = FALSE)$labels$caption)
  expect_equal(op_plot_trend(ex, y = "items", source = "My source")$labels$caption, "My source")
})
