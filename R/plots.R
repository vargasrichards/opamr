# Publication-quality figures -------------------------------------------------------------
#
# Design rules followed throughout: colour-blind safe palette (Okabe-Ito), at most three font
# sizes (labels `base_size`, annotations `base_size - 1`, ticks `base_size - 2`), series
# identified by direct labels instead of legends, no chart junk, one source caption.

#' Colour-blind safe palette
#'
#' The Okabe-Ito palette (Okabe & Ito 2008), ordered so that the first colours are the
#' most distinguishable, with yellow last because it is hard to read on white.
#'
#' @param n Number of colours (recycled with a warning above 8). `NULL` returns all 8.
#' @return A character vector of hex colours.
#' @examples
#' op_palette(3)
#' @export
op_palette <- function(n = NULL) {
  pal <- c(blue = "#0072B2", vermillion = "#D55E00", green = "#009E73", purple = "#CC79A7",
           orange = "#E69F00", sky = "#56B4E9", grey = "#555555", yellow = "#F0E442")
  if (is.null(n)) return(pal)
  if (n > length(pal)) {
    rlang::warn("More than 8 groups: colours are recycled. Use `highlight` or `max_groups` to focus the figure.")
    return(rep_len(unname(pal), n))
  }
  unname(pal[seq_len(n)])
}

#' Colour-blind safe discrete ggplot2 scales
#'
#' @param ... Passed to [ggplot2::discrete_scale()].
#' @return A ggplot2 scale.
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) + geom_point() + scale_colour_op()
#' @export
scale_colour_op <- function(...) {
  ggplot2::discrete_scale("colour", palette = function(n) op_palette(n), ...)
}

#' @rdname scale_colour_op
#' @export
scale_fill_op <- function(...) {
  ggplot2::discrete_scale("fill", palette = function(n) op_palette(n), ...)
}

#' A clean, journal-ready ggplot2 theme
#'
#' Axis lines only on the left and bottom, faint horizontal grid, left-aligned plain titles,
#' and a three-step type scale: axis titles and panel titles at `base_size`, legends and
#' annotations at `base_size - 1`, tick labels at `base_size - 2`. The defaults (8/7/6 pt) suit
#' single- and double-column journal figures.
#'
#' @param base_size Base font size in points (default 8).
#' @param base_family Font family (default: device default sans-serif).
#' @return A [ggplot2::theme()].
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_op()
#' @export
theme_op <- function(base_size = 8, base_family = "") {
  grey_txt <- "grey15"
  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = grey_txt),
      axis.line = ggplot2::element_line(linewidth = 0.3, colour = "grey25"),
      axis.ticks = ggplot2::element_line(linewidth = 0.3, colour = "grey25"),
      axis.ticks.length = ggplot2::unit(1.5, "mm"),
      axis.title = ggplot2::element_text(size = base_size),
      axis.text = ggplot2::element_text(size = base_size - 2, colour = "grey25"),
      panel.grid.major.y = ggplot2::element_line(colour = "grey92", linewidth = 0.25),
      panel.grid.major.x = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(size = base_size, face = "plain", hjust = 0),
      plot.subtitle = ggplot2::element_text(size = base_size - 1, hjust = 0, colour = "grey30"),
      plot.title.position = "plot",
      plot.caption = ggplot2::element_text(size = base_size - 2, colour = "grey35", hjust = 0, margin = ggplot2::margin(t = 4)),
      plot.caption.position = "plot",
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(size = base_size, face = "plain", hjust = 0),
      panel.spacing = ggplot2::unit(4, "mm"),
      legend.position = "right",
      legend.title = ggplot2::element_text(size = base_size - 1),
      legend.text = ggplot2::element_text(size = base_size - 1),
      legend.key.size = ggplot2::unit(3, "mm"),
      plot.margin = ggplot2::margin(4, 4, 4, 4)
    )
}

# Helpers --------------------------------------------------------------------------------

#' @noRd
op_source_caption <- function(width = 80) {
  txt <- paste0("Source: NHS Business Services Authority via OpenPrescribing (Open Government Licence v3.0). ",
                "Items dispensed in the community on prescriptions issued in English primary care.")
  paste(strwrap(txt, width = width), collapse = "\n")
}

# January-1st breaks restricted to the range of the data (no empty years from axis expansion)
#' @noRd
year_breaks <- function(dates) {
  lo <- min(dates, na.rm = TRUE); hi <- max(dates, na.rm = TRUE)
  function(limits) {
    b <- seq(as.Date(format(lo, "%Y-01-01")), hi, by = "year")
    b[b >= lo - 15]
  }
}

