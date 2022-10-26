library(tidyverse)

tmp <-
az_indiv_contribs_2020 %>% filter (cmte_id %in% c("C00508804", "C00661314", "C00666040", "C00696526" )) %>%
  select ( fec_id = cmte_id, donor_name = name, donor_city=city, employer, amount = transaction_amt) %>% arrange ( desc(amount))


arizona_candidates %>%
  inner_join ( tmp, by=c("cmte_id"="fec_id")) %>%
  select ( cmte_id, cand_name, party=cmte_pty_affiliation, donor_name, donor_city) %>%
  View()
