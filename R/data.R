#' Example national antibacterial prescribing, November 2020 to June 2026
#'
#' Monthly national totals for every BNF chemical substance in section 5.1 (antibacterial
#' drugs) in the crosswalk, in the same layout as the output of [op_spending_ab()]. The
#' dataset lets the examples and figures run offline.
#'
#' @details Built from the NHS Business Services Authority English Prescribing Dataset
#'   (EPD, Open Government Licence v3.0), the dataset OpenPrescribing is derived from, by
#'   summing `ITEMS`, `TOTAL_QUANTITY` and `ACTUAL_COST` per chemical substance and month
#'   (see `data-raw/build_example.R`). It was **not** downloaded from the OpenPrescribing API,
#'   so small differences from API values are possible. BNF chemicals that map to the same
#'   antimicrobial (for example two doxycycline salts) are summed, as
#'   `op_spending_ab(aggregate = TRUE)` does.
#' @format A data frame with columns `date`, `org_type`, `org_id`, `org_name`, `ab`, `ab_name`,
#'   `atc`, `code` (BNF chemical code(s)), `items`, `quantity`, `actual_cost`.
#' @source NHSBSA Open Data Portal, <https://opendata.nhsbsa.net/>.
#' @examples
#' head(op_example)
"op_example"
