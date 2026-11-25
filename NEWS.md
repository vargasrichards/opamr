# opamr 0.1.0

* First release.
* Crosswalk between antimicrobial names, `AMR` codes, ATC codes and BNF chemical codes: `ab_to_bnf()`,
  `bnf_to_ab()`, `atc_to_bnf()`, `bnf_to_atc()`, `op_antibiotics()`, `bnf_level()`, `bnf_parent()`,
  `bnf_class()`. The bundled `antibiotic_crosswalk` table has 121 BNF chemicals.
* OpenPrescribing client: `op_spending()`, `op_spending_ab()`, `op_org_details()`, `op_rate()`,
  `op_antibiotic_use()`, `op_bnf_search()`, `op_org_search()`, `op_check_api()`, `op_cache_clear()`. It
  caches responses (in memory and optionally on disk), limits the request rate and retries transient errors.
* Figures: `op_plot_trend()`, `op_plot_seasonal()`, `op_plot_distribution()`, `op_plot_heatmap()`,
  `theme_op()`, `scale_colour_op()`, `op_palette()`, `op_save()`.
* Example data: `op_example`, national monthly antibacterial prescribing from November 2020 to June 2026.
* Four vignettes, a pkgdown site, unit tests, visual-regression tests (vdiffr) and optional live-API tests.
