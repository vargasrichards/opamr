# Save a figure at journal size

Wrapper around
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
with standard journal widths, 300 dpi, and sensible devices: `ragg` for
PNG/TIFF when installed, Cairo for PDF, and vector SVG/PDF/EPS.

## Usage

``` r
op_save(
  plot,
  filename,
  width = "single",
  height = NULL,
  aspect = 0.62,
  dpi = 300
)
```

## Arguments

- plot:

  A ggplot object.

- filename:

  Output file; the extension picks the format (png, pdf, svg, tiff,
  eps).

- width:

  `"single"` (85 mm), `"onehalf"` (120 mm), `"double"` (178 mm), or a
  number in millimetres.

- height:

  Height in mm; default `width * aspect`.

- aspect:

  Height / width when `height` is `NULL` (default 0.62).

- dpi:

  Resolution for raster formats (default 300).

## Value

The file path, invisibly.

## Examples

``` r
p <- op_plot_trend(op_example[op_example$ab_name %in% c("Amoxicillin", "Doxycycline"), ], y = "items")
f <- op_save(p, tempfile(fileext = ".png"), width = "single")
file.exists(f)
#> [1] TRUE
```
