# Spending endpoints ----------------------------------------------------------------

# Convert one parsed spending response to the package's standard layout.
#' @noRd
standardise_spending <- function(df, org_type, code) {
  if (!nrow(df)) {
    return(data.frame(date = as.Date(character()), org_type = character(), org_id = character(),
                      org_name = character(), code = character(), items = numeric(),
                      quantity = numeric(), actual_cost = numeric(), stringsAsFactors = FALSE))
  }
  out <- data.frame(
    date        = as.Date(df$date),
    org_type    = org_type,
    org_id      = if ("row_id" %in% names(df) && !all(is.na(df$row_id))) as.character(df$row_id) else "england",
    org_name    = col_or_na(df, "row_name"),
    code        = code,
    items       = as.numeric(df$items),
    quantity    = as.numeric(col_or_na(df, "quantity", NA_real_)),
    actual_cost = as.numeric(col_or_na(df, "actual_cost", NA_real_)),
    stringsAsFactors = FALSE
  )
  if (org_type == "national") out$org_name <- "England"
  for (extra in c("ccg", "setting")) if (extra %in% names(df)) out[[extra]] <- df[[extra]]
  out
}

#' Prescribing items, quantity and cost from OpenPrescribing
#'
#' Retrieves monthly prescribing totals for one or more BNF codes, nationally or by
#' organisation. Returns tidy data frames with one row per code, organisation and month.
#'
#' @param code Character vector of BNF codes. Any level works (section `"0501"`, chemical
#'   `"0501013B0"`, product, presentation); OpenPrescribing sums everything under a code
#'   prefix. Use [ab_to_bnf()] to obtain chemical codes from antimicrobial names.
#' @param org_type Organisation level: `"national"` (all of England, default), `"sicbl"`
#'   (Sub-ICB Location, formerly CCG), `"icb"`, `"pcn"`, `"practice"` or `"regional_team"`.
#' @param org Optional organisation code(s) (for example a Sub-ICB code such as `"15N"` or
#'   a practice code such as `"H81068"`). For `"practice"`, a Sub-ICB code returns all its
#'   practices. If `NULL`, all organisations of that type are returned.
#' @param date Optional month(s) as `"YYYY-MM"`, `"YYYY-MM-DD"` or `Date`. Required for
#'   `org_type = "practice"` when `org` is `NULL` (the API refuses to return every practice
#'   for every month). Several dates trigger one request per date.
#' @param by_code If `TRUE` (default) one request per code and a `code` column; if `FALSE`
#'   all codes are summed by the API into one series labelled `"code1+code2"`.
#' @param progress Show a progress bar when several requests are needed (default: only in
#'   interactive sessions).
#'
#' @return A data frame with columns `date`, `org_type`, `org_id`, `org_name`, `code`,
#'   `items`, `quantity`, `actual_cost` (and `ccg`, `setting` for practices). `items` counts
#'   prescription items dispensed, `quantity` is in the units of each product (tablets, ml,
#'   ...) and is therefore **not comparable across chemicals or formulations**, `actual_cost`
#'   is in pounds. Months in which an organisation issued no matching item are absent
#'   (they are zeros, not missing data).
#' @details The data are updated monthly with a lag of about two months. Prescribing is
#'   attributed to the practice that issued the prescription; items dispensed outside
#'   England or privately are not included.
#' @seealso [op_spending_ab()] to query by antimicrobial name, [op_org_details()] for
#'   denominators, [op_rate()].
#' @examples
#' \dontrun{
#' # National monthly amoxicillin items
#' op_spending("0501013B0")
#'
#' # Co-amoxiclav in two Sub-ICB Locations
#' op_spending("0501013K0", org_type = "sicbl", org = c("15N", "02P"))
#'
#' # All practices in one Sub-ICB, one month
#' op_spending("0501", org_type = "practice", org = "15N", date = "2025-03")
#' }
#' @export
op_spending <- function(code, org_type = "national", org = NULL, date = NULL, by_code = TRUE,
                        progress = interactive()) {
  code <- clean_codes(code)
  org_type <- check_org_type(org_type)
  date <- as_op_date(date)
  if (org_type == "national" && !is.null(org)) {
    rlang::abort("`org` needs an `org_type` other than \"national\".", class = "opamr_error")
  }
  if (org_type == "practice" && is.null(org) && is.null(date)) {
    rlang::abort("For `org_type = \"practice\"` supply `org` (practice or Sub-ICB codes) or `date`.", class = "opamr_error")
  }
  code_sets <- if (by_code) as.list(code) else list(code)
  dates <- if (is.null(date)) list(NULL) else as.list(date)
  grid <- expand.grid(ci = seq_along(code_sets), di = seq_along(dates))
  pb <- if (progress && nrow(grid) > 1L) utils::txtProgressBar(0, nrow(grid), style = 3) else NULL

  parts <- vector("list", nrow(grid))
  for (k in seq_len(nrow(grid))) {
    cs <- code_sets[[grid$ci[k]]]
    query <- list(code = paste(cs, collapse = ","),
                  org_type = api_org_type(org_type),
                  org = if (!is.null(org)) paste(org, collapse = ","),
                  date = dates[[grid$di[k]]])
    endpoint <- if (org_type == "national") "spending/" else "spending_by_org/"
    df <- op_request(endpoint, query)
    parts[[k]] <- standardise_spending(df, org_type, paste(cs, collapse = "+"))
    if (!is.null(pb)) utils::setTxtProgressBar(pb, k)
  }
  if (!is.null(pb)) close(pb)
  out <- do.call(rbind, parts)
  out <- out[order(out$code, out$org_id, out$date), , drop = FALSE]
  rownames(out) <- NULL
  attr(out, "op_query") <- list(org_type = org_type, org = org, date = date, retrieved = Sys.time())
  out
}

