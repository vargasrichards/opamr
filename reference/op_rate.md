# Convert counts to rates per population or weighted-population denominator

Joins prescribing data to denominators by month (and organisation) and
computes `numerator / denominator * per`.

## Usage

``` r
op_rate(
  x,
  details,
  numerator = "items",
  denominator = "total_list_size",
  per = 1000,
  name = "rate"
)
```

## Arguments

- x:

  Data frame from
  [`op_spending()`](https://OWNER.github.io/opamr/reference/op_spending.md)
  or
  [`op_spending_ab()`](https://OWNER.github.io/opamr/reference/op_spending_ab.md).

- details:

  Data frame from
  [`op_org_details()`](https://OWNER.github.io/opamr/reference/op_org_details.md)
  at the same organisation level.

- numerator:

  Column of `x` to use (default `"items"`).

- denominator:

  Column of `details` (default `"total_list_size"`; for antibacterial
  prescribing `"star_pu_oral_antibacterial_items"` is the usual age-sex
  weighted choice).

- per:

  Scaling factor (default `1000`).

- name:

  Name of the new column. Default `"rate"`.

## Value

`x` with the denominator and the new rate column added; the rate
definition is stored in the `"rate_label"` attribute and used by the
plotting functions for axis labels. Rows without a matching denominator
get `NA`.

## Examples

``` r
x <- data.frame(date = as.Date(c("2025-01-01", "2025-02-01")), org_id = "A",
                items = c(120, 150))
d <- data.frame(date = as.Date(c("2025-01-01", "2025-02-01")), org_id = "A",
                total_list_size = c(60000, 60100))
op_rate(x, d)
#>         date org_id items total_list_size    rate
#> 1 2025-01-01      A   120           60000 2.00000
#> 2 2025-02-01      A   150           60100 2.49584
```
