# Build data/op_example.rda: national monthly totals for BNF section 5.1 (antibacterial drugs).
#
# Input: data-raw/example_national_raw.csv, one row per month and BNF chemical substance, from the NHSBSA
# English Prescribing Dataset SQL API (Open Government Licence v3.0), one query per monthly table:
#   SELECT <chem> AS code, SUM(CAST(ITEMS AS FLOAT64)) AS items,
#          SUM(CAST(TOTAL_QUANTITY AS FLOAT64)) AS quantity, SUM(CAST(ACTUAL_COST AS FLOAT64)) AS actual_cost
#   FROM `EPD_SNOMED_YYYYMM` WHERE <chem> LIKE '0501%' GROUP BY <chem>
# where <chem> is BNF_CHEMICAL_SUBSTANCE up to 2025-02 and BNF_CHEMICAL_SUBSTANCE_CODE from 2025-03
# (the column holding the 9-character code was renamed in March 2025).
# Run after build_crosswalk.R, from the package root.
load("data/antibiotic_crosswalk.rda")
raw <- read.csv("data-raw/example_national_raw.csv", stringsAsFactors = FALSE)
raw$date <- as.Date(raw$date)
stopifnot(length(unique(raw$date)) == length(seq(min(raw$date), max(raw$date), by = "month")))
cw <- antibiotic_crosswalk[antibiotic_crosswalk$bnf_chapter == "05", ]
m <- merge(raw, cw[, c("bnf_chemical_code", "ab", "ab_name", "atc")], by.x = "code", by.y = "bnf_chemical_code")
key <- paste(m$date, m$ab)
sums <- rowsum(m[, c("items", "quantity", "actual_cost")], key, reorder = FALSE)
first <- m[!duplicated(key), c("date", "ab", "ab_name", "atc")]
codes <- tapply(m$code, key, function(z) paste(sort(unique(z)), collapse = "+"))[unique(key)]
op_example <- data.frame(date = first$date, org_type = "national", org_id = "england", org_name = "England",
                         ab = first$ab, ab_name = first$ab_name, atc = first$atc, code = unname(codes),
                         sums[unique(key), , drop = FALSE], stringsAsFactors = FALSE)
op_example <- op_example[order(op_example$ab, op_example$date), ]
rownames(op_example) <- NULL
save(op_example, file = "data/op_example.rda", compress = "xz", version = 2)
cat(nrow(op_example), "rows;", length(unique(op_example$ab)), "antimicrobials;", format(range(op_example$date)), "\n")
