# Antimicrobial crosswalk: BNF chemical substances and AMR package antimicrobials

One row per BNF chemical substance that corresponds to an antimicrobial
agent in the `AMR` package. Built from the chemical substances present
in the NHS Business Services Authority English Prescribing Dataset
(December 2025 and June 2026) by matching names with
[`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html), rejecting
fuzzy false positives, and applying a short manual override table
(`data-raw/manual_overrides.csv`). Several BNF chemicals can map to one
AMR agent (salts and routes, for example doxycycline hyclate and
monohydrate), and one agent can appear in several BNF chapters (systemic
in chapter 5; eye, ear, skin and vaginal products in chapters 7, 11, 12
and 13).

## Usage

``` r
antibiotic_crosswalk
```

## Format

A data frame with columns:

- bnf_chemical_code:

  9-character BNF chemical substance code.

- bnf_name:

  BNF chemical substance name.

- bnf_chapter, bnf_section, bnf_paragraph:

  BNF chapter (2), section (4) and paragraph (6) codes.

- ab:

  `AMR` package antimicrobial code (for example `"AMX"`).

- ab_name:

  `AMR` antimicrobial name.

- ab_group:

  `AMR` antimicrobial group(s), separated by `" | "`.

- atc:

  Primary human ATC code (systemic `J...` code preferred); can be `NA`.

- atc_all:

  All human ATC codes for the agent, separated by `"|"`.

- match_method:

  `"AMR::as.ab"` (name matching) or `"manual"`.

- amr_version:

  Version of the `AMR` package used to build the table.

## Source

NHSBSA English Prescribing Dataset, BNF chemical substances (Open
Government Licence v3.0); `AMR` package antimicrobials dataset.

## Details

Scope: antibacterials (including antimycobacterials) and antifungals,
plus topical anti-infectives. Antivirals and antiparasitics are not
included because the `AMR` package keeps them in separate datasets
(`as.av()`).

## Examples

``` r
head(antibiotic_crosswalk[, c("bnf_chemical_code", "bnf_name", "ab", "atc")])
#>   bnf_chemical_code                               bnf_name  ab     atc
#> 1         0501011J0 Benzylpenicillin sodium (Penicillin G) PEN J01CE01
#> 2         0501011P0 Phenoxymethylpenicillin (Penicillin V) PHN J01CE02
#> 3         0501012G0                  Flucloxacillin sodium FLC J01CF05
#> 4         0501013B0                            Amoxicillin AMX J01CA04
#> 5         0501013C0                     Amoxicillin sodium AMX J01CA04
#> 6         0501013E0                             Ampicillin AMP J01CA01
```
