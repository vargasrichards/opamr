# Example national antibacterial prescribing, November 2020 to June 2026

Monthly national totals for every BNF chemical substance in section 5.1
(antibacterial drugs) in the crosswalk, in the same layout as the output
of
[`op_spending_ab()`](https://OWNER.github.io/opamr/reference/op_spending_ab.md).
The dataset lets the examples and figures run offline.

## Usage

``` r
op_example
```

## Format

A data frame with columns `date`, `org_type`, `org_id`, `org_name`,
`ab`, `ab_name`, `atc`, `code` (BNF chemical code(s)), `items`,
`quantity`, `actual_cost`.

## Source

NHSBSA Open Data Portal, <https://opendata.nhsbsa.net/>.

## Details

Built from the NHS Business Services Authority English Prescribing
Dataset (EPD, Open Government Licence v3.0), the dataset OpenPrescribing
is derived from, by summing `ITEMS`, `TOTAL_QUANTITY` and `ACTUAL_COST`
per chemical substance and month (see `data-raw/build_example.R`). It
was **not** downloaded from the OpenPrescribing API, so small
differences from API values are possible. BNF chemicals that map to the
same antimicrobial (for example two doxycycline salts) are summed, as
`op_spending_ab(aggregate = TRUE)` does.

## Examples

``` r
head(op_example)
#>         date org_type  org_id org_name  ab                     ab_name     atc
#> 1 2020-11-01 national england  England AMC Amoxicillin/clavulanic acid J01CR02
#> 2 2020-12-01 national england  England AMC Amoxicillin/clavulanic acid J01CR02
#> 3 2021-01-01 national england  England AMC Amoxicillin/clavulanic acid J01CR02
#> 4 2021-02-01 national england  England AMC Amoxicillin/clavulanic acid J01CR02
#> 5 2021-03-01 national england  England AMC Amoxicillin/clavulanic acid J01CR02
#> 6 2021-04-01 national england  England AMC Amoxicillin/clavulanic acid J01CR02
#>        code  items quantity actual_cost
#> 1 0501013K0 101252  3801733    290882.7
#> 2 0501013K0 106519  3996897    307438.1
#> 3 0501013K0 103371  3896844    323383.0
#> 4 0501013K0  92852  3461299    288892.6
#> 5 0501013K0 101757  3780092    315605.7
#> 6 0501013K0  93648  3512243    295717.3
```
