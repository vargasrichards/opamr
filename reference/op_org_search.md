# Search organisation codes

Finds Sub-ICB Locations, ICBs, PCNs, practices or regional teams by name
or code.

## Usage

``` r
op_org_search(
  q,
  org_type = c("sicbl", "practice", "pcn", "icb", "regional_team"),
  exact = FALSE
)
```

## Arguments

- q:

  Name fragment or code prefix.

- org_type:

  One of `"sicbl"`, `"icb"`, `"pcn"`, `"practice"`, `"regional_team"`.

- exact:

  Match whole names/codes only (default `FALSE`).

## Value

A data frame with at least `id`, `name` and `type` (practices also have
`postcode`, `setting_name` and the parent Sub-ICB in `ccg`).

## Examples

``` r
if (FALSE) { # \dontrun{
op_org_search("Barnsley", "sicbl")
} # }
```