# Wrap direct labels at slashes and spaces so they need little horizontal room.
#' @noRd
wrap_label <- function(x, width = 16L) {
  vapply(x, function(s) paste(strwrap(gsub("/", "/ ", s, fixed = TRUE), width = width), collapse = "\n"), "",
         USE.NAMES = FALSE)
}

#' @noRd
n_lines <- function(x) 1L + lengths(regmatches(x, gregexpr("\n", x, fixed = TRUE)))

# Right-hand plot margin (pt) needed for direct labels of the given font size.
#' @noRd
label_margin_pt <- function(labels, size) {
  longest <- max(nchar(unlist(strsplit(labels, "\n", fixed = TRUE))))
  longest * 0.55 * size + 6
}

#' @noRd
guess_y <- function(data, y) {
  if (!is.null(y)) {
    if (!y %in% names(data)) rlang::abort(sprintf("Column '%s' not found in `data`.", y), class = "opamr_error")
    return(y)
  }
  for (cand in c("rate", "items")) if (cand %in% names(data)) return(cand)
  rlang::abort("Could not guess `y`; supply the column to plot.", class = "opamr_error")
}

#' @noRd
guess_group <- function(data, group) {
  if (!is.null(group)) {
    if (!group %in% names(data)) rlang::abort(sprintf("Column '%s' not found in `data`.", group), class = "opamr_error")
    return(group)
  }
  # one antimicrobial -> single series, even if its BNF `code` label changes over time
  # (e.g. "0501013B0" in some months and "0501013B0+0501013C0" in others)
  if ("ab_name" %in% names(data)) return(if (length(unique(data$ab_name)) > 1L) "ab_name" else NULL)
  if ("code" %in% names(data) && length(unique(data$code)) > 1L) return("code")
  NULL
}

#' @noRd
y_axis_label <- function(y, data) {
  if (y == "rate" && !is.null(attr(data, "rate_label"))) {
    lab <- attr(data, "rate_label")
    return(paste0(toupper(substr(lab, 1, 1)), substr(lab, 2, nchar(lab)), ", monthly"))
  }
  switch(y,
         items = "Prescription items per month",
         quantity = "Quantity dispensed per month",
         actual_cost = "Actual cost per month (\u00a3)",
         rate = "Rate per month",
         y)
}

#' @noRd
y_axis_labels <- function(y) {
  if (y == "actual_cost") scales::label_currency(prefix = "\u00a3", scale_cut = scales::cut_short_scale())
  else if (y == "rate") scales::label_number(big.mark = ",")
  else scales::label_number(scale_cut = scales::cut_short_scale())
}

# Separate label positions (in plotting units) so neighbouring labels do not overlap.
#' @noRd
spread_labels <- function(y, min_gap, lower = -Inf, upper = Inf) {
  if (length(y) < 2L) return(pmin(pmax(y, lower), upper))
  o <- order(y); ys <- y[o]; adj <- ys
  for (i in seq_along(ys)[-1]) adj[i] <- max(ys[i], adj[i - 1L] + min_gap)
  adj <- adj + mean(ys - adj)                      # re-centre so labels move as little as possible
  n <- length(adj)
  if (is.finite(lower) && adj[1] < lower) adj <- adj + (lower - adj[1])   # keep inside the panel
  if (is.finite(upper) && adj[n] > upper) {
    adj <- adj - (adj[n] - upper)
    if (is.finite(lower) && adj[1] < lower) adj <- seq(lower, upper, length.out = n)
  }
  out <- numeric(length(y)); out[o] <- adj; out
}

#' @noRd
prep_dates <- function(data, date) {
  if (!date %in% names(data)) rlang::abort(sprintf("Column '%s' not found in `data`.", date), class = "opamr_error")
  as.Date(data[[date]])
}

#' @noRd
check_df <- function(data) {
  if (!is.data.frame(data) || !nrow(data)) rlang::abort("`data` must be a non-empty data frame.", class = "opamr_error")
}

#' @noRd
apply_labels <- function(p, title, subtitle, ylab, source, xlab = NULL) {
  caption <- if (isTRUE(source)) op_source_caption() else if (is.character(source)) paste(strwrap(source, 80), collapse = "\n") else NULL
  wrap <- function(z, w) if (is.null(z)) NULL else paste(strwrap(z, w), collapse = "\n")
  # long axis titles are wrapped so they fit a single-column (85 mm) figure
  p + ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = wrap(ylab, 36), caption = caption)
}

