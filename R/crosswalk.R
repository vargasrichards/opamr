# Crosswalk between antimicrobial names / AMR codes / ATC codes and BNF chemical codes ------

#' Antimicrobial crosswalk: BNF chemical substances and AMR package antimicrobials
#'
#' One row per BNF chemical substance that corresponds to an antimicrobial agent in the
#' `AMR` package. Built from the chemical substances present in the NHS Business Services
#' Authority English Prescribing Dataset (December 2025 and June 2026) by matching names with
#' `AMR::as.ab()`, rejecting fuzzy false positives, and applying a short manual override table
#' (`data-raw/manual_overrides.csv`). Several BNF chemicals can map to one AMR agent (salts
#' and routes, for example doxycycline hyclate and monohydrate), and one agent can appear in
#' several BNF chapters (systemic in chapter 5; eye, ear, skin and vaginal products in
#' chapters 7, 11, 12 and 13).
#'
#' Scope: antibacterials (including antimycobacterials) and antifungals, plus topical
#' anti-infectives. Antivirals and antiparasitics are not included because the `AMR`
#' package keeps them in separate datasets (`as.av()`).
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{bnf_chemical_code}{9-character BNF chemical substance code.}
#'   \item{bnf_name}{BNF chemical substance name.}
#'   \item{bnf_chapter, bnf_section, bnf_paragraph}{BNF chapter (2), section (4) and
#'     paragraph (6) codes.}
#'   \item{ab}{`AMR` package antimicrobial code (for example `"AMX"`).}
#'   \item{ab_name}{`AMR` antimicrobial name.}
#'   \item{ab_group}{`AMR` antimicrobial group(s), separated by `" | "`.}
#'   \item{atc}{Primary human ATC code (systemic `J...` code preferred); can be `NA`.}
#'   \item{atc_all}{All human ATC codes for the agent, separated by `"|"`.}
#'   \item{match_method}{`"AMR::as.ab"` (name matching) or `"manual"`.}
#'   \item{amr_version}{Version of the `AMR` package used to build the table.}
#' }
#' @source NHSBSA English Prescribing Dataset, BNF chemical substances (Open Government
#'   Licence v3.0); `AMR` package antimicrobials dataset.
#' @examples
#' head(antibiotic_crosswalk[, c("bnf_chemical_code", "bnf_name", "ab", "atc")])
"antibiotic_crosswalk"

#' @noRd
cw_scope <- function(scope) {
  scope <- match.arg(scope, c("systemic", "all"))
  cw <- opamr::antibiotic_crosswalk
  if (scope == "systemic") cw <- cw[cw$bnf_chapter == "05", , drop = FALSE]
  cw
}

# Normalise a name for dictionary lookups
#' @noRd
norm_key <- function(x) gsub("[^a-z0-9/+ ]", "", tolower(trimws(x)))

# Resolve free-text inputs to AMR antimicrobial codes using the bundled table (offline).
# Recognises AMR codes, full or partial ATC codes (e.g. "J01CA" = aminopenicillins),
# AMR names, BNF names, and AMR group names (e.g. "Penicillins").
# Returns a data frame (input, ab) with one row per resolved agent; unresolved inputs are
# returned with ab = NA.
#' @noRd
resolve_internal <- function(x, cw) {
  agents <- cw[!duplicated(cw$ab), c("ab", "ab_name", "atc", "atc_all", "ab_group")]
  out <- vector("list", length(x))
  atc_list <- strsplit(ifelse(is.na(agents$atc_all), "", agents$atc_all), "|", fixed = TRUE)
  grp_list <- strsplit(ifelse(is.na(agents$ab_group), "", agents$ab_group), " | ", fixed = TRUE)
  # BNF names also act as keys in their short forms: "Co-amoxiclav (Amoxicillin/clavulanic acid)"
  # is reachable as "Co-amoxiclav" and as "Amoxicillin/clavulanic acid"
  bnf_keys <- lapply(cw$bnf_name, function(nm) {
    main <- trimws(sub("\\(.*$", "", nm))
    paren <- trimws(gsub("[()]", "", regmatches(nm, regexpr("\\(.*\\)", nm))))
    unique(norm_key(c(nm, main, paren)))
  })
  for (i in seq_along(x)) {
    xi <- trimws(x[i]); k <- norm_key(xi); hit <- character()
    if (nzchar(xi)) {
      hit <- agents$ab[toupper(agents$ab) == toupper(xi)]
      if (!length(hit) && grepl("^[A-Za-z][0-9]{2}[A-Za-z0-9]*$", xi)) {
        up <- toupper(xi)
        hit <- agents$ab[vapply(atc_list, function(a) any(startsWith(a, up)), logical(1))]
      }
      if (!length(hit)) hit <- agents$ab[norm_key(agents$ab_name) == k]
      if (!length(hit)) hit <- unique(cw$ab[vapply(bnf_keys, function(z) k %in% z, logical(1))])
      if (!length(hit)) hit <- agents$ab[vapply(grp_list, function(g) k %in% norm_key(g), logical(1))]
    }
    out[[i]] <- data.frame(input = xi, ab = if (length(hit)) hit else NA_character_,
                           via = if (length(hit)) "bundled table" else NA_character_, stringsAsFactors = FALSE)
  }
  do.call(rbind, out)
}

