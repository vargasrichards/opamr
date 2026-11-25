mock_router <- function(routes) {
  force(routes)
  function(req) {
    path <- sub("^.*/api/1\\.0/", "", sub("\\?.*$", "", req$url))
    for (nm in names(routes)) if (identical(nm, path)) return(routes[[nm]](req))
    stop("unexpected request path: ", path)
  }
}
query_of <- function(req) httr2::url_parse(req$url)$query

test_that("op_spending returns tidy national data", {
  httr2::local_mocked_responses(mock_router(list(`spending/` = function(req) {
    q <- query_of(req)
    expect_equal(q$code, "0501013B0"); expect_equal(q$format, "json"); expect_null(q$org_type)
    json_response(national_json())
  })))
  x <- op_spending("0501013b0")
  expect_equal(names(x)[1:8], c("date", "org_type", "org_id", "org_name", "code", "items", "quantity", "actual_cost"))
  expect_s3_class(x$date, "Date")
  expect_equal(x$items, c(100, 120))
  expect_equal(unique(x$org_id), "england"); expect_equal(unique(x$org_name), "England")
  expect_equal(unique(x$code), "0501013B0")
})

test_that("op_spending by Sub-ICB sends org_type and org, and parses organisations", {
  httr2::local_mocked_responses(mock_router(list(`spending_by_org/` = function(req) {
    q <- query_of(req)
    expect_equal(q$org_type, "sicbl"); expect_equal(q$org, "15N,02P")
    json_response(sicbl_json)
  })))
  x <- op_spending("0501013K0", org_type = "sicbl", org = c("15N", "02P"))
  expect_setequal(x$org_id, c("15N", "02P"))
  expect_equal(nrow(x), 3L)
  expect_true(all(diff(as.numeric(x$date[x$org_id == "15N"])) > 0))
})

test_that("practice queries need org or date and keep practice attributes", {
  expect_error(op_spending("0501", org_type = "practice"), "supply `org`")
  httr2::local_mocked_responses(mock_router(list(`spending_by_org/` = function(req) {
    expect_equal(query_of(req)$date, "2025-03-01")
    json_response(practice_json)
  })))
  x <- op_spending("0501", org_type = "practice", date = "2025-03")
  expect_equal(x$ccg, "15N"); expect_equal(x$org_id, "H81068")
})

test_that("several codes and dates trigger one request each", {
  n <- 0L
  httr2::local_mocked_responses(mock_router(list(`spending_by_org/` = function(req) {
    n <<- n + 1L; json_response(sicbl_json)
  })))
  x <- op_spending(c("0501013B0", "0501013K0"), org_type = "sicbl", date = c("2025-01", "2025-02"), progress = FALSE)
  expect_equal(n, 4L)
  expect_setequal(x$code, c("0501013B0", "0501013K0"))
  n <- 0L
  y <- op_spending(c("0501013B0", "0501013K0"), org_type = "sicbl", date = "2025-01", by_code = FALSE)
  expect_equal(n, 1L); expect_equal(unique(y$code), "0501013B0+0501013K0")
})

test_that("empty responses give an empty typed data frame", {
  httr2::local_mocked_responses(function(req) json_response("[]"))
  x <- op_spending("0501999")
  expect_equal(nrow(x), 0L); expect_true(all(c("date", "items") %in% names(x)))
})

test_that("input validation for op_spending", {
  expect_error(op_spending(character()), "non-empty")
  expect_error(op_spending("0501", org_type = "county"), "must be one of")
  expect_error(op_spending("0501", org = "15N"), "needs an `org_type`")
  expect_warning(as_op_date("2025-03-15"), "first of the month")
})

test_that("HTML bot-protection pages give an informative error", {
  httr2::local_mocked_responses(function(req) html_response(403L))
  expect_error(op_spending("0501013B0"), "bot-protection", class = "opamr_http_error")
  expect_false(suppressMessages(op_check_api()))
})

test_that("JSON error statuses are reported", {
  httr2::local_mocked_responses(function(req) json_response('{"detail": "bad"}', status = 400L))
  expect_error(op_spending("0501013B0"), "HTTP 400", class = "opamr_http_error")
})

test_that("op_spending_ab aggregates BNF chemicals per antimicrobial", {
  seen <- character()
  httr2::local_mocked_responses(mock_router(list(`spending/` = function(req) {
    seen <<- c(seen, query_of(req)$code); json_response(national_json())
  })))
  x <- op_spending_ab("doxycycline")
  expect_setequal(seen, c("0501030I0", "0501030Z0"))
  expect_equal(nrow(x), 2L)                       # two months, two chemicals summed per month
  expect_equal(x$items, c(200, 240))
  expect_equal(unique(x$ab), "DOX"); expect_equal(unique(x$code), "0501030I0+0501030Z0")
  expect_equal(unique(x$atc), "J01AA02")
  y <- op_spending_ab("doxycycline", aggregate = FALSE)
  expect_equal(nrow(y), 4L)
  expect_error(suppressWarnings(op_spending_ab("zzzzqq", use_amr = FALSE)), "None of the inputs")
})