# Time series ------------------------------------------------------------------------------

#' Publication-quality prescribing time series
#'
#' Draws one line per antimicrobial (or other group) with direct labels at the right-hand
#' end instead of a legend. Output of [op_spending()], [op_spending_ab()] or
#' [op_antibiotic_use()] can be passed directly.
#'
#' @param data Data frame with a date column and a numeric column to plot.
#' @param y Column to plot. Default `"rate"` if present, otherwise `"items"`.
#' @param group Column that defines the lines. If `NULL` (default) it is `"ab_name"` or
#'   `"code"` when present with more than one value, otherwise a single series is drawn.
#' @param facet Optional column to split into small multiples (free y-axes by default). If
#'   `facet` is given and `group` is `NULL`, each panel shows one line in a single colour with no
#'   direct label (the panel title names the series).
#' @param date Date column (default `"date"`).
#' @param highlight Groups to colour; all others are drawn in light grey without labels.
#'   If `NULL` and there are more than `max_groups` groups, the `max_groups` groups with
#'   the highest final value are highlighted.
#' @param max_groups Maximum number of coloured groups when `highlight` is `NULL` (default
#'   8, the size of the colour-blind safe palette).
#' @param label Draw direct labels (default `TRUE`).
#' @param log Use a log10 y-axis (default `FALSE`). Lines only; never bars.
#' @param zero Start a linear y-axis at zero (default `TRUE`).
#' @param events Optional data frame with columns `date` and `label` to mark events with a
#'   dashed vertical line and a label.
#' @param facet_scales Scales for facets: `"free_y"` (default) or `"fixed"`.
#' @param ylab,title,subtitle Text. `title` should state the finding in a sentence; it is
#'   `NULL` by default (put the message in the figure caption of your paper).
#' @param source Add the data-source caption (default `TRUE`); or a custom character string.
#' @param base_size Base font size (default 8 pt, see [theme_op()]).
#' @return A [ggplot2::ggplot()] object.
#' @examples
#' ex <- op_example[op_example$ab_name %in%
#'   c("Amoxicillin", "Doxycycline", "Nitrofurantoin", "Amoxicillin/clavulanic acid"), ]
#' op_plot_trend(ex, y = "items")
#' op_plot_trend(ex, y = "items", highlight = "Nitrofurantoin", log = TRUE)
#' @export
op_plot_trend <- function(data, y = NULL, group = NULL, facet = NULL, date = "date", highlight = NULL,
                          max_groups = 8L, label = TRUE, log = FALSE, zero = TRUE, events = NULL,
                          facet_scales = c("free_y", "fixed"), ylab = NULL, title = NULL, subtitle = NULL,
                          source = TRUE, base_size = 8) {
  check_df(data); facet_scales <- match.arg(facet_scales)
  y <- guess_y(data, y)
  # `facet` given without `group`: one line per panel, single colour, panel titles name the series
  single <- !is.null(facet) && is.null(group)
  group <- if (single) facet else guess_group(data, group)
  df <- data
  df$.date <- prep_dates(df, date); df$.y <- as.numeric(df[[y]])
  df <- df[is.finite(df$.y) & (!log | df$.y > 0), , drop = FALSE]
  if (!nrow(df)) rlang::abort("No finite values to plot.", class = "opamr_error")
  df$.g <- if (is.null(group)) "series" else as.character(df[[group]])
  if (!is.null(facet)) df$.f <- as.character(df[[facet]])

  # order groups by their final value, then decide which are coloured
  last_val <- vapply(split(df, df$.g), function(d) d$.y[which.max(d$.date)], numeric(1))
  ord <- names(sort(last_val, decreasing = TRUE))
  if (is.null(highlight)) highlight <- if (!single && length(ord) > max_groups) ord[seq_len(max_groups)] else ord
  highlight <- intersect(highlight, ord)
  if (!length(highlight)) rlang::abort("`highlight` matches no group.", class = "opamr_error")
  df$.hl <- df$.g %in% highlight
  df$.g <- factor(df$.g, levels = unique(c(highlight, ord)))
  fg <- df[df$.hl, , drop = FALSE]; bg <- df[!df$.hl, , drop = FALSE]
  fg$.g <- factor(as.character(fg$.g), levels = highlight)

  p <- ggplot2::ggplot()
  if (!is.null(events)) {
    ev <- events; ev$date <- as.Date(ev$date)
    p <- p + ggplot2::geom_vline(data = ev, ggplot2::aes(xintercept = .data$date), linetype = "22",
                                 linewidth = 0.3, colour = "grey45") +
      ggplot2::geom_text(data = ev, ggplot2::aes(x = .data$date, y = Inf, label = .data$label), hjust = -0.05,
                         vjust = 1.4, size = (base_size - 1) / ggplot2::.pt, colour = "grey30", inherit.aes = FALSE)
  }
  if (nrow(bg)) {
    bg$.key <- paste(bg$.g, if (is.null(facet)) "" else bg$.f)
    p <- p + ggplot2::geom_line(data = bg, ggplot2::aes(.data$.date, .data$.y, group = .data$.key),
                                colour = "grey78", linewidth = 0.3)
  }
  if (is.null(group)) {
    p <- p + ggplot2::geom_line(data = fg, ggplot2::aes(.data$.date, .data$.y), colour = op_palette(1), linewidth = 0.6)
  } else if (single) {
    p <- p + ggplot2::geom_line(data = fg, ggplot2::aes(.data$.date, .data$.y, group = .data$.g),
                                colour = op_palette(1), linewidth = 0.6)
  } else {
    p <- p + ggplot2::geom_line(data = fg, ggplot2::aes(.data$.date, .data$.y, colour = .data$.g, group = .data$.g),
                                linewidth = 0.6)
  }

  right_pt <- 4
  if (label && !is.null(group) && !single) {
    keys <- c(".g", if (!is.null(facet)) ".f")
    lab <- do.call(rbind, lapply(split(fg, fg[keys], drop = TRUE), function(d) d[which.max(d$.date), , drop = FALSE]))
    lab$.lab <- wrap_label(as.character(lab$.g)); lab$.ly <- lab$.y
    sc <- if (log) log10 else identity; inv <- if (log) function(z) 10^z else identity
    split_by <- if (is.null(facet)) rep(1, nrow(lab)) else lab$.f
    gap_frac <- (if (is.null(facet)) 0.075 else 0.11) * max(n_lines(lab$.lab))
    for (s_ in unique(split_by)) {
      i <- split_by == s_
      vals <- sc(df$.y[if (is.null(facet)) TRUE else df$.f == s_])
      rng <- if (!log && zero) c(0, max(vals)) else range(vals)
      lab$.ly[i] <- inv(spread_labels(sc(lab$.y[i]), gap_frac * diff(rng),
                                      lower = rng[1] + 0.03 * diff(rng), upper = rng[2]))
    }
    p <- p + ggplot2::geom_text(data = lab, ggplot2::aes(x = .data$.date, y = .data$.ly, label = .data$.lab, colour = .data$.g),
                                hjust = 0, nudge_x = 10, lineheight = 0.85, size = (base_size - 1) / ggplot2::.pt, show.legend = FALSE) +
      ggplot2::coord_cartesian(clip = "off")
    right_pt <- label_margin_pt(lab$.lab, base_size - 1)
  }
  xexp <- ggplot2::expansion(mult = c(0.01, 0.02))

  p <- p + ggplot2::scale_x_date(breaks = year_breaks(df$.date), date_labels = "%Y", expand = xexp) +
    scale_colour_op(guide = "none")
  p <- p + if (log) ggplot2::scale_y_log10(labels = y_axis_labels(y))
  else ggplot2::scale_y_continuous(labels = y_axis_labels(y), limits = if (zero) c(0, NA) else c(NA, NA),
                                   expand = ggplot2::expansion(mult = c(0, 0.06)))
  if (!is.null(facet)) p <- p + ggplot2::facet_wrap(ggplot2::vars(.data$.f), scales = facet_scales)
  p <- apply_labels(p, title, subtitle, ylab %||% y_axis_label(y, data), source, xlab = NULL)
  p + theme_op(base_size) + ggplot2::theme(legend.position = "none", plot.margin = ggplot2::margin(4, right_pt, 4, 4, "pt"))
}

