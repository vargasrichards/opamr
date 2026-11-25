# Antimicrobial names, AMR codes, ATC codes and BNF codes

Prescribing and resistance data use different vocabularies for the same
drug:

| Vocabulary | Example for co-amoxiclav | Used by |
|----|----|----|
| BNF chemical code | `0501013K0` | NHS prescribing data, OpenPrescribing |
| `AMR` code | `AMC` | the `AMR` package, susceptibility test results |
| ATC code | `J01CR02` | WHO, ESAC-Net, GLASS, defined daily doses |
| Name | Amoxicillin/clavulanic acid | everyone, spelled in different ways |

`opamr` translates between them with the bundled `antibiotic_crosswalk`
table.

## The crosswalk table

``` r

dim(antibiotic_crosswalk)
#> [1] 121  12
head(antibiotic_crosswalk[, c("bnf_chemical_code", "bnf_name", "ab", "ab_name", "atc")], 8)
#>   bnf_chemical_code                                   bnf_name  ab
#> 1         0501011J0     Benzylpenicillin sodium (Penicillin G) PEN
#> 2         0501011P0     Phenoxymethylpenicillin (Penicillin V) PHN
#> 3         0501012G0                      Flucloxacillin sodium FLC
#> 4         0501013B0                                Amoxicillin AMX
#> 5         0501013C0                         Amoxicillin sodium AMX
#> 6         0501013E0                                 Ampicillin AMP
#> 7         0501013K0 Co-amoxiclav (Amoxicillin/clavulanic acid) AMC
#> 8         0501014S0      Piperacillin sodium/tazobactam sodium TZP
#>                       ab_name     atc
#> 1            Benzylpenicillin J01CE01
#> 2     Phenoxymethylpenicillin J01CE02
#> 3              Flucloxacillin J01CF05
#> 4                 Amoxicillin J01CA04
#> 5                 Amoxicillin J01CA04
#> 6                  Ampicillin J01CA01
#> 7 Amoxicillin/clavulanic acid J01CR02
#> 8     Piperacillin/tazobactam J01CR05
```

The table has one row per BNF chemical substance. Several chemicals can
map to one antimicrobial, one for each salt or formulation:

``` r

sys <- antibiotic_crosswalk[antibiotic_crosswalk$bnf_chapter == "05", ]
dup <- sys[sys$ab %in% sys$ab[duplicated(sys$ab)], c("ab_name", "bnf_chemical_code", "bnf_name")]
dup[order(dup$ab_name), ]
#>         ab_name bnf_chemical_code                    bnf_name
#> 4   Amoxicillin         0501013B0                 Amoxicillin
#> 5   Amoxicillin         0501013C0          Amoxicillin sodium
#> 36  Clindamycin         0501060D0   Clindamycin hydrochloride
#> 37  Clindamycin         0501060E0       Clindamycin phosphate
#> 23  Doxycycline         0501030I0         Doxycycline hyclate
#> 28  Doxycycline         0501030Z0     Doxycycline monohydrate
#> 33 Erythromycin         0501050C0                Erythromycin
#> 34 Erythromycin         0501050H0 Erythromycin ethylsuccinate
#> 35 Erythromycin         0501050N0       Erythromycin stearate
#> 39   Fosfomycin         0501070AE       Fosfomycin trometamol
#> 68   Fosfomycin         0501130S0          Fosfomycin calcium
#> 42 Fusidic acid         0501070M0                Fusidic acid
#> 43 Fusidic acid         0501070N0             Sodium fusidate
```

The same agent also appears in several BNF chapters. Chapter 5 holds
systemic use (oral and injectable). Chapters 7, 11, 12 and 13 hold
vaginal, eye, ear and skin products:

``` r

table(chapter = antibiotic_crosswalk$bnf_chapter)
#> chapter
#> 05 07 11 12 13 
#> 78  6 11  8 18
```

## Converting names and codes to BNF codes

