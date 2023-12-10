# Converting textbook to quarto

## To do

1. Convert all file names to qmd from rmd
2. Convert the _bookdown yaml to _quarto yaml 
3. Convert the top section yamls. 
4. Possibly: Update tinytex for pdf version. 
5. Update the r markdown chapter - switch it to Quarto and use preview mode (with warnings. )


## Cx 

1. Excel: Make sure to make a big deal about missing column info in pivot tables. 
2. 

## Github? Not sure there's any reason for it. 

If we're going to just use it , I can just get it from them on Canvas. Don't bother with it until later in the semester, when it's time to make a website. 


Parts I got rid of: 

## Fuzzy matching with patterns

So far, you've had to do all of your filters for character columns matching exactly. You can see that's rarely going to be useful in columns like names, cities, or addresses.

Enter the idea of fuzzy filtering, called *pattern matching* using *regular expressions*. We're going to use a package that is part of the tidyverse called `stringr` to do this.

::: {.alert .alert-info}
Googling for help in "regular expressions" or "pattern matching" in R will likely bring back instructions on how to use base R, not the `stringr` package from the tidyverse. If you get answers that include "grep" or "grepl", try adding the word "tidyverse" or "stringr" to your Google query.
:::

This chapter has the very basics of pattern matching. There will be an entire chapter on it later in the semester. It's one of the most powerful things you can do in programming languages.[^r-verb-filter-2]

[^r-verb-filter-2]: Every computer language -- except the Excel default interface -- has an implementation of regular expressions, which is the same thing as pattern matching. This is one of the major strengths of Google Sheets over Excel.

### Regular expressions - the short version {.unnumbered}

Regular expressions search for patterns rather than exact words or phrases. You can use them to search a column, to extract a piece of a column in each row, or to replace them. They only work on *strings*, which is computer-eze for text or character columns.

For filtering, the function `str_detect()` *detects* whether or not a *string* exists in a cell. It looks a little different than the usual filter command. It's a function that takes two arguments: The column name to work on and the regular expression to look for. It looks like this:

``` markdown

filter ( str_detect ( a_column_name, "a regular expression" ))
```

Here are some basic rules for the pattern:

-   `^` means "the pattern must come at the beginning of the string"
-   `$` means "the pattern must come at the end of the string"
-   `|` means "or", just as it does in the filter. So "(LLC\|CORP\|INC)" would look for "LLC", "CORP", or "INC"
-   `.*` means "anything or nothing"
-   `?` means "It might or might not exist at all" . You usually need to put a phrase or set of letters in parentheses to make it work properly.

There are many more instructions you can add, but for now we'll just stick with these.

### Examples of regular expressions {.unnumbered}

To filter for any address containing "Central Ave":

``` markdown

filter ( str_detect(borrower_address, "Central Ave"))
```

To filter for any address using Central, Fillmore or Taylor in the zip code "85004":

``` markdown

filter (str_detect (borrower_name, "Central|Fillmore|Taylor") &  
                    borrower_zip == "85004"
        )
```

To filter for any kind of non-profit:

``` markdown

filter (str_detect (business_type, "^Non-Profit"))
```

To filter for "Fillmore St" when you don't know if it might be misspelled as "Filmore".

``` markdown

filter (str_detect (borrower_address, "Fill?more"))
```

Here is how you'd look for everything on North Scottsdale Road, when you don't know whether it's "N" or "North" and "Road" or "Rd":

``` markdown

filter ( str_detect( business_address, "N(orth)? Scottsdale R(oa)?d") )
```

We'll see later in the semester how to standardize names and addresses so you don't have to guess -- it's one of the more time consuming and difficult things to do in data journalism. It's what trips up most people who try to report on campaign finance.

## Your turn

Create a new markdown document with the [YAML (front matter) and setup chunk](https://gist.githubusercontent.com/sarahcnyt/e60ad2d7ccf65498fc88791f3bb683ae/raw/bcf4fb844d183b62f531a74a445271c5571f3a1d/cronkite-boilerplate.Rmd) that you used in the last chapter.

Create an introduction summarizing what this program does. You may want to just leave room for it now, and come back to it once you're finished.

Add a sub-heading that provides documentation and sourcing of the data. You can load the data at the same time using this code chunk[^r-verb-filter-3]:

[^r-verb-filter-3]: This is a "nested" function - a function within a function. The readRDS() function reads a native R file from your computer. The url() function tells R that this file exists on the internet, not on your computer.

``` markdown

ppp_orig <- readRDS( url ( "https://cronkitedata.s3.amazonaws.com/rdata/ppp_az_loans.RDS"))
```

Next, add a code chunk with the `glimpse(ppp_orig)` command to get a list of the columns in order.

### Filtering your data {.unnumbered}

Create code chunks that will filter for the following values. You can select just the columns you want to see in whatever sort order makes sense for you to troubleshoot. You can rewrite the list below into plain English sentences to introduce the code chunks.

Find the following sets of loans, and try to think about why these might make for interesting or possible story ideas.

1.  At least \$1 million

2.  Under \$1,000

3.  Under \$1,000 for projects in Maricopa County

4.  Loans that were paid in full but not forgiven. In other words, the borrower decided to pay it back rather than ask for taxpayers to cover it. (These loans are shown as missing, or `NA` in the forgiveness_amount column)

5.  Loans that had more forgiven than approved.

6.  Loans in Phoenix, Scottsdale and Tempe

7.  Loans in Arizona that were for projects out of state.

8.  McDonald's franchises. (I removed the apostrophe.)

9.  Any loan to a Native American tribe or nation or reservation. Hint: It's hard to do this because "NATION" could be part of the word "NATIONAL" and "TRIBE" could be part of the word "TRIBECA" and "RESERVATION" could be part of the word "PRESERVATION". You can use a special character to look for "word boundaries" : `\\b`. To find just the word "NATION", it would look like this `"\\bNATION\\b"` . Try to see if you can figure out how make it work when you want to use all three words.

10. Your turn! Think of one filter you want to make based on what is in this chapter.
