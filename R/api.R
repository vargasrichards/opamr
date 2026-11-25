# HTTP layer -------------------------------------------------------------------

.op_cache <- new.env(parent = emptyenv())

#' Clear the opamr response cache
#'
#' Responses are cached for the R session (and optionally on disk, see the
#' `opamr.cache_dir` option). Use this to force fresh requests, for example after the
#' monthly data release.
#'
#' @return `NULL`, invisibly.
#' @export
op_cache_clear <- function() {
  rm(list = ls(.op_cache, all.names = TRUE), envir = .op_cache)
  dir <- getOption("opamr.cache_dir")
  if (!is.null(dir) && dir.exists(dir)) unlink(list.files(dir, pattern = "^opamr_.*\\.rds$", full.names = TRUE))
  invisible(NULL)
}

#' @noRd
op_user_agent <- function() {
  paste0("opamr/", as.character(utils::packageVersion("opamr")), " (R package; research use)")
}

# Perform a GET against the OpenPrescribing API and return the parsed JSON as a data frame.
#' @noRd
op_request <- function(endpoint, query = list()) {
  query <- query[!vapply(query, is.null, logical(1))]
  query$format <- "json"
  base <- getOption("opamr.base_url", "https://openprescribing.net/api/1.0")
  key <- paste(base, endpoint, paste(names(query), unlist(query), sep = "=", collapse = "&"))

  use_cache <- isTRUE(getOption("opamr.cache", TRUE))
  disk <- getOption("opamr.cache_dir")
  disk_file <- if (!is.null(disk)) file.path(disk, paste0("opamr_", rlang::hash(key), ".rds"))
  if (use_cache) {
    if (!is.null(.op_cache[[key]])) return(.op_cache[[key]])
    if (!is.null(disk_file) && file.exists(disk_file)) return(readRDS(disk_file))
  }

  req <- op_build_request(base, endpoint, query)
  resp <- httr2::req_perform(req)
  out <- parse_op_response(resp, endpoint, query)

  if (use_cache) {
    .op_cache[[key]] <- out
    if (!is.null(disk_file)) { dir.create(disk, showWarnings = FALSE, recursive = TRUE); saveRDS(out, disk_file) }
  }
  out
}

# Build the httr2 request (separate from performing it so the retry/throttle policy can be tested).
#' @noRd
op_build_request <- function(base, endpoint, query) {
  req <- httr2::request(base)
  req <- httr2::req_url_path_append(req, endpoint)
  req <- httr2::req_url_query(req, !!!query)
  req <- httr2::req_user_agent(req, op_user_agent())
  req <- httr2::req_timeout(req, getOption("opamr.timeout", 120))
  req <- httr2::req_retry(req, max_tries = getOption("opamr.max_tries", 3),
                          is_transient = function(resp) httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L),
                          backoff = function(i) getOption("opamr.retry_wait", 2^i))
  rate <- getOption("opamr.rate", 2)
  if (is.finite(rate)) req <- httr2::req_throttle(req, rate = rate)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  req
}

#' @noRd
parse_op_response <- function(resp, endpoint, query) {
  status <- httr2::resp_status(resp)
  ctype <- httr2::resp_content_type(resp)
  if (is.na(ctype) || !grepl("json", ctype, fixed = TRUE)) {
    hint <- if (status %in% c(403L, 503L)) {
      paste("The server returned an HTML page (HTTP", status, "), which usually means a bot-protection",
            "challenge. Try again from a normal network connection, reduce the request rate",
            "(options(opamr.rate = 1)), or use the NHSBSA Open Data Portal for bulk extracts.")
    } else paste("Unexpected content type:", ctype)
    rlang::abort(c(sprintf("OpenPrescribing request to '%s' failed (HTTP %s).", endpoint, status), i = hint),
                 class = c("opamr_http_error", "opamr_error"))
  }
  txt <- httr2::resp_body_string(resp)
  if (status >= 400L) {
    rlang::abort(c(sprintf("OpenPrescribing request to '%s' failed (HTTP %s).", endpoint, status),
                   i = substr(txt, 1, 300)), class = c("opamr_http_error", "opamr_error"))
  }
  out <- jsonlite::fromJSON(txt, simplifyVector = TRUE, flatten = TRUE)
  if (is.null(out) || length(out) == 0L) return(data.frame())
  if (!is.data.frame(out)) {
    rlang::abort(c(sprintf("Unexpected response shape from '%s'.", endpoint), i = substr(txt, 1, 200)),
                 class = c("opamr_http_error", "opamr_error"))
  }
  out
}

#' Check that the OpenPrescribing API is reachable
#'
#' Sends one small request (a BNF code lookup) and reports whether valid JSON came back.
#'
#' @return `TRUE` if the API responded with valid JSON, otherwise `FALSE` with a message.
#' @examples
#' \dontrun{
#' op_check_api()
#' }
#' @export
op_check_api <- function() {
  res <- tryCatch(op_request("bnf_code/", list(q = "0501013B0", exact = "true")),
                  error = function(e) e)
  if (inherits(res, "error")) {
    message("OpenPrescribing API not usable: ", conditionMessage(res))
    return(invisible(FALSE))
  }
  invisible(is.data.frame(res))
}
