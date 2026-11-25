# Convert BNF codes to AMR package antimicrobial codes

Maps BNF codes to the antimicrobial agent they contain. Codes longer
than 9 characters (products and presentations, such as the 15-character
codes in prescribing data) are truncated to the chemical substance.
Codes shorter than 9 characters (chapter, section, paragraph,
subparagraph) are expanded to every crosswalk chemical they contain, so
`bnf_to_ab("050112")` lists all quinolones.

## Usage

``` r
bnf_to_ab(code, output = c("table", "ab"))
```

## Arguments

- code:

  Character vector of BNF codes (any level).

- output:

  `"table"` (default) or `"ab"` for a character vector of unique `AMR`
  codes.

## Value

A data frame with `input`, `bnf_chemical_code`, `bnf_name`, `ab`,
`ab_name`, `atc`, `ab_group` (one row per input and chemical), or a
character vector of `AMR` codes. Codes not in the crosswalk give a row
with `NA` and a warning.

## See also

[`ab_to_bnf()`](https://vargasrichards.github.io/opamr/reference/ab_to_bnf.md)

## Examples

``` r
bnf_to_ab(c("0501013B0", "0501013B0AAAAAA"))   # chemical, then a 15-char presentation
#>             input bnf_chemical_code    bnf_name  ab     ab_name     atc
#> 1       0501013B0         0501013B0 Amoxicillin AMX Amoxicillin J01CA04
#> 2 0501013B0AAAAAA         0501013B0 Amoxicillin AMX Amoxicillin J01CA04
#>           ab_group
#> 1 Aminopenicillins
#> 2 Aminopenicillins
bnf_to_ab("050112", output = "ab")               # all quinolones in BNF paragraph 5.1.12
#> [1] "CIP" "OFX" "NOR" "LVX" "MFX"
```
