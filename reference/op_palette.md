# Colour-blind safe palette

The Okabe-Ito palette (Okabe & Ito 2008), ordered so that the first
colours are the most distinguishable, with yellow last because it is
hard to read on white.

## Usage

``` r
op_palette(n = NULL)
```

## Arguments

- n:

  Number of colours (recycled with a warning above 8). `NULL` returns
  all 8.

## Value

A character vector of hex colours.

## Examples

``` r
op_palette(3)
#> [1] "#0072B2" "#D55E00" "#009E73"
```
