# Recipes {#r-recipes}






This final chapter on data wrangling in R simply puts together a lot of the code snippets that are easy to forget, and adds some more advanced code examples that you can adapt to your work. There is minimal explanation. Instead, look at at the relevant chapter for more explanation. Over time, I'll add section links to the examples.

You can copy and paste these into RStudio's snippets and use them directly in your program -- then you just have to change the references to the variables in your own work.

These examples use the data from the other chapters, from the PPP program.

### R annoyances and errors {-}

There are several annoyances that aren't consistent from one function in R to the next. When you're having trouble, look for

-   **Quoting issues** - what kind of quotes, whether they're needed, and if they're matched open and closed.

-   Unmatched or missing **parentheses**

    Putting words on the wrong side of **equal signs**. To create a new column name, put it on the left. To identify a column to be used as an argument, put it on the right. To filter a column, use two equals signs, with the column name on the left.

-   Are you working with a **list** of items? If so, you need to wrap them in the `c()` function, for "combine"

-   **Case-sensitivity** in column names; back-ticks for more than one word in a column name rather than quotes.

-   Missing or hanging **pipes** (%\>%)

These are the problems that will fix about 80 percent of the code that won't run once you get more used to it.

## Re-using answers from a previous step

Assign your code chunk to a new variable in the environment to use it again later. This is usefule when: 

* You have a complex filter that you want to apply to future steps. 
* You are joining data frames with columns having the same names: select just the columns you need and re-name any of the ones that are the same, except for the join one. 
* You have fixed some column types or adjusted their values. 

The assignment operator is `<-`, which means "pour the answer into this variable name"

These can all go into one code chunk if you'd like: 


```r
select_ppp <- 
  ppp_orig %>%
  filter ( project_state == "AZ" & !is.na (project_county) ) %>%
  mutate ( forgiveness_amount = if_else (is.na(forgiveness_amount),
                                         0, 
                                         forgiveness_amount)) %>%
  select ( borrower_name, borrower_city, 
           naics_code, 
           amount, forgiveness_amount,
           date_approved, forgiveness_date)



sectors <- 
  naics_codes %>%
  select ( naics_code, sector_code, sector_desc)


select_ppp %>%
  left_join ( sectors, by="naics_code")  %>%
  select ( borrower_name, forgiveness_amount, sector_desc) %>%
  head(5)
```




## Filtering

1.  One condition that's a number :

```
  filter ( amount > 1000 )
```

2.  A number between two values

```
  filter ( between ( amount, 0, 1000))
```

3.  An exact phrase or word

```
  filter ( project_county == "MARICOPA")
```

4.  One of several possible entries in one column (exactly)

```
    filter ( project_county %in% c("MARICOPA", "PIMA", "PINAL" ))
```
5.  Everything except missing values

```
    filter ( ! is.na (project_county) )
```

