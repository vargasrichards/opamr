# Convert between ATC codes and BNF chemical codes

`atc_to_bnf()` accepts full ATC codes or prefixes (`"J01CA"`);
`bnf_to_atc()` returns the primary human ATC code for BNF codes of any
level.

## Usage

``` r
atc_to_bnf(atc, ...)

bnf_to_atc(code)
```

## Arguments

- atc:

  Character vector of ATC codes or prefixes.

- ...:

  Passed to
  [`ab_to_bnf()`](https://vargasrichards.github.io/opamr/reference/ab_to_bnf.md)
  (`scope`, `output`).

- code:

  Character vector of BNF codes (any level).

## Value

`atc_to_bnf()`: as
[`ab_to_bnf()`](https://vargasrichards.github.io/opamr/reference/ab_to_bnf.md).
`bnf_to_atc()`: a named character vector of primary ATC codes, named by
input.

## Examples

``` r
atc_to_bnf("J01CA", output = "codes")
#> [1] "0501013B0" "0501013C0" "0501013E0" "0501015P0"
bnf_to_atc(c("0501013B0", "0501130R0"))
#> 0501013B0 0501130R0 
#> "J01CA04" "J01XE01" 
```
