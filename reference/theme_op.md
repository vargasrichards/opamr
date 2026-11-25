# A clean, journal-ready ggplot2 theme

Axis lines only on the left and bottom, faint horizontal grid,
left-aligned plain titles, and a three-step type scale: axis titles and
panel titles at `base_size`, legends and annotations at `base_size - 1`,
tick labels at `base_size - 2`. The defaults (8/7/6 pt) suit single- and
double-column journal figures.

## Usage

``` r
theme_op(base_size = 8, base_family = "")
```

## Arguments

- base_size:

  Base font size in points (default 8).

- base_family:

  Font family (default: device default sans-serif).

## Value

A
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html).

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_op()
```
