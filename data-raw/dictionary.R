# dictionary.R

# devtools::install_github("jalsalam/tblrelations")

library(tidyverse)

#### Dictionary ---------------------------
# a big list of recognized GWP names for the purpose of name normalization

ghg_dictionary <- readr::read_csv("data-raw/normalize_ghg_name.csv")

#### Wildcaught names ---------------------

# places to catch names from:
# IPCC AR4 table -- DONE
# GCAM -- DONE
# GHGRP EF API --
# GHGI EF API --




#### GCAM output names ---------------------

gcam_nonco2 <- readr::read_csv("data-raw/ref/gcam_nonCO2emiss_reg.csv") %>%
  distinct(ghg)

gcam_nomatch <- anti_join(gcam_nonco2, ghg_dictionary, by = c("ghg" = "wildcaught_name")) %>%
  write_csv("data-raw/ref/gcam_gases_nomatch.csv")

tblrelations::assert_pk_ish(ghg_dictionary, by = "wildcaught_name")

# which values of `wildcaught_name` are duplicated?
# ghg_dictionary %>% group_by(wildcaught_name) %>% summarize(count = n()) %>% filter(count != 1)

tblrelations::assert_fk_ish(
  filter(ghg_dictionary, !is.na(normalized_common_name)),
  ghgcalcs::gwp_ipcc_ar4,
  by = c("normalized_common_name" = "common_name"))

# which values of `normalized_common_name` do not appear in the gwp table are not?
# anti_join(filter(ghg_dictionary, !is.na(normalized_common_name)),
#           ghgcalcs::gwp_ipcc_ar4, by = c("normalized_common_name" = "common_name"))

usethis::use_data(ghg_dictionary)