test_that("op_org_details flattens STAR-PU and handles national and organisation rows", {
  httr2::local_mocked_responses(mock_router(list(`org_details/` = function(req) {
    q <- query_of(req)
    expect_equal(q$keys, "total_list_size,star_pu.oral_antibacterial_items")
    json_response('[{"date": "2025-01-01", "total_list_size": 60000, "star_pu": {"oral_antibacterial_items": 61000.5}},
                    {"date": "2025-02-01", "total_list_size": 60100, "star_pu": {"oral_antibacterial_items": 61100.25}}]')
  })))
  d <- op_org_details(keys = c("total_list_size", "star_pu.oral_antibacterial_items"))
  expect_equal(d$total_list_size, c(60000, 60100))
  expect_equal(d$star_pu_oral_antibacterial_items, c(61000.5, 61100.25))
  expect_equal(unique(d$org_id), "england")
})

test_that("op_rate joins on date and organisation and labels the rate", {
  x <- data.frame(date = as.Date(rep(c("2025-01-01", "2025-02-01"), 2)), org_id = rep(c("A", "B"), each = 2), items = c(60, 90, 30, 45))
  d <- data.frame(date = x$date, org_id = x$org_id, total_list_size = c(60000, 60000, 30000, 30000))
  r <- op_rate(x, d)
  expect_equal(r$rate, c(1, 1.5, 1, 1.5))
  expect_equal(r$items, x$items)                   # row order preserved
  expect_match(attr(r, "rate_label"), "per 1,000 registered patients")
  expect_warning(op_rate(x, d[-1, ]), "no matching denominator")
  conflicting <- d; conflicting$total_list_size <- conflicting$total_list_size * 2
  expect_error(op_rate(x, rbind(d, conflicting)), "several rows")
  expect_equal(op_rate(x, rbind(d, d))$rate, r$rate)   # identical duplicate rows are harmless
})

test_that("op_rate works with national data (join on date only)", {
  x <- data.frame(date = as.Date(c("2025-01-01", "2025-02-01")), org_id = "england", items = c(100, 200))
  d <- data.frame(date = x$date, total_list_size = c(1e6, 1e6))
  expect_equal(op_rate(x, d, per = 100000)$rate, c(10, 20))
})

