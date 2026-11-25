# Changelog

## opamr 0.1.0

- First release.
- Crosswalk between antimicrobial names, `AMR` codes, ATC codes and BNF
  chemical codes:
  [`ab_to_bnf()`](https://OWNER.github.io/opamr/reference/ab_to_bnf.md),
  [`bnf_to_ab()`](https://OWNER.github.io/opamr/reference/bnf_to_ab.md),
  [`atc_to_bnf()`](https://OWNER.github.io/opamr/reference/atc_to_bnf.md),
  [`bnf_to_atc()`](https://OWNER.github.io/opamr/reference/atc_to_bnf.md),
  [`op_antibiotics()`](https://OWNER.github.io/opamr/reference/op_antibiotics.md),
  [`bnf_level()`](https://OWNER.github.io/opamr/reference/bnf_level.md),
  [`bnf_parent()`](https://OWNER.github.io/opamr/reference/bnf_level.md),
  [`bnf_class()`](https://OWNER.github.io/opamr/reference/bnf_level.md).
  The bundled `antibiotic_crosswalk` table has 121 BNF chemicals.
- OpenPrescribing client:
  [`op_spending()`](https://OWNER.github.io/opamr/reference/op_spending.md),
  [`op_spending_ab()`](https://OWNER.github.io/opamr/reference/op_spending_ab.md),
  [`op_org_details()`](https://OWNER.github.io/opamr/reference/op_org_details.md),
  [`op_rate()`](https://OWNER.github.io/opamr/reference/op_rate.md),
  [`op_antibiotic_use()`](https://OWNER.github.io/opamr/reference/op_antibiotic_use.md),
  [`op_bnf_search()`](https://OWNER.github.io/opamr/reference/op_bnf_search.md),
  [`op_org_search()`](https://OWNER.github.io/opamr/reference/op_org_search.md),
  [`op_check_api()`](https://OWNER.github.io/opamr/reference/op_check_api.md),
  [`op_cache_clear()`](https://OWNER.github.io/opamr/reference/op_cache_clear.md).
  It caches responses (in memory and optionally on disk), limits the
  request rate and retries transient errors.
- Figures:
  [`op_plot_trend()`](https://OWNER.github.io/opamr/reference/op_plot_trend.md),
  [`op_plot_seasonal()`](https://OWNER.github.io/opamr/reference/op_plot_seasonal.md),
  [`op_plot_distribution()`](https://OWNER.github.io/opamr/reference/op_plot_distribution.md),
  [`op_plot_heatmap()`](https://OWNER.github.io/opamr/reference/op_plot_heatmap.md),
  [`theme_op()`](https://OWNER.github.io/opamr/reference/theme_op.md),
  [`scale_colour_op()`](https://OWNER.github.io/opamr/reference/scale_colour_op.md),
  [`op_palette()`](https://OWNER.github.io/opamr/reference/op_palette.md),
  [`op_save()`](https://OWNER.github.io/opamr/reference/op_save.md).
- Example data: `op_example`, national monthly antibacterial prescribing
  from November 2020 to June 2026.
- Four vignettes, a pkgdown site, unit tests, visual-regression tests
  (vdiffr) and optional live-API tests.
