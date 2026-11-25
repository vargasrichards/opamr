# opamr: antibiotic prescribing data from OpenPrescribing, linked to the AMR package

`opamr` has three layers:

1.  **Crosswalk** -
    [`ab_to_bnf()`](https://OWNER.github.io/opamr/reference/ab_to_bnf.md),
    [`bnf_to_ab()`](https://OWNER.github.io/opamr/reference/bnf_to_ab.md),
    [`atc_to_bnf()`](https://OWNER.github.io/opamr/reference/atc_to_bnf.md),
    [`bnf_to_atc()`](https://OWNER.github.io/opamr/reference/atc_to_bnf.md)
    and
    [`op_antibiotics()`](https://OWNER.github.io/opamr/reference/op_antibiotics.md)
    move between antimicrobial names / `AMR` package codes / ATC codes
    and BNF chemical codes, using the bundled
    [antibiotic_crosswalk](https://OWNER.github.io/opamr/reference/antibiotic_crosswalk.md)
    table. The `AMR` package is optional: it is only used to resolve
    free-text names, synonyms and brand names that the bundled table
    does not recognise.

2.  **Data access** -
    [`op_spending()`](https://OWNER.github.io/opamr/reference/op_spending.md),
    [`op_spending_ab()`](https://OWNER.github.io/opamr/reference/op_spending_ab.md),
    [`op_org_details()`](https://OWNER.github.io/opamr/reference/op_org_details.md),
    [`op_rate()`](https://OWNER.github.io/opamr/reference/op_rate.md),
    [`op_antibiotic_use()`](https://OWNER.github.io/opamr/reference/op_antibiotic_use.md),
    [`op_bnf_search()`](https://OWNER.github.io/opamr/reference/op_bnf_search.md)
    and
    [`op_org_search()`](https://OWNER.github.io/opamr/reference/op_org_search.md)
    wrap the OpenPrescribing API.

3.  **Figures** -
    [`theme_op()`](https://OWNER.github.io/opamr/reference/theme_op.md),
    [`scale_colour_op()`](https://OWNER.github.io/opamr/reference/scale_colour_op.md),
    [`op_plot_trend()`](https://OWNER.github.io/opamr/reference/op_plot_trend.md),
    [`op_plot_seasonal()`](https://OWNER.github.io/opamr/reference/op_plot_seasonal.md),
    [`op_plot_distribution()`](https://OWNER.github.io/opamr/reference/op_plot_distribution.md),
    [`op_plot_heatmap()`](https://OWNER.github.io/opamr/reference/op_plot_heatmap.md)
    and
    [`op_save()`](https://OWNER.github.io/opamr/reference/op_save.md).

## Data source and licence

Prescribing data are published monthly by the NHS Business Services
Authority under the Open Government Licence v3.0 and served by the
Bennett Institute for Applied Data Science (University of Oxford)
through OpenPrescribing. Cite both when publishing. The data cover
prescriptions issued in English primary care and dispensed in the
community; they contain items, quantities and costs, **not**
indications, doses or patients.

## Options

- `opamr.base_url` - API root (default
  `https://openprescribing.net/api/1.0`).

- `opamr.rate` - maximum requests per second (default `2`; `Inf`
  disables throttling).

- `opamr.cache` - cache responses for the R session (default `TRUE`).

- `opamr.cache_dir` - optional directory for a persistent on-disk
  response cache.

- `opamr.timeout` - request timeout in seconds (default `120`).

- `opamr.max_tries` - attempts for transient failures (HTTP 429/5xx;
  default `3`).

- `opamr.retry_wait` - seconds to wait between attempts (default
  exponential: 2, 4, ...).

## See also

Useful links:

- <https://OWNER.github.io/opamr/>

- <https://github.com/OWNER/opamr>

- Report bugs at <https://github.com/OWNER/opamr/issues>

## Author

**Maintainer**: Package Maintainer <maintainer@example.org>

Authors:

- Package Maintainer <maintainer@example.org>
