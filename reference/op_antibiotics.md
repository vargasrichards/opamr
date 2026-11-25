# List the antimicrobials in the crosswalk

Convenience filter on
[antibiotic_crosswalk](https://vargasrichards.github.io/opamr/reference/antibiotic_crosswalk.md).

## Usage

``` r
op_antibiotics(scope = c("systemic", "all"), section = NULL, ab_group = NULL)
```

## Arguments

- scope:

  `"systemic"` (BNF chapter 5, default) or `"all"`.

- section:

  Optional BNF section or paragraph prefixes to keep (for example
  `"0501"`, `"050112"`).

- ab_group:

  Optional `AMR` group name(s) to keep (matched case-insensitively
  against any group of the agent, for example `"Penicillins"`).

## Value

A data frame (subset of
[antibiotic_crosswalk](https://vargasrichards.github.io/opamr/reference/antibiotic_crosswalk.md))
with an added `bnf_class` column giving the BNF paragraph label where
known.

## Examples

``` r
head(op_antibiotics(section = "050112"))
#>   bnf_chemical_code      bnf_name bnf_chapter bnf_section bnf_paragraph  ab
#> 1         0501120L0 Ciprofloxacin          05        0501        050112 CIP
#> 2         0501120P0     Ofloxacin          05        0501        050112 OFX
#> 3         0501120Q0   Norfloxacin          05        0501        050112 NOR
#> 4         0501120X0  Levofloxacin          05        0501        050112 LVX
#> 5         0501120Y0  Moxifloxacin          05        0501        050112 MFX
#>         ab_name         ab_group     atc                         atc_all
#> 1 Ciprofloxacin Fluoroquinolones J01MA02 J01MA02|S01AE03|S02AA15|S03AA07
#> 2     Ofloxacin Fluoroquinolones J01MA01         J01MA01|S01AE01|S02AA16
#> 3   Norfloxacin Fluoroquinolones J01MA06                 J01MA06|S01AE02
#> 4  Levofloxacin Fluoroquinolones J01MA12                 J01MA12|S01AE05
#> 5  Moxifloxacin Fluoroquinolones J01MA14                 J01MA14|S01AE07
#>   match_method amr_version  bnf_class
#> 1   AMR::as.ab       3.1.0 Quinolones
#> 2   AMR::as.ab       3.1.0 Quinolones
#> 3   AMR::as.ab       3.1.0 Quinolones
#> 4   AMR::as.ab       3.1.0 Quinolones
#> 5   AMR::as.ab       3.1.0 Quinolones
op_antibiotics(ab_group = "Carbapenems")[, c("bnf_chemical_code", "ab_name")]
#>   bnf_chemical_code   ab_name
#> 1         0501022A0 Meropenem
#> 2         0501022B0 Ertapenem
```
