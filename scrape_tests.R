library(tidyverse)
library(jsonlite)

jsonmaster <- fromJSON ("https://www.mcso.org/Sys/Handler/mugshot?bookingNumber=T766538" ,
                    simplifyDataFrame = T)

# there are a couple of ways to do this. It may fail if you do it in one
# pass if there are missing values in the charges. The null is throwing
# up an error and has to be changed to NA as a character column. Sheesh.
charges <-
  jsonmaster$charges


#this is wrong - still end up with two rows, even though they're useless.
person <-
  jsonmaster %>%
  map_depth (1, ~ifelse(is.null(.x), NA_character_, .x))  %>%
  as.data.frame %>%
  select ( -last_col())

flattened <- person %>% left_join  (charges, by=c("bookingNumber"="booking"))


master_id <-
  #take the first 17 of them , which is everything except the charges
  enframe (myjson[1:17]) %>%
  # convert them to character so they can be raised up by the unnest
  mutate ( value = as.character(value)) %>%
  unnest (cols=c(value)) %>%
  # create a data frame from name/value pairs.
  pivot_wider ( names_from=name, values_from = value) %>%
  mutate ( across ( everything(), na_if, "NULL"),
           dateOfBirth = lubridate::as_date(dateOfBirth),
           bookingDate = lubridate::mdy(bookingDate))

charges <- myjson$charges

#NOTES: enframe takes a named list and turns it into a data frame that has a name and a value column.
#The value is still in list form, but can then be lifted using unnest.
#They all must be one form of data for it to work - they pretty much
#
#
#Now try tidyjson


#remove null values.
myjson1 <- jsonmaster[!sapply(jsonmaster, is.null)] %>% as.data.frame


myjson
#now we should be able to convert to data framt
#
