# Prescribing items, quantity and cost from OpenPrescribing

Retrieves monthly prescribing totals for one or more BNF codes,
nationally or by organisation. Returns tidy data frames with one row per
code, organisation and month.

## Usage

``` r
op_spending(
  code,
  org_type = "national",
  org = NULL,
  date = NULL,
  by_code = TRUE,
  progress = interactive()
)
```

## Arguments

- code:

  Character vector of BNF codes. Any level works (section `"0501"`,
  chemical `"0501013B0"`, product, presentation); OpenPrescribing sums
  everything under a code prefix. Use
  [`ab_to_bnf()`](https://OWNER.github.io/opamr/reference/ab_to_bnf.md)
  to obtain chemical codes from antimicrobial names.

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

- by_code:

  If `TRUE` (default) one request per code and a `code` column; if
  `FALSE` all codes are summed by the API into one series labelled
  `"code1+code2"`.

- progress:

  Show a progress bar when several requests are needed (default: only in
  interactive sessions).

## Value

A data frame with columns `date`, `org_type`, `org_id`, `org_name`,
`code`, `items`, `quantity`, `actual_cost` (and `ccg`, `setting` for
practices). `items` counts prescription items dispensed, `quantity` is
in the units of each product (tablets, ml, ...) and is therefore **not
comparable across chemicals or formulations**, `actual_cost` is in
pounds. Months in which an organisation issued no matching item are
absent (they are zeros, not missing data).

## Details

The data are updated monthly with a lag of about two months. Prescribing
is attributed to the practice that issued the prescription; items
dispensed outside England or privately are not included.

## See also

[`op_spending_ab()`](https://OWNER.github.io/opamr/reference/op_spending_ab.md)
to query by antimicrobial name,
[`op_org_details()`](https://OWNER.github.io/opamr/reference/op_org_details.md)
for denominators,
[`op_rate()`](https://OWNER.github.io/opamr/reference/op_rate.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# National monthly amoxicillin items
op_spending("0501013B0")

# Co-amoxiclav in two Sub-ICB Locations
op_spending("0501013K0", org_type = "sicbl", org = c("15N", "02P"))

# All practices in one Sub-ICB, one month
op_spending("0501", org_type = "practice", org = "15N", date = "2025-03")
} # }
```
