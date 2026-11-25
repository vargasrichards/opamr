# Check that the OpenPrescribing API is reachable

Sends one small request (a BNF code lookup) and reports whether valid
JSON came back.

## Usage

``` r
op_check_api()
```

## Value

`TRUE` if the API responded with valid JSON, otherwise `FALSE` with a
message.

## Examples

``` r
if (FALSE) { # \dontrun{
op_check_api()
} # }
```
