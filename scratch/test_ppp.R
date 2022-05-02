library(reactable)

naics_codes <- readRDS( url ( "https://cronkitedata.s3.amazonaws.com/rdata/naics_lookup.RDS"))


reactable(naics_codes)
library(tidyverse)

ppp_fortable <-
  ppp_orig %>%
  # sort in order so that the months aren't alphapbetized or dependent on the first county
  arrange ( date_approved) %>%
  mutate ( month = format(date_approved, "%Y-%m"),
           project_county = replace_na(project_county, "UNKNOWN")) %>%
  filter ( project_state == "AZ") %>%
  group_by ( project_county, month) %>%
  #this at least shows you commas in the values. I haven't had luck using currency on this.
  summarise ( loans  =  n(),
              total_amt = sum(amount),
              .groups="drop"
  )
