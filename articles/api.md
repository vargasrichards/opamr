# Retrieving data from OpenPrescribing

The code in this vignette needs network access to `openprescribing.net`.
It is not run when the package is built, so no output is shown. The
output layouts described are the ones the package tests check. Run
[`op_check_api()`](https://OWNER.github.io/opamr/reference/op_check_api.md)
first to confirm the API can be reached from your machine.

``` r

library(opamr)
op_check_api()
```

## Organisation levels

| `org_type`        | Level                           | Example `org` |
|-------------------|---------------------------------|---------------|
| `"national"`      | England (the default)           | none          |
| `"regional_team"` | NHS England region              | `"Y56"`       |
| `"icb"`           | Integrated Care Board           | `"QWO"`       |
| `"sicbl"`         | Sub-ICB Location (formerly CCG) | `"02P"`       |
| `"pcn"`           | Primary Care Network            | `"U12345"`    |
| `"practice"`      | GP practice                     | `"H81068"`    |

Find codes by name:

``` r

op_org_search("Barnsley", "sicbl")
op_org_search("Densham", "practice")
```

## Items, quantity and cost

[`op_spending()`](https://OWNER.github.io/opamr/reference/op_spending.md)
takes BNF codes at any level. OpenPrescribing sums everything under a
code prefix, so `"0501"` gives all antibacterials and `"0501013B0"`
gives amoxicillin.

``` r

nat     <- op_spending("0501013B0")                                        # England, all months
sub     <- op_spending("0501013K0", org_type = "sicbl", org = c("02P", "15N"))
all_sub <- op_spending("0501", org_type = "sicbl")                         # every Sub-ICB Location
```

Each call returns one row per code, organisation and month, with these
columns:

    date  org_type  org_id  org_name  code  items  quantity  actual_cost

[`op_spending_ab()`](https://OWNER.github.io/opamr/reference/op_spending_ab.md)
does the same by antimicrobial. It looks up BNF codes with
[`ab_to_bnf()`](https://OWNER.github.io/opamr/reference/ab_to_bnf.md)
and sums the chemicals that belong to one agent:

``` r

use <- op_spending_ab(c("amoxicillin", "nitrofurantoin", "doxycycline", "J01MA"))
```

### Practices

The API returns every practice only one month at a time. Either list the
practices, give a Sub-ICB code (which expands to its practices), or give
`date`:

``` r

pr1 <- op_spending("0501", org_type = "practice", org = "02P")                     # practices in one Sub-ICB
pr2 <- op_spending("0501", org_type = "practice", date = c("2025-01", "2025-02"))  # every practice, two months
```

Each requested month is a separate request. Practice-level data for all
of England over several years are large, so for bulk extraction the NHS
Business Services Authority Open Data Portal (English Prescribing
Dataset) is usually faster.

## Denominators and rates

[`op_org_details()`](https://OWNER.github.io/opamr/reference/op_org_details.md)
returns monthly list sizes and weighted denominators at any organisation
level:

- `total_list_size`: registered patients.
- `star_pu.oral_antibacterial_items`: the STAR-PU weighting for oral
  antibacterial prescribing, which adjusts for the age and sex structure
  of the practice population.
- `astro_pu_items` and `astro_pu_cost`: ASTRO-PU weightings.

``` r

den  <- op_org_details("sicbl", keys = c("total_list_size", "star_pu.oral_antibacterial_items"))
rate <- op_rate(all_sub, den, denominator = "star_pu_oral_antibacterial_items")
```

[`op_antibiotic_use()`](https://OWNER.github.io/opamr/reference/op_antibiotic_use.md)
downloads prescribing and the denominator and computes the rate in one
call:

``` r

amx_rates <- op_antibiotic_use("amoxicillin", org_type = "sicbl")                  # per 1,000 patients
op_plot_distribution(amx_rates, y = "rate", highlight = "02P")
```

## Caching, rate limiting and retries

- Responses are cached for the R session. To keep a cache across
  sessions, set a cache directory:

  ``` r

  options(opamr.cache_dir = "~/opamr-cache")
  ```

  Clear the cache with
  [`op_cache_clear()`](https://OWNER.github.io/opamr/reference/op_cache_clear.md),
  for example after the monthly data release.

- Requests are limited to 2 per second. Change this with
  `options(opamr.rate = 1)`.

- Transient failures (HTTP 429 and 5xx) are retried up to
  `opamr.max_tries` times (default 3).

- If you get an error that the server returned an HTML page, a
  bot-protection layer has intercepted the request. This can happen on
  some networks. Try again later, from another network, or with a lower
  request rate.

## Joining to resistance data

Sub-ICB Location codes in OpenPrescribing (`org_id`, such as `"02P"`)
are the same NHS organisation codes that appear at the end of Sub-ICB
area names in UKHSA Fingertips (for example “South Yorkshire ICB -
02P”). This lets prescribing be joined to the Fingertips AMR local
indicators by area and period. The sketch below assumes a Fingertips
extract `fp` with columns `area_name`, `period_start`, `count` and
`denominator` (the number of resistant isolates and the number tested).
Check the area names and the boundary period before relying on the join.

``` r

fp$org_id  <- sub("^.* - ([A-Z0-9]{3})\\s*$", "\\1", fp$area_name)
fp$quarter <- as.Date(cut(fp$period_start, "quarter"))

use <- op_antibiotic_use("trimethoprim", org_type = "sicbl")
use$quarter <- as.Date(cut(use$date, "quarter"))
q_use <- aggregate(cbind(items, total_list_size) ~ org_id + quarter, data = use, FUN = sum)
q_use$rate <- q_use$items / q_use$total_list_size * 1000

joined <- merge(fp, q_use, by = c("org_id", "quarter"))
```

Points to check before modelling:

- **Boundaries.** Sub-ICB Locations replaced CCGs in July 2022, and
  several merged in 2025, so a code’s population can change over time.
- **Monthly versus quarterly sums.** The quarterly sum of monthly list
  sizes is about three times the average list size. That does not affect
  the rate above, because both items and list size are summed over the
  same three months.
- **Rolling indicators.** Many Fingertips resistance indicators are
  rolling averages. Use the discrete quarterly ones if you want counts
  that can be modelled.
