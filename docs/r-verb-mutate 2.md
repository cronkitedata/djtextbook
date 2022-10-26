# Verbs in depth: New from old data with Mutate  {#r-verb-mutate}


:::{.alert .alert-secondary}

<p class="alert-heading font-weight-bolder fs-3">
In this chapter
</p>

* Creating new columns with `mutate()` 
* Combine summary and detail into one data frame
* Replacing `NA` values 
* Using conditional commands `if_else()` and `case_when()` to create categories

::: 

This continues the work using Arizona Paycheck Protection Program loans.  Full documentation of the dataset is in the [Appendix](appendix-ppp.html).   









To follow along, open your PPP project and create a new markdown the usual way, including the usual setup chunk. This will let us make numbers more readable. Read the data into your environment using this code chunk:

:::


```r
ppp_orig <- 
  readRDS( 
   url ( 
     "https://cronkitedata.s3.amazonaws.com/rdata/ppp_az_loans.RDS"
       )
   )
```

 
## `mutate` to create new columns

Use the verb `mutate` whenever you want to create or change existing columns in your data. 

Examples of this include: 

* Computing difference or percent difference
* Collapsing or creating categories for more meaningful analysis
* Replacing `NA` values with "Unknown" or zero. 

You will often use a combination of filtering and mutating to create a new data frame using the `<-` assignment to use in future code chunks. That's because they can get complex, and you don't want to repeat code that you might have to change over and over.


### Math on columns: compute difference and percent difference 

Here's an example of computing the difference and percent difference between the amount received and the amount forgiven. Before you run this, try to think of why a reporter might be interested in this list, especially in the order that it's being listed.^[There is something called "date math", which lets you compute intervals between dates, ages, and the like. We're skipping this, but get some help if you want to use it. It's a little tricky.]


```r
ppp_orig %>%
  select ( borrower_name, borrower_city, amount, forgiveness_amount) %>%
  filter ( forgiveness_amount > 0) %>%
  mutate ( amt_diff = amount - forgiveness_amount, 
           amt_pct_diff = amt_diff / amount  ) %>%
  arrange  ( amt_pct_diff) %>%
  head(5)
```

### Detail and total with summary statistics

In the last chapter, you saw how to use `mutate` to compute the total and sub-total of the number of rows in a summary. You can use any of the summary statistics to get totals for your entire data frame in a mutate statement. 

Use the single "=" sign to provide a name for the new column and  create more than one new column using a comma between them: 

```markdown

mutate ( avg_loan_size = mean( amount ), 
         median_loan_size = median ( amount ))

```

### Converting NA to 0 

NOTE: Beginning with this code chunk, the tutorial begins saving interim data frames every time you make a change. 

We would like to convert the forgiven amount from a missing value to zero, under the idea that if they have not filled it out, nothing has (yet) been forgiven. Of course, we'd have to check that with the SBA before publication. 

There is a specific function used for that: `replace_na()`:



```r
ppp_forgiven_fixed <- 
  ppp_orig %>%
  mutate (amount_forgiven = replace_na(forgiveness_amount, 0))
```


(Note that nothing came out in this code chunk because the result was saved into a new data frame variable.)

## Working with text using conditional statements 

Very often, you'll want to categorize entries in a database in order to make it simpler to count and sum the values in a meaningful way. For example, the `business_type` column has 23 different values, and isn't always filled in. Some are variants of others: 


<div class="kable-table">

