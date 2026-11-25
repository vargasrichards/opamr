# Search BNF codes

Searches the BNF hierarchy served by OpenPrescribing: sections,
chemicals, products and presentations, by name or code prefix.

## Usage

``` r
op_bnf_search(q, exact = FALSE)
```

## Arguments

- q:

  Search string(s): a name fragment (`"amoxicillin"`) or code prefix
  (`"0501013"`).

- exact:

  Match whole names/codes only (default `FALSE`).

## Value

A data frame with columns `type`, `id` (BNF code or section number),
`name` and, where the API provides them, `section` and `is_generic`.

## See also

[`ab_to_bnf()`](https://vargasrichards.github.io/opamr/reference/ab_to_bnf.md)
for offline name-to-code conversion

## Examples

``` r
if (FALSE) { # \dontrun{
op_bnf_search("nitrofurantoin")
} # }
```