# Seasonality -----------------------------------------------------------------------------

#' Seasonal profile: one line per year
#'
#' Plots month of the year on the x-axis and one line per calendar year, with earlier years in
#' graduated grey and the most recent year in colour, so seasonality (for example the winter
#' peak in antibiotic prescribing) and year-to-year change are visible together.
#'
#' @inheritParams op_plot_trend
#' @param facet Column to split into small multiples, usually the antimicrobial
#'   (`"ab_name"`, used automatically if present with several values). The data must hold one
#'   series per facet and month; filter to a single organisation first.
#' @param years Optional integer vector of years to show (default: all).
#' @param highlight_year Year drawn in colour (default: the latest year).
#' @param label_years Label lines with the year at their right-hand end (default `TRUE`).
#' @return A [ggplot2::ggplot()] object.
#' @examples
#' ex <- op_example[op_example$ab_name %in% c("Amoxicillin", "Nitrofurantoin"), ]
#' op_plot_seasonal(ex, y = "items", years = 2022:2026)
#' @export
op_plot_seasonal <- function(data, y = NULL, facet = NULL, date = "date", years = NULL, highlight_year = NULL,
                             label_years = TRUE, facet_scales = c("free_y", "fixed"), ylab = NULL, title = NULL,
                             subtitle = NULL, source = TRUE, base_size = 8) {
  check_df(data); facet_scales <- match.arg(facet_scales)
  y <- guess_y(data, y)
  if (is.null(facet)) facet <- guess_group(data, NULL)
  df <- data; df$.date <- prep_dates(df, date); df$.y <- as.numeric(df[[y]])
  df$.f <- if (is.null(facet)) "all" else as.character(df[[facet]])
  df$.year <- as.integer(format(df$.date, "%Y")); df$.month <- as.integer(format(df$.date, "%m"))
  if (!is.null(years)) df <- df[df$.year %in% years, , drop = FALSE]
  df <- df[is.finite(df$.y), , drop = FALSE]
  if (!nrow(df)) rlang::abort("No data left after filtering.", class = "opamr_error")
  if (anyDuplicated(df[, c(".f", ".date")])) {
    rlang::abort("More than one value per facet and month. Filter to one organisation (or aggregate) before plotting.", class = "opamr_error")
  }
  yrs <- sort(unique(df$.year)); hy <- highlight_year %||% max(yrs)
  prev <- setdiff(yrs, hy)
  cols <- stats::setNames(c(scales::seq_gradient_pal("grey82", "grey35")(seq(0, 1, length.out = max(length(prev), 2L)))[seq_along(prev)],
                            op_palette(2)[2]), c(prev, hy))
  df$.yr <- factor(df$.year, levels = c(prev, hy))
  df$.hl <- df$.year == hy

  p <- ggplot2::ggplot(df, ggplot2::aes(.data$.month, .data$.y, group = .data$.yr, colour = .data$.yr)) +
    ggplot2::geom_line(data = df[!df$.hl, ], linewidth = 0.4) +
    ggplot2::geom_line(data = df[df$.hl, ], linewidth = 0.8) +
    ggplot2::scale_colour_manual(values = cols, guide = "none")
  if (label_years) {
    end <- do.call(rbind, lapply(split(df, df[c(".f", ".year")], drop = TRUE), function(d) d[which.max(d$.month), , drop = FALSE]))
    end$.ly <- end$.y
    # spread only labels that share an x position (a partial final year ends earlier than December)
    key <- paste(end$.f, end$.month)
    for (f in unique(key)) {
      i <- key == f; rng <- c(0, max(df$.y[df$.f == end$.f[i][1]]))
      end$.ly[i] <- spread_labels(end$.y[i], 0.075 * diff(rng), lower = 0.03 * rng[2], upper = rng[2])
    }
    p <- p + ggplot2::geom_text(data = end, ggplot2::aes(y = .data$.ly, label = .data$.year), hjust = 0, nudge_x = 0.15,
                                size = (base_size - 1) / ggplot2::.pt, show.legend = FALSE) +
      ggplot2::coord_cartesian(clip = "off")
  }
  p <- p + ggplot2::scale_x_continuous(breaks = 1:12, labels = substr(month.abb, 1, 1),
                                       expand = ggplot2::expansion(mult = c(0.02, if (label_years) 0.1 else 0.02))) +
    ggplot2::scale_y_continuous(labels = y_axis_labels(y), limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, 0.06)))
  if (!is.null(facet)) p <- p + ggplot2::facet_wrap(ggplot2::vars(.data$.f), scales = facet_scales)
  p <- apply_labels(p, title, subtitle, ylab %||% y_axis_label(y, data), source, xlab = "Month")
  p + theme_op(base_size) + ggplot2::theme(legend.position = "none")
}

