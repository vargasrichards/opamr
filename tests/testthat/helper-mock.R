# HTTP mocking helpers. The JSON fixtures follow the response schema read from the OpenPrescribing
# server source (api/views_spending.py, views_org_details.py, views_bnf_codes.py,
# views_org_codes.py). They contain made-up numbers; they were not captured from the live API.

json_response <- function(json, status = 200L) {
  httr2::response(status_code = status, headers = list(`Content-Type` = "application/json"),
                  body = charToRaw(json))
}

html_response <- function(status = 403L) {
  httr2::response(status_code = status, headers = list(`Content-Type` = "text/html; charset=UTF-8"),
                  body = charToRaw("<html><title>Just a moment...</title></html>"))
}

# tests never use the cache or the throttle
options(opamr.cache = FALSE, opamr.rate = Inf, opamr.cache_dir = NULL, opamr.retry_wait = 0)

national_json <- function(items = c(100, 120)) {
  sprintf('[{"items": %s, "quantity": 5000, "actual_cost": 250.5, "date": "2025-01-01", "row_id": null, "row_name": "england"},
           {"items": %s, "quantity": 6000, "actual_cost": 300.25, "date": "2025-02-01", "row_id": null, "row_name": "england"}]',
          items[1], items[2])
}

sicbl_json <- '[{"items": 10, "quantity": 400, "actual_cost": 20.5, "date": "2025-01-01", "row_id": "15N", "row_name": "NHS DEVON ICB - 15N"},
                {"items": 12, "quantity": 480, "actual_cost": 24.1, "date": "2025-02-01", "row_id": "15N", "row_name": "NHS DEVON ICB - 15N"},
                {"items": 7,  "quantity": 300, "actual_cost": 15.0, "date": "2025-01-01", "row_id": "02P", "row_name": "NHS SOUTH YORKSHIRE ICB - 02P"}]'

practice_json <- '[{"items": 3, "quantity": 90, "actual_cost": 5.5, "date": "2025-03-01", "row_id": "H81068", "row_name": "A PRACTICE", "ccg": "15N", "setting": 4}]'
