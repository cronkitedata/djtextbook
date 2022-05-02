library(tidyverse)
library(RJSONIO)

# get two rows from a single person, with null values.
# Use RJSONIO instead of jsonlite to get the nullValue argument
# MUCH easier than using jsonlite.

jsonmaster <- RJSONIO::fromJSON ("scratch/mugshotetest2.json", nullValue=NA_character_,
                        simplify_all=TRUE)  %>%
  as_tibble %>%
  unnest_wider(col=charges) %>%
  mutate (bookingDate = mdy(bookingDate),
          dateOfBirth = lubridate::as_date(dateOfBirth) ,
          across( where (is.character), str_squish)
  )

# for some reason, enframe doesn't work in pipe.
master_id <-
  jsonlite::fromJSON(txt="scratch/mugshotetest2.json", simplifyVector = TRUE)
  #take the first 17 of them , which then you can remove the NULL using the na_if
  #function.


lapply(master_id, function(y) lapply(y, as.character))~as.character(.x))

person <-
  enframe (master_id[1:17]) %>%
  # convert them to character so they can be raised up by the unnest
  mutate ( value = as.character(value)) %>%
  unnest (cols=c(value)) %>%
  # create a data frame from name/value pairs.
  pivot_wider ( names_from=name, values_from = value) %>%
  mutate ( across ( everything(), na_if, "NULL"),
           dateOfBirth = lubridate::as_date(dateOfBirth),
           bookingDate = lubridate::mdy(bookingDate))

# for some reason, this already is done using the simiplifyDataFrame
charges <- master_id$charges

#NOTES: enframe takes a named list and turns it into a data frame that has a name and a value column.
#The value is still in list form, but can then be lifted using unnest.
#They all must be one form of data for it to work - they pretty much


#remove null values. I have no idea what this does, but it somehow already
#converts it to a data frame.
myjson1 <-
  master_id[!sapply(master_id, is.null)] %>% as.data.frame