# Distribution across organisations --------------------------------------------------------

#' Distribution of prescribing across organisations over time
#'
#' Summarises many organisations (practices, Sub-ICB Locations, ...) per month as the median
#' with 25th-75th and 5th-95th percentile bands, and optionally overlays named organisations.
#' Use it with a **rate** (for example from [op_antibiotic_use()]) so organisations of
#' different sizes are comparable.
#'
#' @inheritParams op_plot_trend
#' @param org Column identifying organisations (default `"org_id"`).
#' @param probs Five probabilities for the lower band, inner lower, median, inner upper and
#'   upper band (default `c(.05, .25, .5, .75, .95)`).
#' @param highlight Organisation id(s) drawn as lines on top of the bands and labelled.
#' @param highlight_label Optional column giving display names for highlighted organisations
#'   (default `"org_name"` if present).
#' @param min_orgs Months with fewer organisations than this are dropped (default 10).
#' @return A [ggplot2::ggplot()] object.
#' @examples
#' set.seed(1)  # simulated organisations, for illustration only
#' sim <- expand.grid(date = seq(as.Date("2023-01-01"), by = "month", length.out = 24), org_id = 1:40)
#' sim$rate <- 40 + 8 * sin(2 * pi * as.integer(format(sim$date, "%m")) / 12) + stats::rnorm(nrow(sim), 0, 4) + sim$org_id / 10
#' op_plot_distribution(sim, y = "rate", highlight = 5, source = FALSE)
#' @export
op_plot_distribution <- function(data, y = NULL, org = "org_id", date = "date", probs = c(0.05, 0.25, 0.5, 0.75, 0.95),
                                 highlight = NULL, highlight_label = NULL, log = FALSE, min_orgs = 10L,
                                 ylab = NULL, title = NULL, subtitle = NULL, source = TRUE, base_size = 8) {
  check_df(data); y <- guess_y(data, y)
  if (!org %in% names(data)) rlang::abort(sprintf("Column '%s' not found in `data`.", org), class = "opamr_error")
  if (length(probs) != 5L || is.unsorted(probs)) rlang::abort("`probs` must be five increasing probabilities.", class = "opamr_error")
  df <- data; df$.date <- prep_dates(df, date); df$.y <- as.numeric(df[[y]]); df$.o <- as.character(df[[org]])
  df <- df[is.finite(df$.y) & (!log | df$.y > 0), , drop = FALSE]
  qs <- do.call(rbind, lapply(split(df, df$.date), function(d) {
    if (length(unique(d$.o)) < min_orgs) return(NULL)
    q <- stats::quantile(d$.y, probs, names = FALSE)
    data.frame(.date = d$.date[1], q1 = q[1], q2 = q[2], q3 = q[3], q4 = q[4], q5 = q[5])
  }))
  if (is.null(qs) || !nrow(qs)) rlang::abort(sprintf("No month has at least %d organisations.", min_orgs), class = "opamr_error")
  pct <- function(p) paste0(round(100 * p), "th")
  band_col <- op_palette(1)
  p <- ggplot2::ggplot(qs, ggplot2::aes(x = .data$.date)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .data$q1, ymax = .data$q5), fill = band_col, alpha = 0.16) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .data$q2, ymax = .data$q4), fill = band_col, alpha = 0.30) +
    ggplot2::geom_line(ggplot2::aes(y = .data$q3), colour = band_col, linewidth = 0.7)

  last <- qs[which.max(qs$.date), ]
  band_lab <- data.frame(.date = last$.date, .y = c(last$q5, last$q4, last$q3),
                         .lab = c(paste0(pct(probs[1]), "\u2013", pct(probs[5]), "\npercentile"),
                                  paste0(pct(probs[2]), "\u2013", pct(probs[4]), "\npercentile"), "Median"))
  hl <- NULL
  if (!is.null(highlight)) {
    hl <- df[df$.o %in% as.character(highlight), , drop = FALSE]
    if (!nrow(hl)) rlang::abort("`highlight` matches no organisation.", class = "opamr_error")
    lab_col <- highlight_label %||% (if ("org_name" %in% names(hl)) "org_name")
    hl$.name <- if (!is.null(lab_col)) as.character(hl[[lab_col]]) else hl$.o
    hl$.name <- factor(hl$.name, levels = unique(hl$.name))
    cols <- stats::setNames(op_palette(length(levels(hl$.name)) + 1L)[-1L], levels(hl$.name))
    p <- p + ggplot2::geom_line(data = hl, ggplot2::aes(.data$.date, .data$.y, group = .data$.name, colour = .data$.name),
                                linewidth = 0.6, inherit.aes = FALSE) +
      ggplot2::scale_colour_manual(values = cols, guide = "none")
    hl_last <- do.call(rbind, lapply(split(hl, hl$.name), function(d) d[which.max(d$.date), ]))
    band_lab2 <- data.frame(.date = hl_last$.date, .y = hl_last$.y, .lab = wrap_label(as.character(hl_last$.name)),
                            .col = unname(cols[as.character(hl_last$.name)]))
  }
  all_lab <- band_lab; all_lab$.col <- "grey25"
  if (!is.null(hl)) all_lab <- rbind(all_lab, band_lab2[, names(all_lab)])
  sc <- if (log) log10 else identity; inv <- if (log) function(z) 10^z else identity
  vals <- sc(c(qs$q1, qs$q5, if (!is.null(hl)) hl$.y))
  rng <- if (log) range(vals) else c(0, max(vals))
  all_lab$.ly <- inv(spread_labels(sc(all_lab$.y), 0.075 * max(n_lines(all_lab$.lab)) * diff(rng),
                                   lower = rng[1] + 0.03 * diff(rng), upper = rng[2]))
  p <- p + ggplot2::geom_text(data = all_lab, ggplot2::aes(x = .data$.date, y = .data$.ly, label = .data$.lab),
                              colour = all_lab$.col, hjust = 0, nudge_x = 10, lineheight = 0.85,
                              size = (base_size - 1) / ggplot2::.pt, inherit.aes = FALSE) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::scale_x_date(breaks = year_breaks(qs$.date), date_labels = "%Y", expand = ggplot2::expansion(mult = c(0.01, 0.02)))
  p <- p + if (log) ggplot2::scale_y_log10(labels = y_axis_labels(y))
  else ggplot2::scale_y_continuous(labels = y_axis_labels(y), limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, 0.06)))
  n_org <- length(unique(df$.o))
  sub <- subtitle %||% sprintf("%d organisations", n_org)
  p <- apply_labels(p, title, sub, ylab %||% y_axis_label(y, data), source)
  p + theme_op(base_size) + ggplot2::theme(legend.position = "none",
                                           plot.margin = ggplot2::margin(4, label_margin_pt(all_lab$.lab, base_size - 1), 4, 4, "pt"))
}