# Resolve with the bundled table first, then fall back to AMR::as.ab() for the rest.
#' @noRd
resolve_ab <- function(x, cw, use_amr = TRUE) {
  res <- resolve_internal(x, cw)
  miss <- unique(res$input[is.na(res$ab)])
  if (length(miss) && use_amr && requireNamespace("AMR", quietly = TRUE)) {
    amr <- suppressWarnings(suppressMessages(
      AMR::as.ab(miss, flag_multiple_results = FALSE, info = FALSE)))
    fill <- data.frame(input = miss, ab = as.character(amr),
                       via = ifelse(is.na(as.character(amr)), NA_character_, "AMR::as.ab"), stringsAsFactors = FALSE)
    res <- rbind(res[!is.na(res$ab), ], fill)
    res <- res[order(match(res$input, trimws(x))), ]
  }
  rownames(res) <- NULL
  res
}

#' Convert antimicrobial names, AMR codes or ATC codes to BNF codes
#'
#' Looks up each input in the bundled [antibiotic_crosswalk] and returns the matching BNF
#' chemical substance code(s). Inputs can be:
#'
#' * `AMR` package antimicrobial codes (`"AMX"`),
#' * antimicrobial names as used by `AMR` or the BNF (`"amoxicillin"`, `"Co-amoxiclav"`),
#' * full ATC codes (`"J01CA04"`) or ATC prefixes that select a whole class (`"J01CA"` =
#'   aminopenicillins, `"J01M"` = quinolones),
#' * `AMR` antimicrobial group names (`"Penicillins"`, `"Carbapenems"`),
#' * anything else, if the `AMR` package is installed: free text, synonyms and brand names
#'   are resolved with `AMR::as.ab()`.
#'
#' @param x Character vector of names or codes.
#' @param scope `"systemic"` (default) keeps BNF chapter 5 (infections: oral and injectable
#'   products). `"all"` also returns topical, eye, ear, skin and vaginal chemicals from
#'   chapters 7, 11, 12 and 13, which are prescribed for different purposes and should not
#'   be pooled with systemic use by accident.
#' @param output `"table"` (default) returns one row per input and BNF chemical;
#'   `"codes"` returns the unique BNF chemical codes as a character vector.
#' @param use_amr Use `AMR::as.ab()` for inputs the bundled table cannot resolve (default
#'   `TRUE`; ignored if `AMR` is not installed).
#'
#' @return A data frame with columns `input`, `ab`, `ab_name`, `atc`, `bnf_chemical_code`,
#'   `bnf_name`, `bnf_section` and `via` (how the input was recognised: `"bundled table"` or
#'   `"AMR::as.ab"`), or a character vector of codes if `output = "codes"`. Inputs that cannot
#'   be resolved, or that resolve to an agent with no BNF chemical in `scope`, give a warning
#'   (naming the agent, so fuzzy matches are visible) and a row with `NA` codes. Group and class
#'   inputs silently skip members that have no BNF chemical in `scope`.
#' @note Matches made by `AMR::as.ab()` can be fuzzy; check the `via` column and `ab_name`.
#' @seealso [bnf_to_ab()], [atc_to_bnf()], [op_antibiotics()]
#' @examples
#' ab_to_bnf(c("amoxicillin", "AMC", "J01XE01"))
#' ab_to_bnf("doxycycline", output = "codes")
#' # a whole class by ATC prefix, or by AMR group name
#' ab_to_bnf("J01MA", output = "codes")
#' ab_to_bnf("Aminoglycosides", output = "codes")
#' # include topical / ophthalmic products
#' ab_to_bnf("chloramphenicol", scope = "all")
#' @export
ab_to_bnf <- function(x, scope = c("systemic", "all"), output = c("table", "codes"), use_amr = TRUE) {
  scope <- match.arg(scope); output <- match.arg(output)
  if (!is.character(x) || !length(x)) rlang::abort("`x` must be a non-empty character vector.", class = "opamr_error")
  all_cw <- opamr::antibiotic_crosswalk
  cw <- cw_scope(scope)
  res <- resolve_ab(x, all_cw, use_amr = use_amr)

  # label for agents resolved by AMR::as.ab that are not in the crosswalk (so a wrong fuzzy match is visible)
  amr_label <- function(ab) {
    if (is.na(ab)) return(NA_character_)
    nm <- all_cw$ab_name[match(ab, all_cw$ab)]
    if (is.na(nm) && requireNamespace("AMR", quietly = TRUE)) nm <- tryCatch(AMR::ab_name(ab, language = NULL), error = function(e) NA_character_)
    nm
  }
  resolved <- res[!is.na(res$ab), , drop = FALSE]
  m <- merge(resolved, cw, by = "ab", all.x = TRUE, sort = FALSE)
  m <- m[order(match(m$input, res$input), m$bnf_chemical_code), , drop = FALSE]
  # an input may expand to several agents (class or group inputs): drop agents without a BNF chemical
  # when at least one other agent of the same input has one; otherwise keep an NA row and warn
  has_code <- tapply(!is.na(m$bnf_chemical_code), m$input, any)
  m <- m[!(is.na(m$bnf_chemical_code) & has_code[m$input]), , drop = FALSE]
  no_code <- m[is.na(m$bnf_chemical_code), , drop = FALSE]
  unresolved <- unique(res$input[is.na(res$ab)])
  if (nrow(no_code)) {
    labs <- vapply(seq_len(nrow(no_code)), function(i) {
      nm <- no_code$ab_name[i]; if (is.na(nm)) nm <- amr_label(no_code$ab[i])
      sprintf("%s -> %s%s", shQuote(no_code$input[i]), no_code$ab[i], if (!is.na(nm)) paste0(" (", nm, ")") else "")
    }, "")
    rlang::warn(paste0("Resolved to an antimicrobial, but no BNF chemical in scope '", scope, "': ",
                       paste(unique(labs), collapse = "; "), ". Check the match, or try scope = \"all\"."))
  }
  if (length(unresolved)) rlang::warn(paste0("Could not resolve to an antimicrobial: ", paste(shQuote(unresolved), collapse = ", ")))
  if (length(unresolved)) {
    m <- rbind(m[, intersect(names(m), c("input", "ab", "via", "ab_name", "atc", "bnf_chemical_code", "bnf_name", "bnf_section")), drop = FALSE],
               data.frame(input = unresolved, ab = NA_character_, via = NA_character_, ab_name = NA_character_, atc = NA_character_,
                          bnf_chemical_code = NA_character_, bnf_name = NA_character_, bnf_section = NA_character_,
                          stringsAsFactors = FALSE))
    m <- m[order(match(m$input, res$input)), , drop = FALSE]
  }
  cols <- c("input", "ab", "ab_name", "atc", "bnf_chemical_code", "bnf_name", "bnf_section", "via")
  m <- m[, cols, drop = FALSE]; rownames(m) <- NULL
  if (output == "codes") return(unique(stats::na.omit(m$bnf_chemical_code)))
  m
}

