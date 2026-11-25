# Colour-blind safe discrete ggplot2 scales

Colour-blind safe discrete ggplot2 scales

## Usage

``` r
scale_colour_op(...)

scale_fill_op(...)
```

## Arguments

- ...:

  Passed to
  [`ggplot2::discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html).

## Value

A ggplot2 scale.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) + geom_point() + scale_colour_op()
```
