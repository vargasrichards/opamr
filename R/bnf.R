# BNF code structure -------------------------------------------------------------

# Code length -> hierarchy level (BNF codes as used by NHS prescribing data)
bnf_levels <- c("2" = "chapter", "4" = "section", "6" = "paragraph", "7" = "subparagraph",
                "9" = "chemical", "11" = "product", "15" = "presentation")

# Paragraph / section labels for BNF chapter 5 (infections). Used by bnf_class().
bnf_class_labels <- c(
  "0501"   = "Antibacterial drugs",
  "0502"   = "Antifungal drugs",
  "0503"   = "Antiviral drugs",
  "0504"   = "Antiprotozoal drugs",
  "0505"   = "Anthelmintics",
  "050101" = "Penicillins",
  "050102" = "Cephalosporins, carbapenems and other beta-lactams",
  "050103" = "Tetracyclines",
  "050104" = "Aminoglycosides",
  "050105" = "Macrolides",
  "050106" = "Clindamycin",
  "050107" = "Some other antibacterials",
  "050108" = "Sulfonamides and trimethoprim",
  "050109" = "Antituberculosis drugs",
  "050110" = "Antileprotic drugs",
  "050111" = "Metronidazole and tinidazole",
  "050112" = "Quinolones",
  "050113" = "Urinary-tract infections"
)

#' Describe the structure of BNF codes
#'
#' BNF codes are hierarchical: the first 2 characters give the chapter, 4 the section,
#' 6 the paragraph, 7 the subparagraph, 9 the chemical substance, 11 the product and 15 the
#' presentation. `bnf_level()` reports which level a code is, `bnf_parent()` truncates to a
#' higher level, and `bnf_class()` returns a readable label for chapter 5 sections and
#' paragraphs (antibacterial classes).
#'
#' @param code Character vector of BNF codes (any level).
#' @param level For `bnf_parent()`: one of `"chapter"`, `"section"`, `"paragraph"`,
#'   `"subparagraph"`, `"chemical"`, `"product"`.
#' @param at For `bnf_class()`: `"paragraph"` (default, e.g. `050101` Penicillins) or
#'   `"section"` (e.g. `0501` Antibacterial drugs).
#'
#' @return `bnf_level()` and `bnf_class()` return character vectors (`NA` where the code is
#'   not recognised); `bnf_parent()` returns the truncated codes (`NA` where the code is
#'   shorter than the requested level).
#' @examples
#' bnf_level(c("0501", "0501013B0", "0501013B0AAAAAA"))
#' bnf_parent("0501013K0", "paragraph")
#' bnf_class(c("0501013B0", "0501120L0", "0501021G0"))
#' @export
bnf_level <- function(code) {
  unname(bnf_levels[as.character(nchar(code))])
}

#' @rdname bnf_level
#' @export
bnf_parent <- function(code, level = c("chemical", "section", "paragraph", "chapter", "subparagraph", "product")) {
  level <- match.arg(level)
  n <- as.integer(names(bnf_levels)[match(level, bnf_levels)])
  ifelse(nchar(code) >= n, substr(code, 1, n), NA_character_)
}

#' @rdname bnf_level
#' @export
bnf_class <- function(code, at = c("paragraph", "section")) {
  at <- match.arg(at)
  n <- if (at == "paragraph") 6L else 4L
  key <- ifelse(nchar(code) >= n, substr(code, 1, n), NA_character_)
  unname(bnf_class_labels[key])
}