# Heatmap ---------------------------------------------------------------------------------

#' Heatmap of drugs (or organisations) by month
#'
#' Tiles show each row's value relative to its own median (`scale = "ratio"`), which makes
#' seasonality and trends comparable between drugs that differ a hundredfold in volume, or the
#' raw value on a perceptually uniform colour scale (`scale = "none"`).
#'
#' @inheritParams op_plot_trend
#' @param row Column defining rows (default `"ab_name"`, else `"code"`).
#' @param scale `"ratio"` (default): colour is log2(value / row median) on a diverging scale
#'   centred at 1x, labelled as multiples. `"none"`: raw value, sequential scale.
#' @param order_by Row order: `"mean"` (largest on top, default), `"peak"` (month of
#'   maximum) or `"name"`.
#' @param title,subtitle Optional title (state the finding in a sentence) and subtitle.
#' @return A [ggplot2::ggplot()] object.
#' @examples
#' ex <- op_example[op_example$ab_name %in% c("Amoxicillin", "Nitrofurantoin", "Doxycycline",
#'                                            "Trimethoprim", "Flucloxacillin"), ]
#' op_plot_heatmap(ex, y = "items")
#' @export
op_plot_heatmap <- function(data, y = NULL, row = NULL, date = "date", scale = c("ratio", "none"),
                            order_by = c("mean", "peak", "name"), title = NULL, subtitle = NULL,
                            source = TRUE, base_size = 8) {
  check_df(data); scale <- match.arg(scale); order_by <- match.arg(order_by)
  y <- guess_y(data, y); row <- guess_group(data, row)
  if (is.null(row)) rlang::abort("Supply `row` (column defining the rows).", class = "opamr_error")
  df <- data; df$.date <- prep_dates(df, date); df$.y <- as.numeric(df[[y]]); df$.r <- as.character(df[[row]])
  df <- df[is.finite(df$.y), , drop = FALSE]
  if (anyDuplicated(df[, c(".r", ".date")])) {
    rlang::abort("More than one value per row and month. Filter to one organisation (or aggregate) first.", class = "opamr_error")
  }
  med <- tapply(df$.y, df$.r, stats::median)
  if (scale == "ratio") {
    if (any(med <= 0)) rlang::warn("Rows with a zero median are shown as missing in `scale = \"ratio\"`.")
    df$.fill <- ifelse(med[df$.r] > 0 & df$.y > 0, log2(df$.y / med[df$.r]), NA_real_)
  } else df$.fill <- df$.y
  ord <- switch(order_by,
                mean = names(sort(tapply(df$.y, df$.r, mean), decreasing = TRUE)),
                peak = names(sort(tapply(seq_len(nrow(df)), df$.r, function(i) as.numeric(df$.date[i][which.max(df$.y[i])])))),
                name = sort(unique(df$.r)))
  df$.r <- factor(df$.r, levels = rev(ord))
  p <- ggplot2::ggplot(df, ggplot2::aes(.data$.date, .data$.r, fill = .data$.fill)) +
    ggplot2::geom_tile(width = 31, height = 0.94) +
    ggplot2::scale_x_date(breaks = year_breaks(df$.date), date_labels = "%Y", expand = ggplot2::expansion(mult = 0.005))
  if (scale == "ratio") {
    lim <- max(abs(df$.fill), na.rm = TRUE); lim <- ceiling(lim * 4) / 4
    p <- p + ggplot2::scale_fill_gradient2(low = op_palette()[["blue"]], mid = "#F4F4F4", high = op_palette()[["vermillion"]],
                                           midpoint = 0, limits = c(-lim, lim), na.value = "grey90", breaks = seq(-3, 3, 0.5),
                                           labels = function(x) paste0(signif(2^x, 2), "\u00d7"),
                                           name = "Relative to the\ndrug's own median")
  } else {
    p <- p + ggplot2::scale_fill_viridis_c(option = "cividis", na.value = "grey90", labels = y_axis_labels(y),
                                           name = y_axis_label(y, data))
  }
  p <- p + ggplot2::guides(fill = ggplot2::guide_colourbar(barheight = ggplot2::unit(25, "mm"), barwidth = ggplot2::unit(2.5, "mm"),
                                                           ticks.colour = "grey30", ticks.linewidth = 0.3))
  p <- apply_labels(p, title, subtitle, NULL, source)
  p + theme_op(base_size) + ggplot2::theme(axis.line.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank(),
                                           panel.grid.major.y = ggplot2::element_blank(),
                                           axis.text.y = ggplot2::element_text(size = base_size - 1, colour = "grey15"))
}

