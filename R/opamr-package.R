#' opamr: antibiotic prescribing data from OpenPrescribing, linked to the AMR package
#'
#' @description
#' `opamr` has three layers:
#'
#' 1. **Crosswalk** - [ab_to_bnf()], [bnf_to_ab()], [atc_to_bnf()], [bnf_to_atc()] and
#'    [op_antibiotics()] move between antimicrobial names / `AMR` package codes / ATC codes
#'    and BNF chemical codes, using the bundled [antibiotic_crosswalk] table. The `AMR`
#'    package is optional: it is only used to resolve free-text names, synonyms and
#'    brand names that the bundled table does not recognise.
#' 2. **Data access** - [op_spending()], [op_spending_ab()], [op_org_details()],
#'    [op_rate()], [op_antibiotic_use()], [op_bnf_search()] and [op_org_search()] wrap the
#'    OpenPrescribing API.
#' 3. **Figures** - [theme_op()], [scale_colour_op()], [op_plot_trend()],
#'    [op_plot_seasonal()], [op_plot_distribution()], [op_plot_heatmap()] and
#'    [op_save()].
#'
#' @section Data source and licence:
#' Prescribing data are published monthly by the NHS Business Services Authority under the
#' Open Government Licence v3.0 and served by the Bennett Institute for Applied Data Science
#' (University of Oxford) through OpenPrescribing. Cite both when publishing. The data cover
#' prescriptions issued in English primary care and dispensed in the community; they
#' contain items, quantities and costs, **not** indications, doses or patients.
#'
#' @section Options:
#' * `opamr.base_url` - API root (default `https://openprescribing.net/api/1.0`).
#' * `opamr.rate` - maximum requests per second (default `2`; `Inf` disables throttling).
#' * `opamr.cache` - cache responses for the R session (default `TRUE`).
#' * `opamr.cache_dir` - optional directory for a persistent on-disk response cache.
#' * `opamr.timeout` - request timeout in seconds (default `120`).
#' * `opamr.max_tries` - attempts for transient failures (HTTP 429/5xx; default `3`).
#' * `opamr.retry_wait` - seconds to wait between attempts (default exponential: 2, 4, ...).
#'
#' @keywords internal
#' @importFrom rlang .data
"_PACKAGE"

utils::globalVariables(c("ab", "ab_group", "atc", "atc_all", "bnf_chemical_code", "bnf_name",
                         "bnf_chapter", "bnf_section", "bnf_paragraph"))
