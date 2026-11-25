# Small internal helpers -------------------------------------------------------

`%||%` <- function(x, y) if (is.null(x)) y else x

op_org_types <- c("national", "practice", "pcn", "sicbl", "icb", "regional_team")

#' @noRd
check_org_type <- function(org_type) {
  if (length(org_type) != 1L || !is.character(org_type) || !org_type %in% op_org_types) {
    rlang::abort(sprintf("`org_type` must be one of: %s.", paste(op_org_types, collapse = ", ")),
                 class = "opamr_error")
  }
  org_type
}

# Organisation type as the API expects it. The spending and org_details endpoints accept the
# modern names (sicbl, icb); the org_code endpoint only knows the legacy ones (ccg, stp).
#' @noRd
api_org_type <- function(org_type, legacy = FALSE) {
  if (org_type == "national") return(NULL)
  if (!legacy) return(org_type)
  legacy_names <- c(sicbl = "ccg", icb = "stp")
  if (org_type %in% names(legacy_names)) unname(legacy_names[org_type]) else org_type
}

# Convert user dates ("2024-03", "2024-03-01", Date) to first-of-month "YYYY-MM-DD" strings.
#' @noRd
as_op_date <- function(x) {
  if (is.null(x)) return(NULL)
  d <- if (inherits(x, "Date")) x else {
    x <- as.character(x)
    x <- ifelse(grepl("^\\d{4}-\\d{2}$", x), paste0(x, "-01"), x)
    as.Date(x, format = "%Y-%m-%d")
  }
  if (anyNA(d)) rlang::abort("Could not parse `date`; use 'YYYY-MM' or 'YYYY-MM-DD'.", class = "opamr_error")
  if (any(as.integer(format(d, "%d")) != 1L)) {
    rlang::warn("OpenPrescribing data are monthly; dates were moved to the first of the month.")
  }
  unique(format(as.Date(format(d, "%Y-%m-01")), "%Y-%m-%d"))
}

#' @noRd
clean_codes <- function(x, arg = "code") {
  if (is.null(x) || !length(x) || !is.character(x) || anyNA(x)) {
    rlang::abort(sprintf("`%s` must be a non-empty character vector without NA.", arg), class = "opamr_error")
  }
  x <- toupper(trimws(x))
  x <- unique(x[nzchar(x)])
  if (!length(x)) rlang::abort(sprintf("`%s` is empty.", arg), class = "opamr_error")
  x
}

#' @noRd
empty_df <- function(...) {
  cols <- list(...)
  as.data.frame(cols, stringsAsFactors = FALSE)
}

# Column of `df` or NA vector
#' @noRd
col_or_na <- function(df, nm, type = NA_character_) {
  if (nm %in% names(df)) df[[nm]] else rep(type, nrow(df))
}
