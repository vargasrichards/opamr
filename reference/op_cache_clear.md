# Clear the opamr response cache

Responses are cached for the R session (and optionally on disk, see the
`opamr.cache_dir` option). Use this to force fresh requests, for example
after the monthly data release.

## Usage

``` r
op_cache_clear()
```

## Value

`NULL`, invisibly.