#' Convert BNF codes to AMR package antimicrobial codes
#'
#' Maps BNF codes to the antimicrobial agent they contain. Codes longer than 9 characters
#' (products and presentations, such as the 15-character codes in prescribing data) are
#' truncated to the chemical substance. Codes shorter than 9 characters (chapter, section,
#' paragraph, subparagraph) are expanded to every crosswalk chemical they contain, so
#' `bnf_to_ab("050112")` lists all quinolones.
#'
#' @param code Character vector of BNF codes (any level).
#' @param output `"table"` (default) or `"ab"` for a character vector of unique `AMR` codes.
#' @return A data frame with `input`, `bnf_chemical_code`, `bnf_name`, `ab`, `ab_name`,
#'   `atc`, `ab_group` (one row per input and chemical), or a character vector of `AMR`
#'   codes. Codes not in the crosswalk give a row with `NA` and a warning.
#' @seealso [ab_to_bnf()]
#' @examples
#' bnf_to_ab(c("0501013B0", "0501013B0AAAAAA"))   # chemical, then a 15-char presentation
#' bnf_to_ab("050112", output = "ab")               # all quinolones in BNF paragraph 5.1.12
#' @export
bnf_to_ab <- function(code, output = c("table", "ab")) {
  output <- match.arg(output)
  code <- clean_codes(code)
  cw <- opamr::antibiotic_crosswalk
  rows <- lapply(code, function(cd) {
    key <- if (nchar(cd) >= 9L) substr(cd, 1, 9) else cd
    hit <- if (nchar(cd) >= 9L) cw[cw$bnf_chemical_code == key, ] else cw[startsWith(cw$bnf_chemical_code, key), ]
    if (!nrow(hit)) {
      return(data.frame(input = cd, bnf_chemical_code = NA_character_, bnf_name = NA_character_, ab = NA_character_,
                        ab_name = NA_character_, atc = NA_character_, ab_group = NA_character_, stringsAsFactors = FALSE))
    }
    data.frame(input = cd, hit[, c("bnf_chemical_code", "bnf_name", "ab", "ab_name", "atc", "ab_group")],
               stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows); rownames(out) <- NULL
  miss <- unique(out$input[is.na(out$ab)])
  if (length(miss)) rlang::warn(paste0("Not in the crosswalk: ", paste(miss, collapse = ", ")))
  if (output == "ab") return(unique(stats::na.omit(out$ab)))
  out
}

#' Convert between ATC codes and BNF chemical codes
#'
#' `atc_to_bnf()` accepts full ATC codes or prefixes (`"J01CA"`); `bnf_to_atc()` returns the
#' primary human ATC code for BNF codes of any level.
#'
#' @param atc Character vector of ATC codes or prefixes.
#' @param ... Passed to [ab_to_bnf()] (`scope`, `output`).
#' @inheritParams bnf_to_ab
#' @return `atc_to_bnf()`: as [ab_to_bnf()]. `bnf_to_atc()`: a named character vector of
#'   primary ATC codes, named by input.
#' @examples
#' atc_to_bnf("J01CA", output = "codes")
#' bnf_to_atc(c("0501013B0", "0501130R0"))
#' @export
atc_to_bnf <- function(atc, ...) {
  if (!is.character(atc)) rlang::abort("`atc` must be a character vector.", class = "opamr_error")
  ab_to_bnf(toupper(trimws(atc)), use_amr = FALSE, ...)
}

#' @rdname atc_to_bnf
#' @export
bnf_to_atc <- function(code) {
  res <- suppressWarnings(bnf_to_ab(code))
  stats::setNames(res$atc, res$input)
}

#' List the antimicrobials in the crosswalk
#'
#' Convenience filter on [antibiotic_crosswalk].
#'
#' @param scope `"systemic"` (BNF chapter 5, default) or `"all"`.
#' @param section Optional BNF section or paragraph prefixes to keep (for example `"0501"`,
#'   `"050112"`).
#' @param ab_group Optional `AMR` group name(s) to keep (matched case-insensitively against
#'   any group of the agent, for example `"Penicillins"`).
#' @return A data frame (subset of [antibiotic_crosswalk]) with an added `bnf_class` column
#'   giving the BNF paragraph label where known.
#' @examples
#' head(op_antibiotics(section = "050112"))
#' op_antibiotics(ab_group = "Carbapenems")[, c("bnf_chemical_code", "ab_name")]
#' @export
op_antibiotics <- function(scope = c("systemic", "all"), section = NULL, ab_group = NULL) {
  scope <- match.arg(scope)
  cw <- cw_scope(scope)
  if (!is.null(section)) {
    section <- toupper(section)
    keep <- Reduce(`|`, lapply(section, function(s) startsWith(cw$bnf_chemical_code, s)))
    cw <- cw[keep, , drop = FALSE]
  }
  if (!is.null(ab_group)) {
    g <- norm_key(ab_group)
    keep <- vapply(strsplit(ifelse(is.na(cw$ab_group), "", cw$ab_group), " | ", fixed = TRUE),
                   function(x) any(norm_key(x) %in% g), logical(1))
    cw <- cw[keep, , drop = FALSE]
  }
  cw$bnf_class <- bnf_class(cw$bnf_chemical_code)
  rownames(cw) <- NULL
  cw
}