[`ab_to_bnf()`](https://vargasrichards.github.io/opamr/reference/ab_to_bnf.md)
accepts these inputs, and they can be mixed in one call:

``` r

ab_to_bnf(c("AMC",                 # AMR code
            "Co-trimoxazole",      # BNF or common name
            "J01XE01",             # ATC code
            "Carbapenems"),        # AMR group
          use_amr = FALSE)[, c("input", "ab", "bnf_chemical_code", "bnf_name", "via")]
#>            input  ab bnf_chemical_code
#> 1            AMC AMC         0501013K0
#> 2 Co-trimoxazole SXT         0501080D0
#> 3        J01XE01 NIT         0501130R0
#> 4    Carbapenems MEM         0501022A0
#> 5    Carbapenems ETP         0501022B0
#>                                        bnf_name           via
#> 1    Co-amoxiclav (Amoxicillin/clavulanic acid) bundled table
#> 2 Co-trimoxazole(Trimethoprim/sulfamethoxazole) bundled table
#> 3                                Nitrofurantoin bundled table
#> 4                                     Meropenem bundled table
#> 5                              Ertapenem sodium bundled table
```

ATC prefixes select whole classes, following the ATC hierarchy:

``` r

ab_to_bnf("J01C", output = "codes")    # all beta-lactam penicillins
#> [1] "0501011J0" "0501011P0" "0501012G0" "0501013B0" "0501013C0" "0501013E0"
#> [7] "0501013K0" "0501014S0" "0501015P0"
```

### Systemic and topical scope

[`ab_to_bnf()`](https://vargasrichards.github.io/opamr/reference/ab_to_bnf.md)
returns only chapter 5 (systemic) codes by default. Use `scope = "all"`
to include topical and other formulations:

``` r

ab_to_bnf("fusidic acid", output = "codes", use_amr = FALSE)
#> [1] "0501070M0" "0501070N0"
ab_to_bnf("fusidic acid", scope = "all", use_amr = FALSE)[, c("bnf_chemical_code", "bnf_name")]
#>   bnf_chemical_code        bnf_name
#> 1         0501070M0    Fusidic acid
#> 2         0501070N0 Sodium fusidate
#> 3         1103010H0    Fusidic acid
#> 4         1310012F0    Fusidic acid
#> 5         1310012Q0 Sodium fusidate
```

Systemic and topical prescribing measure different exposures. Fusidic
acid cream and fusidic acid tablets, for example, are rarely
interchangeable in an analysis. Keeping them apart by default stops them
being pooled by accident.

### Free text and brand names

If the `AMR` package is installed, inputs that the bundled table does
not recognise are passed to
[`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html). That
function handles brand names, misspellings and synonyms. The `via`
column records how each input was resolved, because
[`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html) matching is
fuzzy:

``` r

ab_to_bnf(c("Augmentin", "amoxycillin", "Macrobid"))[, c("input", "ab_name", "bnf_chemical_code", "via")]
#>         input                     ab_name bnf_chemical_code        via
#> 1   Augmentin Amoxicillin/clavulanic acid         0501013K0 AMR::as.ab
#> 2 amoxycillin                 Amoxicillin         0501013B0 AMR::as.ab
#> 3 amoxycillin                 Amoxicillin         0501013C0 AMR::as.ab
#> 4    Macrobid              Nitrofurantoin         0501130R0 AMR::as.ab
```

If [`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html) picks an
agent with no BNF chemical,
[`ab_to_bnf()`](https://vargasrichards.github.io/opamr/reference/ab_to_bnf.md)
warns and names the agent, so a wrong match is visible rather than
silently returning nothing:

``` r

x <- ab_to_bnf("amikacin")
#> Warning: Resolved to an antimicrobial, but no BNF chemical in scope 'systemic':
#> 'amikacin' -> AMK (Amikacin). Check the match, or try scope = "all".
```

Amikacin is given almost entirely in hospital, so it does not appear in
community prescribing data.

## From BNF codes back to antimicrobials

[`bnf_to_ab()`](https://vargasrichards.github.io/opamr/reference/bnf_to_ab.md)
maps a code of any length:

- longer than 9 characters (product or presentation): truncated to the
  chemical substance;
- exactly 9 characters (chemical substance): looked up directly;
- shorter than 9 characters (section, paragraph, subparagraph): expanded
  to every crosswalk chemical in that part of the BNF.

``` r

bnf_to_ab(c("0501013K0AAAJAJ", "050105"))[, c("input", "bnf_chemical_code", "ab", "ab_name")]
#>             input bnf_chemical_code  ab                     ab_name
#> 1 0501013K0AAAJAJ         0501013K0 AMC Amoxicillin/clavulanic acid
#> 2          050105         0501050A0 AZM                Azithromycin
#> 3          050105         0501050B0 CLR              Clarithromycin
#> 4          050105         0501050C0 ERY                Erythromycin
#> 5          050105         0501050H0 ERY                Erythromycin
#> 6          050105         0501050N0 ERY                Erythromycin
bnf_to_atc(c("0501013B0", "0501120L0", "0501130R0"))
#> 0501013B0 0501120L0 0501130R0 
#> "J01CA04" "J01MA02" "J01XE01"
```

[`bnf_class()`](https://vargasrichards.github.io/opamr/reference/bnf_level.md)
gives the BNF paragraph name, which is a convenient class variable for
prescribing data:

``` r

bnf_class(c("0501013B0", "0501021L0", "0501050B0", "0501130R0"))
#> [1] "Penicillins"                                       
#> [2] "Cephalosporins, carbapenems and other beta-lactams"
#> [3] "Macrolides"                                        
#> [4] "Urinary-tract infections"
```

## Aggregating to antibiotic classes

`op_example` carries `AMR` codes, so `AMR` functions can add class
information. Here the bundled `ab_group` column is used to sum 2025
items by class:

``` r

ex <- op_example[format(op_example$date, "%Y") == "2025", ]
grp <- antibiotic_crosswalk$ab_group[match(ex$ab, antibiotic_crosswalk$ab)]
ex$class <- sub(" \\|.*$", "", grp)                     # first AMR group of each agent
by_class <- aggregate(items ~ class, data = ex, FUN = sum)
head(by_class[order(-by_class$items), ], 8)
#>                    class   items
#> 2       Aminopenicillins 7897310
#> 23         Tetracyclines 4958486
#> 11 Isoxazolylpenicillins 3683396
#> 14           Nitrofurans 3677861
#> 13            Macrolides 2990414
#> 17           Penicillins 2487308
#> 24         Trimethoprims 1840722
#> 15                 Other 1369649
```

The same can be done by BNF paragraph:

``` r

ex$bnf_class <- bnf_class(substr(ex$code, 1, 9))
head(sort(tapply(ex$items, ex$bnf_class, sum), decreasing = TRUE), 6)
#>                                        Penicillins 
#>                                           14068035 
#>                                      Tetracyclines 
#>                                            4958486 
#>                           Urinary-tract infections 
#>                                            4412441 
#>                                         Macrolides 
#>                                            2990414 
#>                      Sulfonamides and trimethoprim 
#>                                            1840722 
#> Cephalosporins, carbapenems and other beta-lactams 
#>                                             901411
```

If `AMR` is installed, its own functions add more information, for
example WHO defined daily doses:

``` r

data.frame(ab = c("AMX", "DOX", "NIT"),
           name = AMR::ab_name(c("AMX", "DOX", "NIT")),
           oral_ddd_g = AMR::ab_ddd(c("AMX", "DOX", "NIT"), administration = "oral"))
#>    ab           name oral_ddd_g
#> 1 AMX    Amoxicillin        1.5
#> 2 DOX    Doxycycline        0.1
#> 3 NIT Nitrofurantoin        0.2
```

Converting prescribing to defined daily doses needs the strength and
pack size of each presentation. OpenPrescribing’s `quantity` (tablets,
ml) does not provide these on its own, so `opamr` reports items.

## How the crosswalk was built, and its limits

- **Source of BNF codes.** Distinct BNF chemical substances in the
  English Prescribing Dataset for December 2025 and June 2026. Chemicals
  not dispensed in the community in those months are absent, such as
  most hospital-only injectables.
- **Matching.** BNF names were matched to `AMR` codes with
  [`AMR::as.ab()`](https://amr-for-r.org/reference/as.ab.html) on
  cleaned name variants, with salt words removed and bracketed synonyms
  split. A match was kept only if the agent’s first non-salt word occurs
  in the BNF name. This rule rejects false matches such as “Sodium
  citrate” to “Sodium aminosalicylate”.
- **Manual corrections.** `data-raw/manual_overrides.csv` in the source
  repository holds nine hand-checked entries. Eight fix a mapping, for
  example colistimethate to colistin and plain ceftazidime rather than
  ceftazidime/avibactam. One records that rifampicin combined
  preparations have no single `AMR` agent, so they are left out of the
  table.
- **Scope.** Antibacterials (including antimycobacterials), antifungals
  and topical anti-infectives. Antivirals and antiparasitics are left
  out because the `AMR` package keeps them in separate datasets.
- **Versions.** Built with `AMR` 3.1.0. Run `data-raw/build_crosswalk.R`
  again after an `AMR` update or a BNF change.

``` r

table(antibiotic_crosswalk$match_method)
#> 
#> AMR::as.ab     manual 
#>        113          8
```
