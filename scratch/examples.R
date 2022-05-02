ppp_orig %>%
  filter (project_state == "AZ") %>%
  left_join (naics_codes, by="naics_code") %>%
  group_by ( project_county, subsector_desc) %>%
  summarise ( loans = n() ,
              .groups="drop_last") %>%
  mutate (
    county_total_loans = sum(loans) ,
    pct_of_loans = loans / county_total_loans * 100 ) %>%
  filter ( subsector_desc == "Food Services and Drinking Places")



ppp_orig %>%
  filter ( str_detect (franchise_name, "^Dairy Queen")) %>%
  select ( borrower_name, franchise_name)


ppp_orig %>%
  group_by (project_county) %>%
  summarise ( loans = n(),
              industries = n_distinct ( naics_code)) %>%
  arrange ( desc ( loans))
