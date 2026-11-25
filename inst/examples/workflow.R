# End-to-end workflow with the live API (needs network access to openprescribing.net).
# Run line by line: system.file("examples/workflow.R", package = "opamr")
library(opamr)

# 1. antimicrobials of interest, by name / AMR code / ATC prefix -> BNF chemical codes
ab_to_bnf(c("amoxicillin", "nitrofurantoin", "J01MA"))

# 2. national monthly use of each agent (one request per BNF chemical, cached for the session)
nat <- op_spending_ab(c("amoxicillin", "nitrofurantoin", "doxycycline", "trimethoprim"))

# 3. one Sub-ICB Location: find its code, then rates per 1,000 registered patients
op_org_search("Barnsley", "sicbl")
barnsley <- op_antibiotic_use(c("amoxicillin", "nitrofurantoin"), org_type = "sicbl", org = "02P")

# 4. all Sub-ICB Locations -> distribution over organisations
all_sicbl <- op_antibiotic_use("J01", org_type = "sicbl")            # J01 = antibacterials for systemic use
p <- op_plot_distribution(all_sicbl[all_sicbl$ab == "AMX", ], y = "rate", highlight = "02P")

# 5. figures
op_save(op_plot_trend(nat, y = "items"), "trend.pdf", width = "single")
op_save(op_plot_seasonal(nat, y = "items", years = 2022:2025), "seasonal.pdf", width = "double")
op_save(op_plot_heatmap(nat, y = "items"), "heatmap.pdf", width = "double", aspect = 0.4)
