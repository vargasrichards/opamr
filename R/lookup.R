# Reference lookups ------------------------------------------------------------------

#' Search BNF codes
#'
#' Searches the BNF hierarchy served by OpenPrescribing: sections, chemicals, products and
#' presentations, by name or code prefix.
#'
#' @param q Search string(s): a name fragment (`"amoxicillin"`) or code prefix (`"0501013"`).
#' @param exact Match whole names/codes only (default `FALSE`).
#' @return A data frame with columns `type`, `id` (BNF code or section number), `name` and,
#'   where the API provides them, `section` and `is_generic`.
#' @seealso [ab_to_bnf()] for offline name-to-code conversion
#' @examples
#' \dontrun{
#' op_bnf_search("nitrofurantoin")
#' }
#' @export
op_bnf_search <- function(q, exact = FALSE) {
  q <- trimws(q)
  if (!is.character(q) || !length(q) || any(!nzchar(q))) rlang::abort("`q` must be a non-empty character vector.", class = "opamr_error")
  df <- op_request("bnf_code/", list(q = paste(q, collapse = ","), exact = if (isTRUE(exact)) "true"))
  if (!nrow(df)) return(data.frame(type = character(), id = character(), name = character(), stringsAsFactors = FALSE))
  df
}

#' Search organisation codes
#'
#' Finds Sub-ICB Locations, ICBs, PCNs, practices or regional teams by name or code.
#'
#' @param q Name fragment or code prefix.
#' @param org_type One of `"sicbl"`, `"icb"`, `"pcn"`, `"practice"`, `"regional_team"`.
#' @param exact Match whole names/codes only (default `FALSE`).
#' @return A data frame with at least `id`, `name` and `type` (practices also have
#'   `postcode`, `setting_name` and the parent Sub-ICB in `ccg`).
#' @examples
#' \dontrun{
#' op_org_search("Barnsley", "sicbl")
#' }
#' @export
op_org_search <- function(q, org_type = c("sicbl", "practice", "pcn", "icb", "regional_team"), exact = FALSE) {
  org_type <- match.arg(org_type)
  if (!is.character(q) || length(q) != 1L) rlang::abort("`q` must be a single string.", class = "opamr_error")
  df <- op_request("org_code/", list(q = q, org_type = api_org_type(org_type, legacy = TRUE),
                                     exact = if (isTRUE(exact)) "true"))
  if (!nrow(df)) return(data.frame(id = character(), name = character(), type = character(), stringsAsFactors = FALSE))
  df
}