test_that("op_antibiotic_use chains spending, details and rate", {
  httr2::local_mocked_responses(mock_router(list(
    `spending_by_org/` = function(req) json_response(sicbl_json),
    `org_details/` = function(req) json_response(
      '[{"date": "2025-01-01", "row_id": "15N", "row_name": "DEVON", "total_list_size": 1000},
        {"date": "2025-02-01", "row_id": "15N", "row_name": "DEVON", "total_list_size": 1000},
        {"date": "2025-01-01", "row_id": "02P", "row_name": "SY", "total_list_size": 500}]'))))
  u <- op_antibiotic_use("co-amoxiclav", org_type = "sicbl", org = c("15N", "02P"))
  expect_equal(u$rate[u$org_id == "15N"], c(10, 12))
  expect_equal(u$rate[u$org_id == "02P"], 14)
})

test_that("lookups hit the right endpoints with legacy org types for org_code", {
  httr2::local_mocked_responses(mock_router(list(
    `bnf_code/` = function(req) { expect_equal(query_of(req)$exact, "true")
      json_response('[{"type": "chemical", "id": "0501130R0", "name": "Nitrofurantoin", "section": "5.1.13"}]') },
    `org_code/` = function(req) { expect_equal(query_of(req)$org_type, "ccg")
      json_response('[{"id": "02P", "code": "02P", "name": "NHS SOUTH YORKSHIRE ICB - 02P", "type": "CCG"}]') })))
  expect_equal(op_bnf_search("nitrofurantoin", exact = TRUE)$id, "0501130R0")
  expect_equal(op_org_search("south yorkshire", "sicbl")$id, "02P")
})

test_that("responses are cached for the session when caching is on", {
  n <- 0L
  httr2::local_mocked_responses(function(req) { n <<- n + 1L; json_response(national_json()) })
  op <- options(opamr.cache = TRUE); on.exit(options(op), add = TRUE)
  op_cache_clear()
  op_spending("0501013B0"); op_spending("0501013B0")
  expect_equal(n, 1L)
  op_cache_clear(); op_spending("0501013B0")
  expect_equal(n, 2L)
})

test_that("the on-disk cache persists responses across in-memory cache clears", {
  dir <- withr::local_tempdir()
  n <- 0L
  httr2::local_mocked_responses(function(req) { n <<- n + 1L; json_response(national_json()) })
  withr::local_options(opamr.cache = TRUE, opamr.cache_dir = dir)
  rm(list = ls(opamr:::.op_cache, all.names = TRUE), envir = opamr:::.op_cache)
  a <- op_spending("0501013B0")
  expect_equal(n, 1L)
  expect_length(list.files(dir, pattern = "^opamr_.*\\.rds$"), 1L)
  rm(list = ls(opamr:::.op_cache, all.names = TRUE), envir = opamr:::.op_cache)   # memory only
  b <- op_spending("0501013B0")
  expect_equal(n, 1L)                                   # served from disk
  expect_equal(a, b, ignore_attr = TRUE)
  op_cache_clear()                                      # clears disk too
  expect_length(list.files(dir, pattern = "^opamr_.*\\.rds$"), 0L)
})

test_that("requests retry transient failures only, with configurable attempts", {
  # httr2's mocking bypasses its retry loop, so the retry policy is checked on the built request
  req <- op_build_request("https://example.org/api/1.0", "spending/", list(code = "0501", format = "json"))
  transient <- req$policies$retry_is_transient
  expect_true(transient(httr2::response(503)))
  expect_true(transient(httr2::response(429)))
  expect_false(transient(httr2::response(404)))
  expect_false(transient(httr2::response(200)))
  expect_equal(req$policies$retry_max_tries, 3)
  withr::local_options(opamr.max_tries = 5, opamr.retry_wait = 0.5)
  req2 <- op_build_request("https://example.org/api/1.0", "spending/", list())
  expect_equal(req2$policies$retry_max_tries, 5)
  expect_equal(req2$policies$retry_backoff(1), 0.5)
  expect_match(req2$url, "/api/1.0/spending/")
})

test_that("non-JSON error pages are reported once, not retried as data", {
  calls <- 0L
  httr2::local_mocked_responses(function(req) { calls <<- calls + 1L; json_response('{"detail": "no"}', status = 404L) })
  expect_error(op_spending("0501013B0"), "HTTP 404")
  expect_equal(calls, 1L)
})

test_that("requests identify the package in the user agent", {
  ua <- NULL
  httr2::local_mocked_responses(function(req) { ua <<- req$options$useragent; json_response(national_json()) })
  op_spending("0501013B0")
  expect_match(ua, "^opamr/")
})

test_that("op_org_details at Sub-ICB level keeps organisations and handles empty responses", {
  httr2::local_mocked_responses(mock_router(list(`org_details/` = function(req) {
    q <- query_of(req); expect_equal(q$org_type, "sicbl"); expect_equal(q$org, "15N")
    json_response('[{"date": "2025-01-01", "row_id": "15N", "row_name": "DEVON", "total_list_size": 1200000}]')
  })))
  d <- op_org_details("sicbl", org = "15N")
  expect_equal(d$org_id, "15N"); expect_equal(d$org_name, "DEVON"); expect_equal(d$total_list_size, 1.2e6)
  httr2::local_mocked_responses(function(req) json_response("[]"))
  expect_equal(nrow(op_org_details("sicbl", org = "ZZZ")), 0L)
  expect_error(op_org_details(org = "15N"), "needs an `org_type`")
})

test_that("op_spending_ab with scope = 'all' requests topical chemicals too", {
  seen <- character()
  httr2::local_mocked_responses(mock_router(list(`spending/` = function(req) {
    seen <<- c(seen, query_of(req)$code); json_response(national_json())
  })))
  op_spending_ab("chloramphenicol", use_amr = FALSE)
  expect_equal(seen, "0501070F0")
  seen <- character()
  x <- op_spending_ab("chloramphenicol", scope = "all", use_amr = FALSE)
  expect_gt(length(seen), 1L)
  expect_equal(unique(x$ab), "CHL")
  expect_equal(x$items, c(100, 120) * length(seen))     # all chemicals summed into one agent series
})

test_that("op_spending records the query in an attribute", {
  httr2::local_mocked_responses(function(req) json_response(sicbl_json))
  x <- op_spending("0501", org_type = "sicbl", org = "15N")
  q <- attr(x, "op_query")
  expect_equal(q$org_type, "sicbl"); expect_equal(q$org, "15N")
  expect_s3_class(q$retrieved, "POSIXct")
})

test_that("lookups validate input and return typed empty frames when nothing matches", {
  expect_error(op_bnf_search(character()), "non-empty")
  expect_error(op_bnf_search(""), "non-empty")
  expect_error(op_org_search(c("a", "b"), "sicbl"), "single string")
  expect_error(op_org_search("a", "ccg"), "should be one of")
  httr2::local_mocked_responses(function(req) json_response("[]"))
  b <- op_bnf_search("zzzz")
  expect_equal(nrow(b), 0L); expect_equal(names(b), c("type", "id", "name"))
  o <- op_org_search("zzzz", "practice")
  expect_equal(nrow(o), 0L); expect_equal(names(o), c("id", "name", "type"))
})

test_that("op_org_search sends legacy org types only where the endpoint needs them", {
  seen <- character()
  httr2::local_mocked_responses(function(req) { seen <<- c(seen, query_of(req)$org_type); json_response("[]") })
  for (t in c("sicbl", "icb", "practice", "pcn", "regional_team")) op_org_search("x", t)
  expect_equal(seen, c("ccg", "stp", "practice", "pcn", "regional_team"))   # regression: practice was NA
})
