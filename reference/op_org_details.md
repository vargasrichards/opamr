# Practice list size and STAR-PU by organisation

Downloads monthly denominators from OpenPrescribing: total registered
patients (`total_list_size`), ASTRO-PU (`astro_pu_items`,
`astro_pu_cost`) and STAR-PU weights (for example
`star_pu.oral_antibacterial_items`), summed to the requested
organisation level.

## Usage

``` r
op_org_details(org_type = "national", org = NULL, keys = "total_list_size")
```

## Arguments

- org_type, org:

  As in
  [`op_spending()`](https://vargasrichards.github.io/opamr/reference/op_spending.md).
  For `"national"` all practices in England are summed.

- keys:

  Statistics to return: any of `"total_list_size"`, `"astro_pu_items"`,
  `"astro_pu_cost"` and STAR-PU keys of the form `"star_pu.<name>"` such
  as `"star_pu.oral_antibacterial_items"` (the standard weighting for
  oral antibacterial prescribing). Default `"total_list_size"`.

## Value

A data frame with `date`, `org_type`, `org_id`, `org_name` and one
numeric column per key (dots replaced by underscores, for example
`star_pu_oral_antibacterial_items`).

## Examples

``` r
if (FALSE) { # \dontrun{
op_org_details("sicbl", org = c("15N", "02P"),
               keys = c("total_list_size", "star_pu.oral_antibacterial_items"))
} # }
```