# Saving ----------------------------------------------------------------------------------

#' Save a figure at journal size
#'
#' Wrapper around [ggplot2::ggsave()] with standard journal widths, 300 dpi, and sensible
#' devices: `ragg` for PNG/TIFF when installed, Cairo for PDF, and vector SVG/PDF/EPS.
#'
#' @param plot A ggplot object.
#' @param filename Output file; the extension picks the format (png, pdf, svg, tiff, eps).
#' @param width `"single"` (85 mm), `"onehalf"` (120 mm), `"double"` (178 mm), or a number in
#'   millimetres.
#' @param height Height in mm; default `width * aspect`.
#' @param aspect Height / width when `height` is `NULL` (default 0.62).
#' @param dpi Resolution for raster formats (default 300).
#' @return The file path, invisibly.
#' @examples
#' p <- op_plot_trend(op_example[op_example$ab_name %in% c("Amoxicillin", "Doxycycline"), ], y = "items")
#' f <- op_save(p, tempfile(fileext = ".png"), width = "single")
#' file.exists(f)
#' @export
op_save <- function(plot, filename, width = "single", height = NULL, aspect = 0.62, dpi = 300) {
  if (!inherits(plot, "ggplot")) rlang::abort("`plot` must be a ggplot object.", class = "opamr_error")
  w <- if (is.numeric(width)) width else c(single = 85, onehalf = 120, double = 178)[match.arg(width, c("single", "onehalf", "double"))]
  h <- height %||% (unname(w) * aspect)
  ext <- tolower(tools::file_ext(filename))
  device <- switch(ext,
                   png = if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_png else "png",
                   tif = , tiff = if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_tiff else "tiff",
                   pdf = if (isTRUE(capabilities("cairo"))) grDevices::cairo_pdf else "pdf",
                   NULL)
  ggplot2::ggsave(filename, plot, device = device, width = unname(w), height = h, units = "mm", dpi = dpi)
  invisible(filename)
}
