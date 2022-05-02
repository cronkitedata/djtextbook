library(tidyverse)
library(rvest)

site <- "https://www.imdb.com/chart/toptv/?ref_=nv_tvv_250"

myhtml <- minimal_html("<div class='myclass'> This is some text
                       then some more <span>with a span </span> </div>
                       <div class='myclass'> another one, this time
                       with a link <a href='mylink'>the link text</a> and then a
                       <p>paragraph of a different class with <a href='myurl'>
                       a nested link </a> </p>
                       </div>")
myhtml %>%
  as.character()

myhtml %>%
  html_nodes("div") %>%
  .[[2]] %>%
  html_children


mytable <-
  read_html(site) %>%
  html_node(" .chart ")


#see how to get # 3
read_html(site) %>%
  html_nodes("div") %>%
  .[[3]] %>%
  as.character()


static_chart <-
  mytable %>%
  html_table (trim=T)

col1 <-  mytable %>% html_nodes("tbody > tr > .titleColumn")


year <- col1 %>% html_nodes(".secondaryInfo") %>% html_text(trim=T)
title <- col1 %>% html_nodes("a") %>% html_text
link <- col1 %>% html_nodes("a") %>% html_attr("href") %>%   paste0("https://imdb.com", .)
rank <- col1 %>% html_text(trim=T) %>% str_extract( "^\\d+") %>% as.integer

# this part is really hard - don't worry about the matching - it comes back as a list, and you
# have to extract out the second part of it. I have no idea what the "map" is doing but it works.
rating_basis <- mytable %>% html_nodes("tbody > tr  .ratingColumn > strong ") %>%
  html_attr ("title") %>%
  str_match_all (.,  "based on ([,0-9]+)")    %>%
  map(2) %>%
  as.character %>%
  parse_number()


static_chart %>%
  janitor::clean_names() %>%
  select (rank_title, im_db_rating) %>%
  add_column ( year, title, link, rank, rating_basis) %>%
  mutate (across(everything(), str_squish))


