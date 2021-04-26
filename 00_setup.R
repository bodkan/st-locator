install.packages(c("devtools", "sf", "tidyverse"))
devtools::install_github("bodkan/spammr", ref = "2dd21e3")

# locations of generated SLiM scripts and output files
dir.create("results/")
dir.create("figures/")
