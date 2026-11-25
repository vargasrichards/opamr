# Convert antimicrobial names, AMR codes or ATC codes to BNF codes

Looks up each input in the bundled
[antibiotic_crosswalk](https://OWNER.github.io/opamr/reference/antibiotic_crosswalk.md)
and returns the matching BNF chemical substance code(s). Inputs can be:

## Usage

``` r
ab_to_bnf(
  x,
  scope = c("systemic", "all"),
  output = c("table", "codes"),
  use_amr = TRUE
)
```

## Arguments

- x:

  Character vector of names or codes.

- scope:

  `"systemic"` (default) keeps BNF chapter 5 (infections: oral and
  injectable products). `"all"` also returns topical, eye, ear, skin and
  vaginal chemicals from chapters 7, 11, 12 and 13, which are prescribed
  for different purposes and should not be pooled with systemic use by
  accident.

- output:

  `"table"` (default) returns one row per input and BNF chemical;
  `"codes"` returns the unique BNF chemical codes as a character vector.

- use_amr:

  Use [`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html) for
  inputs the bundled table cannot resolve (default `TRUE`; ignored if
  `AMR` is not installed).

## Value

A data frame with columns `input`, `ab`, `ab_name`, `atc`,
`bnf_chemical_code`, `bnf_name`, `bnf_section` and `via` (how the input
was recognised: `"bundled table"` or `"AMR::as.ab"`), or a character
vector of codes if `output = "codes"`. Inputs that cannot be resolved,
or that resolve to an agent with no BNF chemical in `scope`, give a
warning (naming the agent, so fuzzy matches are visible) and a row with
`NA` codes. Group and class inputs silently skip members that have no
BNF chemical in `scope`.

## Details

- `AMR` package antimicrobial codes (`"AMX"`),

- antimicrobial names as used by `AMR` or the BNF (`"amoxicillin"`,
  `"Co-amoxiclav"`),

- full ATC codes (`"J01CA04"`) or ATC prefixes that select a whole class
  (`"J01CA"` = aminopenicillins, `"J01M"` = quinolones),

- `AMR` antimicrobial group names (`"Penicillins"`, `"Carbapenems"`),

- anything else, if the `AMR` package is installed: free text, synonyms
  and brand names are resolved with
  [`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html).

## Note

Matches made by
[`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html) can be
fuzzy; check the `via` column and `ab_name`.

## See also

[`bnf_to_ab()`](https://OWNER.github.io/opamr/reference/bnf_to_ab.md),
[`atc_to_bnf()`](https://OWNER.github.io/opamr/reference/atc_to_bnf.md),
[`op_antibiotics()`](https://OWNER.github.io/opamr/reference/op_antibiotics.md)

## Examples

``` r
ab_to_bnf(c("amoxicillin", "AMC", "J01XE01"))
#>         input  ab                     ab_name     atc bnf_chemical_code
#> 1 amoxicillin AMX                 Amoxicillin J01CA04         0501013B0
#> 2 amoxicillin AMX                 Amoxicillin J01CA04         0501013C0
#> 3         AMC AMC Amoxicillin/clavulanic acid J01CR02         0501013K0
#> 4     J01XE01 NIT              Nitrofurantoin J01XE01         0501130R0
#>                                     bnf_name bnf_section           via
#> 1                                Amoxicillin        0501 bundled table
#> 2                         Amoxicillin sodium        0501 bundled table
#> 3 Co-amoxiclav (Amoxicillin/clavulanic acid)        0501 bundled table
#> 4                             Nitrofurantoin        0501 bundled table
ab_to_bnf("doxycycline", output = "codes")
#> [1] "0501030I0" "0501030Z0"
# a whole class by ATC prefix, or by AMR group name
ab_to_bnf("J01MA", output = "codes")
#> [1] "0501120L0" "0501120P0" "0501120Q0" "0501120X0" "0501120Y0"
ab_to_bnf("Aminoglycosides", output = "codes")
#> [1] "0501040H0" "0501040U0"
# include topical / ophthalmic products
ab_to_bnf("chloramphenicol", scope = "all")
#>             input  ab         ab_name     atc bnf_chemical_code        bnf_name
#> 1 chloramphenicol CHL Chloramphenicol J01BA01         0501070F0 Chloramphenicol
#> 2 chloramphenicol CHL Chloramphenicol J01BA01         1103010C0 Chloramphenicol
#> 3 chloramphenicol CHL Chloramphenicol J01BA01         1201010H0 Chloramphenicol
#>   bnf_section           via
#> 1        0501 bundled table
#> 2        1103 bundled table
#> 3        1201 bundled table
```
