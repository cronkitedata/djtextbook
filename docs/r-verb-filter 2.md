# Verbs in depth: Select, filter, arrange {#r-verb-filter}









:::{.alert .alert-secondary}

<p class="alert-heading font-weight-bolder fs-3">
In this chapter
</p>

* `select` to pick out columns efficiently and rename them
* `arrange` to order the rows in your data frame 
* `filter` using Boolean logic 
*  `str_detect` in filters for fuzzy matching 

::: 



This the next several chapters are based on Paycheck Protection Program, or PPP, loans in Arizona. Full documentation of the dataset is in the [Appendix](appendix-ppp.html). If you haven't already, look through that documentation before you start. 


## `select` columns

The `select` verb allows you to pick out columns by name or by their order in the data frame. Selecting columns is case-sensitive: a column called `amount` is completely different than a column named `Amount`. That's one reason to use our style of always converting column names to lower case. 

`select` is the easiest verb to understand it, so it's shown here first. But in practice, you'll usually include it as your last command in a code chunk because you need to use some columns in filtering or other operations that you don't want to include in the final output.   

There a lot of ways to pick out column names that are based on their name, their position, their type or other characteristics. For now we'll stick with a few ways:

* `select (1:10)` picks out the first 10 columns. Think of the colon as the word "through"
* `select (date_approved, borrower_name, borrower_address, borrower_zip, loan_status, amount, business_type)` picks out those columns in order.
* `select ( 2, 4:6, business_type)` combines position and name so you can use whichever is easier.


You can rename columns at the same time you select them by typing the new name, an equals sign and the old name, for example: 

```
select ( given_date = date_approved, 
        borrower = borrower_name ,
        borrower_city:borrower_zip)

```


## `arrange` rows

The `arrange` verb sorts your data in different ways depending on the type of column. They can be alphabetical (character columns), in numeric order ( number or double columns), or chronologically (date or date/time columns) . Reverse the order  by using `desc()` :

```
ppp_orig %>%
  arrange ( date_approved, desc(amount) )
  
```


## `filter` rows

`filter` uses Boolean logic to allow quite sophisticated and powerful conditions to pick out just the rows you want to see or to further examine.  The conditions are  case-sensitive and extremely literal. For example, "PIZZA HUT OF ARIZONA, INC" is completely different than "PIZZA HUT" or "Pizza Hut of Arizona Inc" . A simple extra character will prevent a match.^[That's why I've removed all of the punctuation from your the borrower names and addresses in your data file, and turned all of the names into upper case. ]

The conditions are indicated using the following symbols:


Symbol | Data types | Meaning
----| --- | ---
`==` | All | Equals, exactly. Note the double-equals sign, which distinguishes it from an assignment operator, such as setting new column name. 
`>` , `>=` | date, numeric | Greater than / greater than or equal to. 
`<`,  `<=` | date, numeric | Less than / less than or equal to. 
`!=` | all | Not equal to 
`%in%` | all | Is equal to any of the items in a list that you type  out, such as `fruit %in% c("apple", "orange")`.  
`is.na(column_name)` | all | find anything missing, which does not mean the same thing as 0 or "". 


In each of these cases, the column name goes on the left of the operator, and the condition goes on the right. 

You can combine them using `and` and `or` : 

* `&` is "and" , which means that both conditions must be true. It NARROWS your search
* `|` is "or" , which means that EITHER condition can be true. It WIDENS your search. You'll usually use this if you want to get results from two different columns. Think of "this or that". This is rarer than you would think, since you usually are looking for different items within one column. 
* `%in%` is the equivalent of an "or" condition within one column. 


This is sometimes confusing because it's the exact opposite of the way we describe it in English. If we want "apples and oranges", we have to search for ` fruit == 'apple' | fruit == 'orange'`   (Note the plural versus singular as well - we have to search for what is in the data, not what we want to say.)

 You often need to use parentheses to tell R what order you want to evaluate the conditions when you combine "AND" and "OR" conditions.

::: {.alert .alert-info}

