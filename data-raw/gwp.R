## code to download and process gwp table from IPCC pdf

# pdf of IPCC AR4 WG1 Table of Global Warming Potentials
# https://www.ipcc.ch/site/assets/uploads/2018/02/ar4-wg1-chapter2-1.pdf

library(tidyverse)

# tabulizer::locate_areas(
#   file = "data-raw/ref/ar4-wg1-chapter2-1.pdf",
#   pages = 84:85
# )

gwp_col_names <- c("common_name", "chemical_formula", "lifetime", "radiative_eff",
                   "gwp_sar_100", "gwp_ar4_20", "gwp_ar4_100", "gwp_ar4_500")

# page 84
# top = 145.1
# bottom = 706.5
# cols = 36, 128, 238, 287, 356, 392, 436, 476

p84 <- tabulizer::extract_tables(
  file = "data-raw/ref/ar4-wg1-chapter2-1.pdf",
  output = "data.frame",
  pages = 84,

  guess = FALSE,
  columns = list(c(36, 128, 238, 287, 356, 392, 436, 476))
) %>% .[[1]] %>%
  slice(9:52) %>%
  select(-1) %>%
  set_names(gwp_col_names) %>%
  mutate_at(.vars = 3:8, .funs = readr::parse_number) %>%
  filter(!is.na(gwp_ar4_100))

# page 85
# top = 133
# bottom = 608
# cols = 53, 140, 269, 296, 386, 413, 452, 495

p85 <- tabulizer::extract_tables(
  file = "data-raw/ref/ar4-wg1-chapter2-1.pdf",
  output = "data.frame",
  pages = 85,

  guess = FALSE,
  columns = list(c(53, 140, 269, 296, 386, 413, 452, 495))
) %>% .[[1]] %>%
  slice(9:46) %>%
  select(-1) %>%
  set_names(gwp_col_names) %>%
  mutate_at(.vars = 3:8, .funs = readr::parse_number) %>%
  filter(!is.na(gwp_ar4_100))

table2.14_ipcc_ar4 <- bind_rows(p84, p85)

csvy::write_csvy(table2.14_ipcc_ar4, file = "data-raw/table214_ipcc_ar4.csvy")

# copied to ghg_gwp.csvy, and manually edited to fix OCR errors

gwp_ipcc_ar4 <- csvy::read_csvy(file = "data-raw/gwp_ipcc_ar4.csvy")

tblrelations::assert_pk_ish(gwp_ipcc_ar4, by = "common_name")

usethis::use_data(gwp_ipcc_ar4)
