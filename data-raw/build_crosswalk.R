# Build data/antibiotic_crosswalk.rda and inst/extdata/antibiotic_crosswalk.csv
#
# Input : data-raw/epd_chemicals_raw.csv - distinct BNF chemical substances (code, name, chapter) in the
#         NHS Business Services Authority English Prescribing Dataset (EPD), months 2025-12 and 2026-06,
#         from the NHSBSA Open Data Portal SQL API (Open Government Licence v3.0):
#           SELECT DISTINCT BNF_CHEMICAL_SUBSTANCE_CODE, BNF_CHEMICAL_SUBSTANCE, BNF_CHAPTER_PLUS_CODE
#           FROM `EPD_SNOMED_YYYYMM`
#         data-raw/manual_overrides.csv - hand-checked corrections.
# Method: BNF names are matched to AMR antimicrobial codes with AMR::as.ab() on several cleaned variants
#         (salt words stripped, bracketed synonyms split). A match is accepted only if the first non-salt
#         word of the AMR name occurs in the BNF name (rejects fuzzy false positives such as
#         "Sodium citrate" -> "Sodium aminosalicylate"). Manual overrides are applied last.
# Run from the package root with the AMR package installed.
suppressMessages(library(AMR))
raw <- read.csv("data-raw/epd_chemicals_raw.csv", stringsAsFactors = FALSE)
chem <- unique(raw[, c("BNF_CHEMICAL_SUBSTANCE_CODE", "BNF_CHEMICAL_SUBSTANCE", "BNF_CHAPTER_PLUS_CODE")])
chem <- chem[!duplicated(chem$BNF_CHEMICAL_SUBSTANCE_CODE), ]
names(chem) <- c("bnf_chemical_code", "bnf_name", "bnf_chapter")
chem$bnf_chapter <- sub(":.*$", "", chem$bnf_chapter)
chem <- chem[order(chem$bnf_chemical_code), ]

salts <- c("sodium", "hydrochloride", "hyclate", "monohydrate", "pentahydrate", "sulfate", "sulphate",
           "trometamol", "calcium", "hippurate", "axetil", "ethylsuccinate", "stearate", "phosphate",
           "hydrate", "dihydrate", "trihydrate", "potassium", "disodium", "mesilate", "mesylate",
           "acetate", "succinate", "citrate", "tartrate", "lactate", "benzoate", "proxetil", "medoxomil",
           "etabonate", "embonate", "pamoate", "base", "anhydrous", "hemihydrate", "dihydrochloride")
variants <- function(nm) {
  paren <- regmatches(nm, gregexpr("\\(([^)]+)\\)", nm))[[1]]
  paren <- gsub("[()]", "", paren)
  main  <- trimws(sub("\\(.*$", "", nm))
  v <- c(nm, main, paren, unlist(strsplit(paren, "/")))
  strip <- function(s) trimws(gsub(paste0("\\b(", paste(salts, collapse = "|"), ")\\b"), "", s, ignore.case = TRUE))
  v <- c(v, vapply(v, strip, ""))
  v <- gsub("\\s+", " ", trimws(v))
  unique(v[nzchar(v)])
}
# first word of the AMR agent name that is not a salt/counter-ion word
first_word <- function(x) {
  w <- tolower(strsplit(x, "[ /-]")[[1]])
  w <- w[nzchar(w) & !w %in% salts]
  if (length(w)) w[1] else tolower(x)
}
try_match <- function(nm) {
  for (v in variants(nm)) {
    ab <- suppressWarnings(suppressMessages(as.ab(v, flag_multiple_results = FALSE, info = FALSE)))
    if (length(ab) == 1 && !is.na(ab)) {
      abn <- ab_name(ab, language = NULL)
      if (grepl(first_word(abn), tolower(nm), fixed = TRUE) || grepl(first_word(abn), tolower(v), fixed = TRUE))
        return(c(ab = as.character(ab), via = v))
    }
  }
  c(ab = NA_character_, via = NA_character_)
}
m <- do.call(rbind, lapply(chem$bnf_name, try_match))
colnames(m) <- c("ab", "via")
chem$ab <- unname(m[, "ab"]); chem$match_via <- unname(m[, "via"])
chem$match_method <- ifelse(is.na(chem$ab), NA_character_, "AMR::as.ab")

manual <- read.csv("data-raw/manual_overrides.csv", stringsAsFactors = FALSE, na.strings = "")
i <- match(manual$bnf_chemical_code, chem$bnf_chemical_code)
stopifnot(!anyNA(i), all(is.na(manual$ab) | manual$ab %in% as.character(AMR::antimicrobials$ab)))
chem$ab[i] <- manual$ab
chem$match_method[i] <- ifelse(is.na(manual$ab), "manual: no single AMR agent", "manual")
chem$match_via[i] <- NA

has <- !is.na(chem$ab)
chem$ab_name <- NA_character_; chem$ab_group <- NA_character_; chem$atc <- NA_character_; chem$atc_all <- NA_character_
chem$ab_name[has]  <- ab_name(chem$ab[has], language = NULL)
chem$ab_group[has] <- vapply(chem$ab[has], function(a) paste(ab_group(a, language = NULL), collapse = " | "), "")
atcs <- lapply(chem$ab[has], function(a) { x <- as.character(ab_atc(a)); x[!is.na(x) & !grepl("^Q", x)] })
# primary ATC: prefer the systemic anti-infective code (J...) over topical/other codes
prim <- function(x) if (!length(x)) NA_character_ else if (any(grepl("^J", x))) x[grepl("^J", x)][1] else x[1]
chem$atc[has]     <- vapply(atcs, prim, "")
chem$atc_all[has] <- vapply(atcs, function(x) paste(x, collapse = "|"), "")

# scope: antimicrobial ATC codes, plus every matched chemical in BNF 5.1 / 5.2 even where AMR has no ATC
keep_atc <- "^(J01|J02|J04|J05|A07A|D01|D06|D07C|G01A|S01A|S02A|S03A|P01A|P01B|J07|A01AB|B05)"
in_bnf_5_1_2 <- grepl("^050[12]", chem$bnf_chemical_code)
cw <- chem[has & ((!is.na(chem$atc) & grepl(keep_atc, chem$atc)) | in_bnf_5_1_2), ]
cw$bnf_section <- substr(cw$bnf_chemical_code, 1, 4)
cw$bnf_paragraph <- substr(cw$bnf_chemical_code, 1, 6)
cw$amr_version <- as.character(packageVersion("AMR"))
cols <- c("bnf_chemical_code", "bnf_name", "bnf_chapter", "bnf_section", "bnf_paragraph", "ab", "ab_name",
          "ab_group", "atc", "atc_all", "match_method", "amr_version")
antibiotic_crosswalk <- cw[, cols]
rownames(antibiotic_crosswalk) <- NULL

cat("Crosswalk rows:", nrow(antibiotic_crosswalk), "\n")
save(antibiotic_crosswalk, file = "data/antibiotic_crosswalk.rda", compress = "xz", version = 2)
dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)
write.csv(antibiotic_crosswalk, "inst/extdata/antibiotic_crosswalk.csv", row.names = FALSE)