Pro tip: Matching parentheses can be tricky. To make it a little easier, you can set "rainbow parentheses" in the RStudio options, which will show you the matching opening or closing brackets and parentheses in different colors when your cursor is placed next to one of them. It's under the Preferences -> Code -> Display options, at the bottom. 

:::

### A few examples {-}

In the PPP data, all borrower names are in upper case, and all cities and addresses are in proper case. In addition, all of the punctuation has been removed, such as periods, commas, quotes and apostrophes. 

When you use a condition : 

* Numbers are without quotes, commas, dollar signs or anything other than digits and decimal points. (1000000.24)
* Text is always in quotes. 
* Dates are in the form "2022-01-22". 
* NA values never match anything. Search for them using the `is.na()` function. 


:::{.alert .alert-info}

Pro tip: you can explore your data in the data frame window (by clicking on the name of the data frame in the Environment tab. ) . That is a wildcard search and is not case-sensitive. Use it to test various ways to search for an item, and to find the exact phrasing you need in a filter. 

:::


####  A list of borrowers in Flagstaff and Sedona {-}


Here's an example of extracting a few columns of the data, filtering for those borrowers in Flagstaff and Sedona, using the `%in%` operator on a list of cities, defined with the `c()` command, for "combine": 


```r
ppp_orig %>%
  filter ( borrower_city %in% c("Flagstaff", "Sedona")) %>%
  select (borrower_name, borrower_city, date_approved, amount, forgiveness_amount)
```

#### Narrowed to under $100,000 {-}

To narrow it just to loans under $100,000, you can use an "&" condition, or add another filter. Here, we'll arrange it in chronological order: 



```r
ppp_orig %>%
  filter ( borrower_city %in% c("Flagstaff", "Sedona")) %>%
  filter ( amount < 100000) %>%
  select (borrower_name, borrower_city, date_approved, amount, forgiveness_amount) %>%
  arrange (date_approved)
```

#### Another way to do the same thing {-}

The query above is the equivalent of the last example to produce the same answer. This time it uses a combination of the `|` "or" operator with the `&` "and" operator.



```r
ppp_orig %>%
  filter ( 
           (borrower_city == "Flagstaff" | borrower_city == "Sedona") &
              amount < 10000
  ) %>%
  select (borrower_name, borrower_city, date_approved, 
          amount, forgiveness_amount) %>%
  arrange (date_approved)
```


(You might note how I did the indentations above -- it helps in reading the code to make clear what comes before what.)


#### Projects in Maricopa County that are NOT in Phoenix or Scottsdale {-}


And here's how to negate a filter - everything NOT in two cities. The `!` means "NOT". 



```r
ppp_orig %>%
  filter ( project_county == "MARICOPA" &
             (! borrower_city %in% c("Scottsdale", "Phoenix")) 
  ) %>%
  select ( borrower_city, borrower_name, 
           amount, forgiveness_amount) %>%
  arrange (amount)
```





## Fuzzy matching with patterns


So far, you've had to do all of your filters for character columns matching exactly. You can see that's rarely going to be useful in columns like names, cities, or addresses. 


Enter the idea of fuzzy filtering, called *pattern matching* using *regular expressions*. We're going to use a package that is part of the tidyverse called `stringr` to do this.

:::{.alert .alert-info}

Googling for help in "regular expressions" or "pattern matching" in R will likely bring back instructions on how to use base R, not the `stringr` package from the tidyverse. If you get answers that include "grep" or "grepl", try adding the word "tidyverse" or "stringr" to your Google query. 

::: 

This chapter has the very basics of pattern matching. There will be an entire chapter on it later in the semester. It's one of the most powerful things you can do in programming languages.^[Every computer language -- except the Excel default interface -- has an implementation of regular expressions, which is the same thing as pattern matching. This is one of the major strengths of Google Sheets over Excel. ]

### Regular expressions - the short version  {-}

Regular expressions search for patterns rather than exact words or phrases. You can use them to search a column, to extract a piece of a column in each row, or to replace them. They only work on *strings*, which is computer-eze for text or character columns. 

