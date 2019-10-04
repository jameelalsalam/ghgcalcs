# GHGRP GWP table

library(tidyverse)
library(rvest)

ghgrp_cfr <- read_html("https://www.ecfr.gov/cgi-bin/text-idx?SID=364a5fce8172ea4a303e405e64dfbce4&mc=true&node=ap40.21.98_19.1&rgn=div9")

tablea1 <- html_table(ghgrp_cfr, fill = TRUE) %>% .[[4]] %>%
  set_names(c("ghg_name", "CASRN", "chemical_formula", "gwp_chr")) %>%
  mutate(gwp = readr::parse_number(gwp_chr)) %>%

  # group descriptions cross several columns
  mutate(grp_desc = if_else(
    !is.na(ghg_name) &
      ghg_name == CASRN &
      ghg_name == gwp_chr,
    ghg_name, NA_character_)) %>%

  tidyr::fill(grp_desc) %>%

  # get rid of previous group description rows
  filter(!(
    !is.na(ghg_name) &
      ghg_name == CASRN &
      ghg_name == gwp_chr
  )) %>%
  mutate(note = stringr::str_extract(gwp_chr, "^[abcd]")) %>%
  mutate(note_text = case_when(
    note == "a" ~ "The GWP for this compound was updated in the final rule published on November 29, 2013 [78 FR 71904] and effective on January 1, 2014.",
    note == "b" ~ "This compound was added to Table A-1 in the final rule published on December 11, 2014, and effective on January 1, 2015.",
    note == "c" ~ "The GWP for this compound was updated in the final rule published on December 11, 2014, and effective on January 1, 2015 .",
    note == "d" ~ "For electronics manufacturing (as defined in §98.90), the term “fluorinated GHGs” in the definition of each fluorinated GHG group in §98.6 shall include fluorinated heat transfer fluids (as defined in §98.98), whether or not they are also fluorinated GHGs.",
    TRUE ~ NA_character_
  )) %>%
  select(-gwp_chr)

library(webchem)

cir_query("carbon dioxide", representation = 'cas')

# each api call done individually...
# casrn <- cir_query(
#   tablea1$ghg_name,
#   representation = 'cas'
# )

casrn_clean <- map(casrn, as.character) %>%
  map(unique)

tablea1 %>%
  mutate(casrn_api = casrn_clean) %>%
  unnest(cols = casrn_api) %>%
  write_csv("data-raw/ref/casrn-api-lookup.csv")



