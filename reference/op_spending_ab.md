# Prescribing data by antimicrobial name

Looks up BNF chemical codes for antimicrobials (names, `AMR` codes, ATC
codes or groups, see
[`ab_to_bnf()`](https://OWNER.github.io/opamr/reference/ab_to_bnf.md)),
downloads their prescribing with
[`op_spending()`](https://OWNER.github.io/opamr/reference/op_spending.md),
and labels the result with the `AMR` code, name and ATC code. When
several BNF chemicals belong to one agent (for example doxycycline
hyclate and doxycycline monohydrate) they are summed per agent by
default.

## Usage

``` r
op_spending_ab(
  x,
  org_type = "national",
  org = NULL,
  date = NULL,
  scope = c("systemic", "all"),
  aggregate = TRUE,
  use_amr = TRUE,
  progress = interactive()
)
```

## Arguments

- x:

  Antimicrobial names, `AMR` codes, ATC codes/prefixes or group names
  (see
  [`ab_to_bnf()`](https://OWNER.github.io/opamr/reference/ab_to_bnf.md)).

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

- scope:

  `"systemic"` (default) keeps BNF chapter 5 (infections: oral and
  injectable products). `"all"` also returns topical, eye, ear, skin and
  vaginal chemicals from chapters 7, 11, 12 and 13, which are prescribed
  for different purposes and should not be pooled with systemic use by
  accident.

- aggregate:

  Sum BNF chemicals that map to the same antimicrobial and organisation
  (default `TRUE`). Set `FALSE` to keep one row per BNF chemical.
  `quantity` is summed too, so treat it with care when the chemicals
  have different units; prefer `items`.

- use_amr:

  Use [`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html) for
  inputs the bundled table cannot resolve (default `TRUE`; ignored if
  `AMR` is not installed).

- progress:

  Show a progress bar when several requests are needed (default: only in
  interactive sessions).

## Value

A data frame as from
[`op_spending()`](https://OWNER.github.io/opamr/reference/op_spending.md)
with extra columns `ab`, `ab_name`, `atc` (and `code` listing the BNF
chemical code(s) combined).

## Examples

``` r
if (FALSE) { # \dontrun{
use <- op_spending_ab(c("amoxicillin", "nitrofurantoin", "doxycycline"))
head(use)
op_spending_ab("J01MA", org_type = "sicbl", org = "15N")   # quinolones in one Sub-ICB
} # }
```