|business_type                       | # of rows|
|:-----------------------------------|---------:|
|Limited  Liability Company(LLC)     |     57744|
|Sole Proprietorship                 |     38587|
|Corporation                         |     27723|
|Subchapter S Corporation            |     13895|
|Independent Contractors             |     13604|
|Self-Employed Individuals           |     10452|
|Non-Profit Organization             |      2606|
|Single Member LLC                   |      1314|
|Partnership                         |      1198|
|Limited Liability Partnership       |      1074|
|Professional Association            |       606|
|501(c)3 – Non Profit                |       157|
|501(c)6 – Non Profit Membership     |        62|
|NA                                  |        42|
|Cooperative                         |        35|
|Qualified Joint-Venture (spouses)   |        32|
|Tenant in Common                    |        32|
|Trust                               |        32|
|Non-Profit Childcare Center         |        29|
|Joint Venture                       |        21|
|Tribal Concerns                     |        15|
|Employee Stock Ownership Plan(ESOP) |         6|
|501(c)19 – Non Profit Veterans      |         1|
|Rollover as Business Start-Ups (ROB |         1|

</div>


One way to work with these is to create new columns with yes-no indicators for certain types of businesses like non-profits or individuals vs. companies. 

### Categories using `if_else`


The function to do this is  `if_else()` , which tests a condition exactly the same way `filter` did, but then assigns a value based on whether it's met or not. Here's the general form of what it looks like: 

```markdown

new_column_name = if_else ( test the old column for something as in a a filter,
                         give it a value if it's true,
                         give it another value if it's not true)

```

So here is a way to do this with the business_type using the same %in% operator you used in the `filter` lesson, saving it to new data frame in your Environment, then displaying the resulting data frame:   



```r
ppp_category_indiv <- 
  ppp_forgiven_fixed %>%
  mutate ( is_individual = 
              if_else ( business_type %in% 
                          c("Independent Contractors", 
                            "Sole Proprietorship", 
                            "Self-Employed Individuals", 
                            "Single Member LLC"), 
                        "Individual", 
                        "Organization")
  )  


# now you can print out the ones that were changed to check them:

ppp_category_indiv %>%
  group_by ( business_type, is_individual) %>%
  summarise ( n = n(), .groups="drop") %>%
  arrange ( desc(n) ) %>% 
  head(5)
```

<div class="kable-table">

|business_type                   |is_individual |     n|
|:-------------------------------|:-------------|-----:|
|Limited  Liability Company(LLC) |Organization  | 57744|
|Sole Proprietorship             |Individual    | 38587|
|Corporation                     |Organization  | 27723|
|Subchapter S Corporation        |Organization  | 13895|
|Independent Contractors         |Individual    | 13604|

</div>


### Categories using pattern matching 

You can also use the same `str_detect()` function you used in filtering. Here, it sets whether or not the borrower was a non-profit. The period means "nothing or any 1 character" because sometimes it's listed with a dash and sometimes it's not. 



```r
ppp_category_nonprofit <-
  ppp_category_indiv %>%
  mutate ( is_nonprofit = 
             if_else ( str_detect(business_type, "Non.Profit") , 
                       "Is nonprofit", 
                       "Not nonprofit"))  



ppp_category_nonprofit %>%
  count ( business_type, is_nonprofit) %>%
  filter ( is_nonprofit == "Is nonprofit")
```

<div class="kable-table">

|business_type                   |is_nonprofit |    n|
|:-------------------------------|:------------|----:|
|501(c)19 – Non Profit Veterans  |Is nonprofit |    1|
|501(c)3 – Non Profit            |Is nonprofit |  157|
|501(c)6 – Non Profit Membership |Is nonprofit |   62|
|Non-Profit Childcare Center     |Is nonprofit |   29|
|Non-Profit Organization         |Is nonprofit | 2606|

</div>


(The profit categorization is unclear for some of these types, such as professional associations , tribal concerns and cooperatives.)

### More than one outcome 

Sometimes you will want more than one outcome, such as setting a value for "High", "Medium" and "Low". Instead of `if_then`, use the function `case_when`, which looks like this: 


```markdown

case_when ( first condition ~ what if it's true,
            second condition ~ what if  it's true, 
            third condition  ~ what if it's true, 
            TRUE ~ what to do with everything that's left
            )

```




## Putting it all together


Here is how you could set a column to with five types of borrowers instead of three. It's a little complicated, but see if you can follow along, using your knowledge of pattern matching: 



```r
ppp_business_categories <- 
  ppp_category_nonprofit %>%
  mutate (  new_business_type = 
                case_when (  str_detect(business_type, "Non.Profit") ~ "Non-profit", 

                             business_type %in% 
                               c("Independent Contractors", 
                                "Sole Proprietorship", 
                                "Self-Employed Individuals", 
                                  "Single Member LLC")              ~ "Individual", 
                             
                             business_type == "Tribal Concerns"     ~ "Tribal concerns", 
                             
                             str_detect (business_type, "LLC|Company|Corporation|Partnership") ~ "Companies", 
                             
                             TRUE ~ "Other") 
            )


# Now compare what they were to what they are:

ppp_business_categories %>%
  group_by ( new_business_type, business_type) %>%
  summarise ( "# of loans" = n(), .groups="drop")
```

<div class="kable-table">

|new_business_type |business_type                       | # of loans|
|:-----------------|:-----------------------------------|----------:|
|Companies         |Corporation                         |      27723|
|Companies         |Limited  Liability Company(LLC)     |      57744|
|Companies         |Limited Liability Partnership       |       1074|
|Companies         |Partnership                         |       1198|
|Companies         |Subchapter S Corporation            |      13895|
|Individual        |Independent Contractors             |      13604|
|Individual        |Self-Employed Individuals           |      10452|
|Individual        |Single Member LLC                   |       1314|
|Individual        |Sole Proprietorship                 |      38587|
|Non-profit        |501(c)19 – Non Profit Veterans      |          1|
|Non-profit        |501(c)3 – Non Profit                |        157|
|Non-profit        |501(c)6 – Non Profit Membership     |         62|
|Non-profit        |Non-Profit Childcare Center         |         29|
|Non-profit        |Non-Profit Organization             |       2606|
|Other             |Cooperative                         |         35|
|Other             |Employee Stock Ownership Plan(ESOP) |          6|
|Other             |Joint Venture                       |         21|
|Other             |Professional Association            |        606|
|Other             |Qualified Joint-Venture (spouses)   |         32|
|Other             |Rollover as Business Start-Ups (ROB |          1|
|Other             |Tenant in Common                    |         32|
|Other             |Trust                               |         32|
|Other             |NA                                  |         42|
|Tribal concerns   |Tribal Concerns                     |         15|

</div>

(You might notice the indentation and the spacing in this code chunk, making it easier to identify exactly what's happening in each sub-phrase.)

Now, when you want to look at the types of companies, you can do it with fewer groups. Note that it uses the fixed amount for "forgiven", not the original with the `NA`. You could have skipped that, and used `forgiven = sum(forgiveness_amount, na.rm=T)`: 



```r
ppp_business_categories %>%
  group_by ( new_business_type) %>%
  summarise ( "# of loans" = n(), 
              total_amount  = sum(amount), 
              forgiven = sum(amount_forgiven) , 
              forgiveness_pct = forgiven / total_amount * 100, 
              .groups="drop")
```

<div class="kable-table">

|new_business_type | # of loans| total_amount|   forgiven| forgiveness_pct|
|:-----------------|----------:|------------:|----------:|---------------:|
|Companies         |     101634|  10553908671| 9002387186|        85.29908|
|Individual        |      63957|   1071395478|  744840040|        69.52055|
|Non-profit        |       2855|    657187325|  530224118|        80.68082|
|Other             |        807|     98775038|   89605080|        90.71632|
|Tribal concerns   |         15|     11533963|    8920104|        77.33771|

</div>

Explore some of these data frames by clicking on them in the Environment tab and see if you can tell whether the formulas worked. 


### Save it for use in another program {-}


Saving this for future use means you don't have to worry anymore about some of the missing values, and you can filter and group by the simpler new business type instead of the original. 


```markdown

saveRDS(ppp_business_categories, file="ppp_edited.RDS")


```