For filtering, the function `str_detect()`  *detects* whether or not a *string*  exists in a cell. It looks a little different than the usual filter command. It's a function that takes two arguments: The column name to work on and the regular expression to look for. It looks like this: 


```markdown

filter ( str_detect ( a_column_name, "a regular expression" ))

```

Here are some basic rules for the pattern: 

* `^` means "the pattern must come at the beginning of the string"
* `$` means "the pattern must come at the end of the string"
* `|` means "or", just as it does in the filter. So "(LLC|CORP|INC)" would look for "LLC", "CORP", or "INC"
* `.*` means "anything or nothing" 
* `?` means "It might or might not exist at all" . You usually need to put a phrase or set of letters in parentheses to make it work properly. 

There are many more instructions you can add, but for now we'll just stick with these. 

### Examples of regular expressions {-}


To filter for any address containing "Central Ave":

```markdown

filter ( str_detect(borrower_address, "Central Ave"))

```


To filter for any address using Central, Fillmore or Taylor in the zip code "85004": 

```markdown

filter (str_detect (borrower_name, "Central|Fillmore|Taylor") &  
                    borrower_zip == "85004"
        )

```


To filter for any kind of non-profit: 

```markdown

filter (str_detect (business_type, "^Non-Profit"))

```

To filter for "Fillmore St" when you don't know if it might be misspelled as "Filmore". 

```markdown

filter (str_detect (borrower_address, "Fill?more"))

```

Here is how you'd look for everything on North Scottsdale Road, when you don't know whether it's "N" or "North" and "Road" or "Rd": 

```markdown

filter ( str_detect( business_address, "N(orth)? Scottsdale R(oa)?d") )

```

We'll see later in the semester how to standardize names and addresses so you don't have to guess -- it's one of the more time consuming and difficult things to do in data journalism. It's what trips up most people who try to report on campaign finance. 

 

## Your turn 


Create a new markdown document with the [YAML (front matter) and setup chunk](https://gist.githubusercontent.com/sarahcnyt/e60ad2d7ccf65498fc88791f3bb683ae/raw/bcf4fb844d183b62f531a74a445271c5571f3a1d/cronkite-boilerplate.Rmd) that you used in the last chapter.  

Create an introduction summarizing what this program does. You may want to just leave room for it now, and come back to it once you're finished. 

Add a sub-heading that provides documentation and sourcing of the data. You can load the data at the same time using this code chunk^[This is a "nested" function - a function within a function. The readRDS() function reads a native R file from your computer. The url() function tells R that this file exists on the internet, not on your computer.]: 

```markdown

ppp_orig <- readRDS( url ( "https://cronkitedata.s3.amazonaws.com/rdata/ppp_az_loans.RDS"))

```

Next, add a code chunk with the `glimpse(ppp_orig)` command to get a list of the columns in order. 


### Filtering your data {-}

Create code chunks that will filter for the following values. You can select just the columns you want to see in whatever sort order makes sense for you to troubleshoot. You can rewrite the list below into plain English sentences to introduce the code chunks. 

Find the following sets of loans, and try to think about why these might make for interesting or possible story ideas. 

1. At least $1 million 

2. Under $1,000 

3. Under $1,000 for projects in Maricopa County

4. Loans that were paid in full but not forgiven. In other words, the borrower decided to pay it back rather than ask for taxpayers to cover it. (These loans are shown as missing, or `NA` in the forgiveness_amount column)

5. Loans that had more forgiven than approved. 

6. Loans in Phoenix, Scottsdale and Tempe

7. Loans in Arizona that were for projects out of state. 

8. McDonald's franchises. (I removed the apostrophe.)

9. Any loan to a Native American tribe or nation or reservation. Hint: It's hard to do this because "NATION" could be part of the word "NATIONAL" and "TRIBE" could be part of the word "TRIBECA" and "RESERVATION" could be part of the word "PRESERVATION". You can use a special character to look for "word boundaries" : `\\b`. To find just the word "NATION", it would look like this `"\\bNATION\\b"` . Try to see if you can figure out how make it work when you want to use all three words.
 
10. Your turn! Think of one filter you want to make based on what is in this chapter.

