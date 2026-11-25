# Describe the structure of BNF codes

BNF codes are hierarchical: the first 2 characters give the chapter, 4
the section, 6 the paragraph, 7 the subparagraph, 9 the chemical
substance, 11 the product and 15 the presentation. `bnf_level()` reports
which level a code is, `bnf_parent()` truncates to a higher level, and
`bnf_class()` returns a readable label for chapter 5 sections and
paragraphs (antibacterial classes).

## Usage

``` r
bnf_level(code)

bnf_parent(
  code,
  level = c("chemical", "section", "paragraph", "chapter", "subparagraph", "product")
)

bnf_class(code, at = c("paragraph", "section"))
```

## Arguments

- code:

  Character vector of BNF codes (any level).

- level:

  For `bnf_parent()`: one of `"chapter"`, `"section"`, `"paragraph"`,
  `"subparagraph"`, `"chemical"`, `"product"`.

- at:

  For `bnf_class()`: `"paragraph"` (default, e.g. `050101` Penicillins)
  or `"section"` (e.g. `0501` Antibacterial drugs).

## Value

`bnf_level()` and `bnf_class()` return character vectors (`NA` where the
code is not recognised); `bnf_parent()` returns the truncated codes
(`NA` where the code is shorter than the requested level).

## Examples

``` r
bnf_level(c("0501", "0501013B0", "0501013B0AAAAAA"))
#> [1] "section"      "chemical"     "presentation"
bnf_parent("0501013K0", "paragraph")
#> [1] "050101"
bnf_class(c("0501013B0", "0501120L0", "0501021G0"))
#> [1] "Penicillins"                                       
#> [2] "Quinolones"                                        
#> [3] "Cephalosporins, carbapenems and other beta-lactams"
```
