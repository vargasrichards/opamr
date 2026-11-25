# Organisation details (denominators) and rates -----------------------------------------

#' Practice list size and STAR-PU by organisation
#'
#' Downloads monthly denominators from OpenPrescribing: total registered patients
#' (`total_list_size`), ASTRO-PU (`astro_pu_items`, `astro_pu_cost`) and STAR-PU weights
#' (for example `star_pu.oral_antibacterial_items`), summed to the requested organisation
#' level.
#'
#' @param org_type,org As in [op_spending()]. For `"national"` all practices in England are
#'   summed.
#' @param keys Statistics to return: any of `"total_list_size"`, `"astro_pu_items"`,
#'   `"astro_pu_cost"` and STAR-PU keys of the form `"star_pu.<name>"` such as
#'   `"star_pu.oral_antibacterial_items"` (the standard weighting for oral antibacterial
#'   prescribing). Default `"total_list_size"`.
#' @return A data frame with `date`, `org_type`, `org_id`, `org_name` and one numeric column
#'   per key (dots replaced by underscores, for example `star_pu_oral_antibacterial_items`).
#' @examples
#' \dontrun{
#' op_org_details("sicbl", org = c("15N", "02P"),
#'                keys = c("total_list_size", "star_pu.oral_antibacterial_items"))
#' }
#' @export
op_org_details <- function(org_type = "national", org = NULL, keys = "total_list_size") {
  org_type <- check_org_type(org_type)
  if (org_type == "national" && !is.null(org)) {
    rlang::abort("`org` needs an `org_type` other than \"national\".", class = "opamr_error")
  }
  df <- op_request("org_details/", list(org_type = api_org_type(org_type),
                                        org = if (!is.null(org)) paste(org, collapse = ","),
                                        keys = paste(keys, collapse = ",")))
  if (!nrow(df)) return(data.frame())
  names(df) <- gsub(".", "_", names(df), fixed = TRUE)
  out <- data.frame(date = as.Date(df$date), org_type = org_type,
                    org_id = if ("row_id" %in% names(df)) as.character(df$row_id) else "england",
                    org_name = if (org_type == "national") "England" else col_or_na(df, "row_name"),
                    stringsAsFactors = FALSE)
  stat_cols <- setdiff(names(df), c("date", "row_id", "row_name"))
  for (cn in stat_cols) out[[cn]] <- as.numeric(df[[cn]])
  out <- out[order(out$org_id, out$date), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' Convert counts to rates per population or weighted-population denominator
#'
#' Joins prescribing data to denominators by month (and organisation) and computes
#' `numerator / denominator * per`.
#'
#' @param x Data frame from [op_spending()] or [op_spending_ab()].
#' @param details Data frame from [op_org_details()] at the same organisation level.
#' @param numerator Column of `x` to use (default `"items"`).
#' @param denominator Column of `details` (default `"total_list_size"`; for antibacterial
#'   prescribing `"star_pu_oral_antibacterial_items"` is the usual age-sex weighted choice).
#' @param per Scaling factor (default `1000`).
#' @param name Name of the new column. Default `"rate"`.
#' @return `x` with the denominator and the new rate column added; the rate definition is
#'   stored in the `"rate_label"` attribute and used by the plotting functions for axis
#'   labels. Rows without a matching denominator get `NA`.
#' @examples
#' x <- data.frame(date = as.Date(c("2025-01-01", "2025-02-01")), org_id = "A",
#'                 items = c(120, 150))
#' d <- data.frame(date = as.Date(c("2025-01-01", "2025-02-01")), org_id = "A",
#'                 total_list_size = c(60000, 60100))
#' op_rate(x, d)
#' @export
op_rate <- function(x, details, numerator = "items", denominator = "total_list_size", per = 1000, name = "rate") {
  stopifnot(is.data.frame(x), is.data.frame(details))
  if (!numerator %in% names(x)) rlang::abort(sprintf("`x` has no column '%s'.", numerator), class = "opamr_error")
  if (!denominator %in% names(details)) rlang::abort(sprintf("`details` has no column '%s'.", denominator), class = "opamr_error")
  by <- intersect(c("date", "org_id"), intersect(names(x), names(details)))
  if (!"date" %in% by) rlang::abort("Both tables need a `date` column.", class = "opamr_error")
  if (denominator %in% names(x)) x[[denominator]] <- NULL   # replaced by the joined denominator
  det <- unique(details[, c(by, denominator), drop = FALSE])
  if (anyDuplicated(det[, by, drop = FALSE])) {
    rlang::abort("`details` has several rows per date/organisation; supply one denominator per month.", class = "opamr_error")
  }
  ord <- seq_len(nrow(x))
  out <- merge(cbind(x, .ord = ord), det, by = by, all.x = TRUE, sort = FALSE)
  out <- out[order(out$.ord), , drop = FALSE]; out$.ord <- NULL
  out[[name]] <- out[[numerator]] / out[[denominator]] * per
  if (anyNA(out[[name]])) rlang::warn("Some rows have no matching denominator; their rate is NA.")
  rownames(out) <- NULL
  attr(out, "rate_label") <- sprintf("%s per %s %s", numerator, format(per, big.mark = ",", scientific = FALSE),
                                     sub("^total_list_size$", "registered patients", sub("^star_pu_", "STAR-PU: ", denominator)))
  attr(out, "op_query") <- attr(x, "op_query")
  out
}

#' Antimicrobial use as a rate, in one call
#'
#' Combines [op_spending_ab()], [op_org_details()] and [op_rate()]: downloads prescribing for
#' the requested antimicrobials, downloads the denominator at the same organisation level,
#' and returns items per 1,000 registered patients (or another denominator).
#'
#' @inheritParams op_spending_ab
#' @param denominator Denominator key from [op_org_details()]; default `"total_list_size"`.
#'   `"star_pu.oral_antibacterial_items"` gives STAR-PU weighted rates.
#' @param per Scaling factor (default 1000).
#' @return A data frame as from [op_spending_ab()] plus the denominator column and `rate`.
#' @examples
#' \dontrun{
#' use <- op_antibiotic_use(c("amoxicillin", "nitrofurantoin"), org_type = "sicbl", org = "15N")
#' op_plot_trend(use, y = "rate")
#' }
#' @export
op_antibiotic_use <- function(x, org_type = "national", org = NULL, date = NULL,
                              denominator = "total_list_size", per = 1000,
                              scope = c("systemic", "all"), use_amr = TRUE, progress = interactive()) {
  sp <- op_spending_ab(x, org_type = org_type, org = org, date = date, scope = scope,
                       use_amr = use_amr, progress = progress)
  det <- op_org_details(org_type = org_type, org = org, keys = denominator)
  op_rate(sp, det, numerator = "items", denominator = gsub(".", "_", denominator, fixed = TRUE), per = per)
}