5.  Between two dates date[^Be sure it's really a date in the data by glimpsing your data frame. If not, turn it into a date first]

```
    filter ( approval_date >= "2021-01-24" & 
           approval_date <= "2021-01-31")
```
6.  Phrases, words or letters at the beginning of a column

```
    filter ( str_detect (borrower_type , "^Non-Profit"))
```

7.  Phrases, letters or words at the end of a column

```
    filter ( str_detect (borrower_type, "Corporation$"))
```
8.  A word that isn't part of another word

```
    filter ( str_detect ( "\\bNation\\b"))
```

All of these examples can be used in a `mutate` statement to create flags or new values if the conditions are met.  

## Aggregate (count, sum rows by category)

1.  Counting (How many?)

```
    group_by (project_county) %>%
    summarise (loans = n() )  %>%
    arrange ( desc ( loans ))
```

Make sure you don't name the new column containing the count the same thing as a group_by() column.

2. Shortcut for counting:

```
     count( project_county, sort=TRUE, name="loans")
```


3.  Counting unique entries

Sometimes you want to know how many items of a type, not how many rows, are included in a category.

```
        group_by ( project_county) %>%
        summarise ( number_of_loans = n(), 
                    number_of_industries = n_distinct ( naics_code )
                    )
```


4.  Summing (how much?)

```
    group_by (project_county) %>%
    summarise ( total_amount = sum (amount, na.rm=T))
```

5. Shortcut for summing:

```
    count ( project_county, weight=amount, name="total_amount")
```

## Recoding categories

You'll often want fewer categories, or numbers in categories, that you want to use instead of the original values. This is done in a mutate statement. Don't forget to save the output to a new data frame (<-), or you won't have access to it later on. 


1.  Create yes-no categories . This is really "Yes", "No" or NA, where there is an NA to begin with.

```
    mutate ( corp_yn = if_else  
                      (str_detect (borrower_type, 
                                   "Corporation"), 
                       "Yes", 
                       "No")
       )
```

2. Recode into more than two categories, example using `str_detect()`

```
  mutate ( new_type = case_when 
           (str_detect (borrower_type, 
                        "Corporation|Company") ~     "
                        For-profit company", 
          str_detect (borrower_type,
                      "(Non-Profit|Cooperative|Association)") ~ 
                      "Non profit", 
          str_detect ( borrower_type, 
                      "(Sole|Self-Employed|Independent)") ~
                      "Individual", 
          TRUE ~ "Everyone else")
        )
```

You'll want to check them when you're done to make sure: 

```
        new_dataframe %>%
        count ( new_type, borrower_type)
```

to make sure you coded them properly. Too many `NA` values means you likely misspelled something or left something out.


3. Recode numbers into categories

It's often useful to give them numeric codes in front so they sort properly:

```
        mutate ( new_type = 
                 case_when  (
                    amount <= 1000 ~ "00-Very low", 
                    amount <= 10000 ) ~ "01-Low", 
                    amount <= 100000) ~ "03-Medium", 
                    amount > 100000 ~ "04-High")
              )
```

This works because the first one that it finds will be used, so a value of exactly 1,000 would be "Very low", but a value of 1,001 would be "Low".^[A more precise way to do it would be : `amount < 1000 ~ "Very Low", between ( amount, 1000.01, 10000) ~ "Low"` , etc. But it relies on numbers that are never more precise than two digits.]


## Working with grouped data for subtotals, changes, percents

1.  Percent of total by group

```
  group_by ( project_county, sector_desc ) %>%
  summarise ( loans = n() , .groups="drop_last") %>%
  mutate ( pct_in_county = loans / sum(loans))
```

2. Display results as in spreadsheet form

To see the items across the top, use `pivot_wider`. 

```
  group_by ( project_county, new_type) %>%
  summarise ( loan_count = n() ) %>%
  pivot_wider ( names_from = new_type, 
                id_cols = c( project_county), 
                values_from = loan_count)
```

You can add an argument after `values_from` if you know that any missing values are zero, by using `values_fill=0`

You usually only choose one column to show down the side, one column to spread across the top, and one column to display the value. 

2.  Complex example: Get the change by year within each county.

      annual_ppp <- 
        mutate  ( approve_year = year (approval_date ) ) %>%
        group_by ( project_county, approve_year) %>%
        summarise ( loans = n() , 
                    amount = sum( amount, na.rm=T), 
                    .groups="drop_last") 
                    
Next, compare them within groups. New functions introduced: `complete()`, which fills in missing information in a sequence. For example, if there were missing years by county, it would create a row to fill it in. `lag()` refers to the previous item in a group. First, make a new, summarized data frame with just the columns you nee

                    
        complete ( project_county, approve_year, 
                  fill= list (amount=0, loans =0) )%>%
        mutate ( change_loans = loans - lag(loans), 
                 pct_change_loans = change_loans / lag(loans) * 100) 

3.  Pick out the last item in a group, with all of its columns. New verb introduced : `slice_tail()` . This is particularly useful for chronological events, such as the last thing that happened in a court case, or the most recent complaint against a police officer. This example isn't a great one, but it gets you the name and other details of the most recent loan for each lender

        arrange ( lender, date_approved) %>%
        group_by ( lender) %>%
        slice_tail()

## Do the same thing on many columns at once

These examples use a new concept, called `across`. It's a way to do the same thing to all of the columns at the same time, replacing the original value with a new one. They can be tricky to write, and I'm not sure I understand them completely. They can also be really, really slow on large datasets.

1.  Convert all character columns to upper case for easier filtering

```
   mutate (across ( where (is.character) , toupper))
```

2.  Strip all punctuation from a set of columns for easier filtering and grouping

**New functions introduced: str_squish() to remove extra blanks, and str_replace_all() to replace all punctuation with nothing. The \~ is needed to put an expression when you use "across" to refer to a bunch of columns at the same time.**

```
  mutate ( across ( c(borrower_name, borrower_address, borrower_city),                 ~str_squish( 
                      str_replace_all ( ., "[:punctuation:]","")
                            )
                  )
        )
```

## Better looking tables

One of the big annoyances in R is that the results are, well, unreadable. Numbers aren't formatted, you can't see all of the data you want, and it's hard to share the results.

Think of this as a quick tour of some options you have to make better looking tables and readable output. In practice, I use one of three:

-   `reactable` provides a powerful way to make sortable, searchable tables in your markdown. It's great for sharing data with people who just want to explore it. Just be careful not to include so many rows that it can't be opened effectively in your browser.

-   `gt` makes very professional looking static tables, such as those you might see in a book. They're good for labeling, footnotes and other details when you don't want anyone to change anything.

Both `reactable` and `gt` will produce subtotals and other math , meaning you can show multiple levels at once. The examples will use the PPP data for each county in Arizona by month.

### Strategy {-}

Typically, you'll do all of your data processing in a series of steps that culminate all of the columns you'll need for any table you want to make -- this will include any grouping, joining or computations that you've already made.

This can be a challenge to get right on sorting, but it otherwise works OK.

#### Make the data frame you want to display and save it {-}

This example:

1.  Converts dates to months by converting it to a character column formatted as the year-month to keep a sort order proper.

2.  Replaces missing counties with "UNKNOWN" and keeps only those in Arizona.

3.  Computes totals by month.

4.  Saves it to a data frame called `ppp_fortable`.


```r
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
```

### Reactable: Sortable, searchable tables with formatted numbers {-}

This is how you can make a sortable, searchable table. The syntax and grammar of this is completely different than what you're used to because it's an implementation of a Javascript library:


```r
ppp_fortable %>%
reactable (  defaultPageSize = 15,
             defaultColDef = colDef ( filterable=TRUE, 
                                      sortable=TRUE,
                                      format = colFormat(digits = 0, separators=TRUE) 
                                       ), 
              columns  = list (
                  project_county = colDef ("County"), 
                  month = colDef ("Month"), 
                  loans  = colDef ("# of loans", align="right", filterable=FALSE), 
                  total_amt = colDef ("$ amount", 
                                       align="right", 
                                      format = colFormat (
                                              separators=TRUE, prefix="$", digits=0)
                                      )
                  
                 )
            )
```
![react 1]{assets/images/r-recipes-react1.png}{width=100%}

### Pivoted reactable table {-}

This isn't a great example, but you could turn it into a monthly table by pivoting the data before printing. I also added some formatting to this example so you can see how to reduce the size, put in scrollbars, etc. They're optional. 



```r
ppp_fortable %>%
  ungroup() %>%
  arrange ( month) %>%
  pivot_wider ( names_from = month, 
                values_from = total_amt, 
                values_fill = 0, 
                id_cols = project_county) %>%
  reactable ( # these options make it scrollable and smaller print
              wrap=FALSE,
              width=700,
              theme = reactableTheme( style=list(fontSize="smaller", 
                                                 color="DimGray", 
                                                 fontFamily="sans-serif")),
              #these options set the default column format.
              defaultColDef = colDef ( format=colFormat ( 
                                                 separators=TRUE,
                                                 digits=0, 
                                                 prefix="$"
                                                 ), 
                                       minWidth=150) , 
      # Here you'd list anything that defies the normal column defaults
    columns = list(
        project_county = colDef ("County", format=colFormat(prefix = ""))
           )
)
```

![react_example2](assets/images/r-recipes-react2.png){width=100%}

### Static table with subtotals and percentages using `gt`

This will include a section on `gt`, which is one option for good-looking static tables.  This starts with a data frame containing totals by sector and county, with just a few counties and sectors picked out. 




There is  a LOT of typing to do to get a good looking static table, but it can be worth it. Consider saving a simple example to your Rstudio snippets to pull out whenever you need it. 



```r
library(gt)

ppp_subtotals %>%
  group_by (project_county) %>%
  gt ( ) %>%
  fmt_number ( columns = c(loans), decimals=0, sep_mark=",") %>%
  fmt_currency ( columns = c(amount, forgiven), 
                           currency = "USD", 
                           decimals= 0) %>%
  summary_rows ( columns = c(loans:forgiven),
                  groups=TRUE, 
                  fns = list( Total="sum"), 
                  formatter = fmt_number, 
                  decimals=0, 
                 use_seps=TRUE) %>%
  grand_summary_rows ( 
       columns = c( amount:forgiven), 
       fns = list (`Grand Total` = "sum"), 
       formatter = fmt_currency,
       decimals=0
  )
```

```{=html}
<div id="dpqdtsbccb" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#dpqdtsbccb .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#dpqdtsbccb .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#dpqdtsbccb .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#dpqdtsbccb .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#dpqdtsbccb .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#dpqdtsbccb .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#dpqdtsbccb .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#dpqdtsbccb .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#dpqdtsbccb .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#dpqdtsbccb .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#dpqdtsbccb .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#dpqdtsbccb .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#dpqdtsbccb .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#dpqdtsbccb .gt_from_md > :first-child {
  margin-top: 0;
}

#dpqdtsbccb .gt_from_md > :last-child {
  margin-bottom: 0;
}

#dpqdtsbccb .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#dpqdtsbccb .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#dpqdtsbccb .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#dpqdtsbccb .gt_row_group_first td {
  border-top-width: 2px;
}

#dpqdtsbccb .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#dpqdtsbccb .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#dpqdtsbccb .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#dpqdtsbccb .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#dpqdtsbccb .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#dpqdtsbccb .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#dpqdtsbccb .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#dpqdtsbccb .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#dpqdtsbccb .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#dpqdtsbccb .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#dpqdtsbccb .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#dpqdtsbccb .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#dpqdtsbccb .gt_left {
  text-align: left;
}

#dpqdtsbccb .gt_center {
  text-align: center;
}

#dpqdtsbccb .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#dpqdtsbccb .gt_font_normal {
  font-weight: normal;
}

#dpqdtsbccb .gt_font_bold {
  font-weight: bold;
}

#dpqdtsbccb .gt_font_italic {
  font-style: italic;
}

#dpqdtsbccb .gt_super {
  font-size: 65%;
}

#dpqdtsbccb .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#dpqdtsbccb .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#dpqdtsbccb .gt_slash_mark {
  font-size: 0.7em;
  line-height: 0.7em;
  vertical-align: 0.15em;
}

#dpqdtsbccb .gt_fraction_numerator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: 0.45em;
}

#dpqdtsbccb .gt_fraction_denominator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: -0.05em;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1"></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">sector</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">loans</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">amount</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">forgiven</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <td colspan="5" class="gt_group_heading">COCONINO</td>
    </tr>
    <tr class="gt_row_group_first"><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">45 - Retail Trade</td>
<td class="gt_row gt_right">142</td>
<td class="gt_row gt_right">$6,034,677</td>
<td class="gt_row gt_right">$5,125,553</td></tr>
    <tr><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">54 - Professional and Technical Services</td>
<td class="gt_row gt_right">332</td>
<td class="gt_row gt_right">$14,194,790</td>
<td class="gt_row gt_right">$11,080,115</td></tr>
    <tr><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">72 - Accommodation and Food Services</td>
<td class="gt_row gt_right">518</td>
<td class="gt_row gt_right">$75,391,291</td>
<td class="gt_row gt_right">$56,706,533</td></tr>
    <tr><td class="gt_row gt_right gt_stub gt_summary_row gt_first_summary_row thick gt_last_summary_row">Total</td>
<td class="gt_row gt_left gt_summary_row gt_first_summary_row thick gt_last_summary_row">&mdash;</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">992</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">95,620,758</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">72,912,201</td></tr>
    <tr class="gt_group_heading_row">
      <td colspan="5" class="gt_group_heading">MARICOPA</td>
    </tr>
    <tr class="gt_row_group_first"><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">45 - Retail Trade</td>
<td class="gt_row gt_right">4,395</td>
<td class="gt_row gt_right">$229,048,373</td>
<td class="gt_row gt_right">$203,849,039</td></tr>
    <tr><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">54 - Professional and Technical Services</td>
<td class="gt_row gt_right">17,513</td>
<td class="gt_row gt_right">$1,171,017,897</td>
<td class="gt_row gt_right">$1,006,574,907</td></tr>
    <tr><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">72 - Accommodation and Food Services</td>
<td class="gt_row gt_right">7,848</td>
<td class="gt_row gt_right">$1,016,174,986</td>
<td class="gt_row gt_right">$747,856,856</td></tr>
    <tr><td class="gt_row gt_right gt_stub gt_summary_row gt_first_summary_row thick gt_last_summary_row">Total</td>
<td class="gt_row gt_left gt_summary_row gt_first_summary_row thick gt_last_summary_row">&mdash;</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">29,756</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">2,416,241,256</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">1,958,280,803</td></tr>
    <tr class="gt_group_heading_row">
      <td colspan="5" class="gt_group_heading">PIMA</td>
    </tr>
    <tr class="gt_row_group_first"><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">45 - Retail Trade</td>
<td class="gt_row gt_right">793</td>
<td class="gt_row gt_right">$37,791,703</td>
<td class="gt_row gt_right">$33,745,398</td></tr>
    <tr><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">54 - Professional and Technical Services</td>
<td class="gt_row gt_right">2,525</td>
<td class="gt_row gt_right">$153,636,306</td>
<td class="gt_row gt_right">$138,369,541</td></tr>
    <tr><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">72 - Accommodation and Food Services</td>
<td class="gt_row gt_right">1,429</td>
<td class="gt_row gt_right">$185,384,342</td>
<td class="gt_row gt_right">$127,931,050</td></tr>
    <tr><td class="gt_row gt_right gt_stub gt_summary_row gt_first_summary_row thick gt_last_summary_row">Total</td>
<td class="gt_row gt_left gt_summary_row gt_first_summary_row thick gt_last_summary_row">&mdash;</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">4,747</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">376,812,351</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">300,045,989</td></tr>
    <tr class="gt_group_heading_row">
      <td colspan="5" class="gt_group_heading">PINAL</td>
    </tr>
    <tr class="gt_row_group_first"><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">45 - Retail Trade</td>
<td class="gt_row gt_right">189</td>
<td class="gt_row gt_right">$3,502,229</td>
<td class="gt_row gt_right">$2,833,964</td></tr>
    <tr><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">54 - Professional and Technical Services</td>
<td class="gt_row gt_right">526</td>
<td class="gt_row gt_right">$12,573,265</td>
<td class="gt_row gt_right">$10,411,520</td></tr>
    <tr><td class="gt_row gt_right gt_stub"></td>
<td class="gt_row gt_left">72 - Accommodation and Food Services</td>
<td class="gt_row gt_right">338</td>
<td class="gt_row gt_right">$17,078,884</td>
<td class="gt_row gt_right">$13,967,079</td></tr>
    <tr><td class="gt_row gt_right gt_stub gt_summary_row gt_first_summary_row thick gt_last_summary_row">Total</td>
<td class="gt_row gt_left gt_summary_row gt_first_summary_row thick gt_last_summary_row">&mdash;</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">1,053</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">33,154,378</td>
<td class="gt_row gt_right gt_summary_row gt_first_summary_row thick gt_last_summary_row">27,212,563</td></tr>
    <tr><td class="gt_row gt_right gt_stub gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">Grand Total</td>
<td class="gt_row gt_left gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">&mdash;</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">&mdash;</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">$2,921,828,743</td>
<td class="gt_row gt_right gt_grand_summary_row gt_first_grand_summary_row gt_last_summary_row">$2,358,451,556</td></tr>
  </tbody>
  
  
</table>
</div>
```