#' Prescribing data by antimicrobial name
#'
#' Looks up BNF chemical codes for antimicrobials (names, `AMR` codes, ATC codes or groups, see
#' [ab_to_bnf()]), downloads their prescribing with [op_spending()], and labels the result with
#' the `AMR` code, name and ATC code. When several BNF chemicals belong to one agent (for
#' example doxycycline hyclate and doxycycline monohydrate) they are summed per agent by
#' default.
#'
#' @inheritParams op_spending
#' @inheritParams ab_to_bnf
#' @param x Antimicrobial names, `AMR` codes, ATC codes/prefixes or group names (see
#'   [ab_to_bnf()]).
#' @param aggregate Sum BNF chemicals that map to the same antimicrobial and organisation
#'   (default `TRUE`). Set `FALSE` to keep one row per BNF chemical. `quantity` is summed too, so
#'   treat it with care when the chemicals have different units; prefer `items`.
#' @return A data frame as from [op_spending()] with extra columns `ab`, `ab_name`, `atc`
#'   (and `code` listing the BNF chemical code(s) combined).
#' @examples
#' \dontrun{
#' use <- op_spending_ab(c("amoxicillin", "nitrofurantoin", "doxycycline"))
#' head(use)
#' op_spending_ab("J01MA", org_type = "sicbl", org = "15N")   # quinolones in one Sub-ICB
#' }
#' @export
op_spending_ab <- function(x, org_type = "national", org = NULL, date = NULL,
                           scope = c("systemic", "all"), aggregate = TRUE, use_amr = TRUE,
                           progress = interactive()) {
  scope <- match.arg(scope)
  map <- ab_to_bnf(x, scope = scope, use_amr = use_amr)
  map <- map[!is.na(map$bnf_chemical_code), , drop = FALSE]
  if (!nrow(map)) rlang::abort("None of the inputs could be mapped to a BNF chemical code.", class = "opamr_error")
  codes <- unique(map$bnf_chemical_code)
  sp <- op_spending(codes, org_type = org_type, org = org, date = date, by_code = TRUE, progress = progress)
  info <- unique(map[, c("bnf_chemical_code", "ab", "ab_name", "atc")])
  out <- merge(sp, info, by.x = "code", by.y = "bnf_chemical_code", all.x = TRUE, sort = FALSE)
  if (aggregate && nrow(out)) {
    keys <- intersect(c("date", "org_type", "org_id", "org_name", "ab", "ab_name", "atc", "ccg", "setting"), names(out))
    grp <- do.call(paste, c(out[keys], sep = "\r"))
    sums <- rowsum(out[, c("items", "quantity", "actual_cost")], grp, reorder = FALSE, na.rm = TRUE)
    first <- out[!duplicated(grp), keys, drop = FALSE]
    codes_by <- tapply(out$code, grp, function(z) paste(sort(unique(z)), collapse = "+"))[unique(grp)]
    out <- cbind(first, code = unname(codes_by), sums[unique(grp), , drop = FALSE])
  }
  out <- out[order(out$ab, out$org_id, out$date), , drop = FALSE]
  rownames(out) <- NULL
  first_cols <- c("date", "org_type", "org_id", "org_name", "ab", "ab_name", "atc", "code", "items", "quantity", "actual_cost")
  out <- out[, c(intersect(first_cols, names(out)), setdiff(names(out), first_cols)), drop = FALSE]
  attr(out, "op_query") <- list(x = x, org_type = org_type, org = org, date = date, scope = scope, retrieved = Sys.time())
  out
}
