# Seasonal profile: one line per year

Plots month of the year on the x-axis and one line per calendar year,
with earlier years in graduated grey and the most recent year in colour,
so seasonality (for example the winter peak in antibiotic prescribing)
and year-to-year change are visible together.

## Usage

``` r
op_plot_seasonal(
  data,
  y = NULL,
  facet = NULL,
  date = "date",
  years = NULL,
  highlight_year = NULL,
  label_years = TRUE,
  facet_scales = c("free_y", "fixed"),
  ylab = NULL,
  title = NULL,
  subtitle = NULL,
  source = TRUE,
  base_size = 8
)
```

## Arguments

- data:

  Data frame with a date column and a numeric column to plot.

- y:

  Column to plot. Default `"rate"` if present, otherwise `"items"`.

- facet:

  Column to split into small multiples, usually the antimicrobial
  (`"ab_name"`, used automatically if present with several values). The
  data must hold one series per facet and month; filter to a single
  organisation first.

- date:

  Date column (default `"date"`).

- years:

  Optional integer vector of years to show (default: all).

- highlight_year:

  Year drawn in colour (default: the latest year).

- label_years:

  Label lines with the year at their right-hand end (default `TRUE`).

- facet_scales:

  Scales for facets: `"free_y"` (default) or `"fixed"`.

- ylab, title, subtitle:

  Text. `title` should state the finding in a sentence; it is `NULL` by
  default (put the message in the figure caption of your paper).

- source:

  Add the data-source caption (default `TRUE`); or a custom character
  string.

- base_size:

  Base font size (default 8 pt, see
  [`theme_op()`](https://vargasrichards.github.io/opamr/reference/theme_op.md)).

## Value

A
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Examples

``` r
ex <- op_example[op_example$ab_name %in% c("Amoxicillin", "Nitrofurantoin"), ]
op_plot_seasonal(ex, y = "items", years = 2022:2026)
```
