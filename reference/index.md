# Package index

## Crosswalk

Convert between antimicrobial names, AMR codes, ATC codes and BNF codes
(offline).

- [`ab_to_bnf()`](https://OWNER.github.io/opamr/reference/ab_to_bnf.md)
  : Convert antimicrobial names, AMR codes or ATC codes to BNF codes
- [`bnf_to_ab()`](https://OWNER.github.io/opamr/reference/bnf_to_ab.md)
  : Convert BNF codes to AMR package antimicrobial codes
- [`atc_to_bnf()`](https://OWNER.github.io/opamr/reference/atc_to_bnf.md)
  [`bnf_to_atc()`](https://OWNER.github.io/opamr/reference/atc_to_bnf.md)
  : Convert between ATC codes and BNF chemical codes
- [`op_antibiotics()`](https://OWNER.github.io/opamr/reference/op_antibiotics.md)
  : List the antimicrobials in the crosswalk
- [`bnf_level()`](https://OWNER.github.io/opamr/reference/bnf_level.md)
  [`bnf_parent()`](https://OWNER.github.io/opamr/reference/bnf_level.md)
  [`bnf_class()`](https://OWNER.github.io/opamr/reference/bnf_level.md)
  : Describe the structure of BNF codes

## Prescribing data

Monthly items, quantity and cost from the OpenPrescribing API.

- [`op_spending()`](https://OWNER.github.io/opamr/reference/op_spending.md)
  : Prescribing items, quantity and cost from OpenPrescribing
- [`op_spending_ab()`](https://OWNER.github.io/opamr/reference/op_spending_ab.md)
  : Prescribing data by antimicrobial name
- [`op_antibiotic_use()`](https://OWNER.github.io/opamr/reference/op_antibiotic_use.md)
  : Antimicrobial use as a rate, in one call

## Denominators and rates

- [`op_org_details()`](https://OWNER.github.io/opamr/reference/op_org_details.md)
  : Practice list size and STAR-PU by organisation
- [`op_rate()`](https://OWNER.github.io/opamr/reference/op_rate.md) :
  Convert counts to rates per population or weighted-population
  denominator

## Lookups and API utilities

- [`op_bnf_search()`](https://OWNER.github.io/opamr/reference/op_bnf_search.md)
  : Search BNF codes
- [`op_org_search()`](https://OWNER.github.io/opamr/reference/op_org_search.md)
  : Search organisation codes
- [`op_check_api()`](https://OWNER.github.io/opamr/reference/op_check_api.md)
  : Check that the OpenPrescribing API is reachable
- [`op_cache_clear()`](https://OWNER.github.io/opamr/reference/op_cache_clear.md)
  : Clear the opamr response cache

## Figures

Publication-quality ggplot2 figures with a colour-blind safe palette and
direct labels.

- [`op_plot_trend()`](https://OWNER.github.io/opamr/reference/op_plot_trend.md)
  : Publication-quality prescribing time series
- [`op_plot_seasonal()`](https://OWNER.github.io/opamr/reference/op_plot_seasonal.md)
  : Seasonal profile: one line per year
- [`op_plot_distribution()`](https://OWNER.github.io/opamr/reference/op_plot_distribution.md)
  : Distribution of prescribing across organisations over time
- [`op_plot_heatmap()`](https://OWNER.github.io/opamr/reference/op_plot_heatmap.md)
  : Heatmap of drugs (or organisations) by month
- [`op_save()`](https://OWNER.github.io/opamr/reference/op_save.md) :
  Save a figure at journal size
- [`theme_op()`](https://OWNER.github.io/opamr/reference/theme_op.md) :
  A clean, journal-ready ggplot2 theme
- [`scale_colour_op()`](https://OWNER.github.io/opamr/reference/scale_colour_op.md)
  [`scale_fill_op()`](https://OWNER.github.io/opamr/reference/scale_colour_op.md)
  : Colour-blind safe discrete ggplot2 scales
- [`op_palette()`](https://OWNER.github.io/opamr/reference/op_palette.md)
  : Colour-blind safe palette

## Data

- [`antibiotic_crosswalk`](https://OWNER.github.io/opamr/reference/antibiotic_crosswalk.md)
  : Antimicrobial crosswalk: BNF chemical substances and AMR package
  antimicrobials
- [`op_example`](https://OWNER.github.io/opamr/reference/op_example.md)
  : Example national antibacterial prescribing, November 2020 to June
  2026

## Package

- [`opamr`](https://OWNER.github.io/opamr/reference/opamr-package.md)
  [`opamr-package`](https://OWNER.github.io/opamr/reference/opamr-package.md)
  : opamr: antibiotic prescribing data from OpenPrescribing, linked to
  the AMR package
