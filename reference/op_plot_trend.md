# Publication-quality prescribing time series

Draws one line per antimicrobial (or other group) with direct labels at
the right-hand end instead of a legend. Output of
[`op_spending()`](https://vargasrichards.github.io/opamr/reference/op_spending.md),
[`op_spending_ab()`](https://vargasrichards.github.io/opamr/reference/op_spending_ab.md)
or
[`op_antibiotic_use()`](https://vargasrichards.github.io/opamr/reference/op_antibiotic_use.md)
can be passed directly.

## Usage

``` r
op_plot_trend(
  data,
  y = NULL,
  group = NULL,
  facet = NULL,
  date = "date",
  highlight = NULL,
  max_groups = 8L,
  label = TRUE,
  log = FALSE,
  zero = TRUE,
  events = NULL,
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

- group:

  Column that defines the lines. If `NULL` (default) it is `"ab_name"`
  or `"code"` when present with more than one value, otherwise a single
  series is drawn.

- facet:

  Optional column to split into small multiples (free y-axes by
  default). If `facet` is given and `group` is `NULL`, each panel shows
  one line in a single colour with no direct label (the panel title
  names the series).

- date:

  Date column (default `"date"`).

- highlight:

  Groups to colour; all others are drawn in light grey without labels.
  If `NULL` and there are more than `max_groups` groups, the
  `max_groups` groups with the highest final value are highlighted.

- max_groups:

  Maximum number of coloured groups when `highlight` is `NULL` (default
  8, the size of the colour-blind safe palette).

- label:

  Draw direct labels (default `TRUE`).

- log:

  Use a log10 y-axis (default `FALSE`). Lines only; never bars.

- zero:

  Start a linear y-axis at zero (default `TRUE`).

- events:

  Optional data frame with columns `date` and `label` to mark events
  with a dashed vertical line and a label.

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
ex <- op_example[op_example$ab_name %in%
  c("Amoxicillin", "Doxycycline", "Nitrofurantoin", "Amoxicillin/clavulanic acid"), ]
op_plot_trend(ex, y = "items")

op_plot_trend(ex, y = "items", highlight = "Nitrofurantoin", log = TRUE)
```
