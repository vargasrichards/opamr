# Antimicrobial use as a rate, in one call

Combines
[`op_spending_ab()`](https://vargasrichards.github.io/opamr/reference/op_spending_ab.md),
[`op_org_details()`](https://vargasrichards.github.io/opamr/reference/op_org_details.md)
and
[`op_rate()`](https://vargasrichards.github.io/opamr/reference/op_rate.md):
downloads prescribing for the requested antimicrobials, downloads the
denominator at the same organisation level, and returns items per 1,000
registered patients (or another denominator).

## Usage

``` r
op_antibiotic_use(
  x,
  org_type = "national",
  org = NULL,
  date = NULL,
  denominator = "total_list_size",
  per = 1000,
  scope = c("systemic", "all"),
  use_amr = TRUE,
  progress = interactive()
)
```

## Arguments

- x:

  Antimicrobial names, `AMR` codes, ATC codes/prefixes or group names
  (see
  [`ab_to_bnf()`](https://vargasrichards.github.io/opamr/reference/ab_to_bnf.md)).

- org_type:

  Organisation level: `"national"` (all of England, default), `"sicbl"`
  (Sub-ICB Location, formerly CCG), `"icb"`, `"pcn"`, `"practice"` or
  `"regional_team"`.

- org:

  Optional organisation code(s) (for example a Sub-ICB code such as
  `"15N"` or a practice code such as `"H81068"`). For `"practice"`, a
  Sub-ICB code returns all its practices. If `NULL`, all organisations
  of that type are returned.

- date:

  Optional month(s) as `"YYYY-MM"`, `"YYYY-MM-DD"` or `Date`. Required
  for `org_type = "practice"` when `org` is `NULL` (the API refuses to
  return every practice for every month). Several dates trigger one
  request per date.

- denominator:

  Denominator key from
  [`op_org_details()`](https://vargasrichards.github.io/opamr/reference/op_org_details.md);
  default `"total_list_size"`. `"star_pu.oral_antibacterial_items"`
  gives STAR-PU weighted rates.

- per:

  Scaling factor (default 1000).

- scope:

  `"systemic"` (default) keeps BNF chapter 5 (infections: oral and
  injectable products). `"all"` also returns topical, eye, ear, skin and
  vaginal chemicals from chapters 7, 11, 12 and 13, which are prescribed
  for different purposes and should not be pooled with systemic use by
  accident.

- use_amr:

  Use [`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html) for
  inputs the bundled table cannot resolve (default `TRUE`; ignored if
  `AMR` is not installed).

- progress:

  Show a progress bar when several requests are needed (default: only in
  interactive sessions).

## Value

A data frame as from
[`op_spending_ab()`](https://vargasrichards.github.io/opamr/reference/op_spending_ab.md)
plus the denominator column and `rate`.

## Examples

``` r
if (FALSE) { # \dontrun{
use <- op_antibiotic_use(c("amoxicillin", "nitrofurantoin"), org_type = "sicbl", org = "15N")
op_plot_trend(use, y = "rate")
} # }
```
