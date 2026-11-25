# Heatmap of drugs (or organisations) by month

Tiles show each row's value relative to its own median
(`scale = "ratio"`), which makes seasonality and trends comparable
between drugs that differ a hundredfold in volume, or the raw value on a
perceptually uniform colour scale (`scale = "none"`).

## Usage

``` r
op_plot_heatmap(
  data,
  y = NULL,
  row = NULL,
  date = "date",
  scale = c("ratio", "none"),
  order_by = c("mean", "peak", "name"),
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

- row:

  Column defining rows (default `"ab_name"`, else `"code"`).

- date:

  Date column (default `"date"`).

- scale:

  `"ratio"` (default): colour is log2(value / row median) on a diverging
  scale centred at 1x, labelled as multiples. `"none"`: raw value,
  sequential scale.

- order_by:

  Row order: `"mean"` (largest on top, default), `"peak"` (month of
  maximum) or `"name"`.

- title, subtitle:

  Optional title (state the finding in a sentence) and subtitle.

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
ex <- op_example[op_example$ab_name %in% c("Amoxicillin", "Nitrofurantoin", "Doxycycline",
                                           "Trimethoprim", "Flucloxacillin"), ]
op_plot_heatmap(ex, y = "items")
```
