# Documentation for PPP data chapters  {#appendix-ppp}

The Paycheck Protection Program was a response to the severe business losses during COVID-19. It provided no-interest, forgiveable loans to cover 2 1/2 months' of payroll and some other expenses during the national shutdown in 2020, and some lost revenue during a second round in early 2021. Restaurants and similar businesses had higher loan amounts than other industries. It was intended to keep restaurants, offices and other small businesses  afloat if they agreed to keep people on their payrolls during covid restrictions. 

The program was administered through the Small Business Administration, but the business owners went to banks to get the loans. (In most cases, the loans became grants -- they never had to be paid back.) Banks got a fee for processing the applications and were never on the hook for anyone who didn't pay it back. 

After several lawsuits, the federal government finally started releasing relatively complete data for each of the 111 million loans in early 2021, and then expanded the reporting later that year. 

## Sources

All data used in this book was downloaded as of January 2022 from the SBA data site at <https://data.sba.gov/dataset/ppp-foia> . 

The data dictionary is distributed at that same site at <https://data.sba.gov/dataset/ppp-foia/resource/aab8e9f9-36d1-42e1-b3ba-e59c79f1d7f0> in an Excel spreadsheet. 

Here is some other background information on the program: <https://www.sba.gov/funding-programs/loans/covid-19-relief-options/paycheck-protection-program>


The data was downloaded using a program to concatenate all of the files into one, large data frame. Only minimal standardization and cleaning was done: 

* All recipient names are in upper case, and periods were removed.
* All city names are in proper case. 

PPP loans have two geographic locations included: The location of the borrower, and the city, county, state and congressional district of the project that is being funded. This is especially important for construction and similar trades that have work done  on sites. 

Most PPP loans were given 24 months to either repay the debt or request forgiveness. None of them have yet met their maturity date, so none are "charged off" or written off by the SBA. 

Arizona loans were extracted if either the borrower or the project was in the state. It contains 169,268 loans. 


## Data used in the tutorials

The columns were renamed and then a selection of those columns were used in the tutorials.  

The files referenced in the tutorials have a selection of columns used out of this list: 


Column name | Type  | Description 
------------| ------ | ---------
loan_number  |  numeric |  The original, unique loan number that was provided by SBA
date_approved | date |  
draw | chr | "First" draw was April 2020-May 2020. "Second" draw was Jan 2021 to May 2021. 
borrower_name | chr | All upper-case name of the borrower, with punctuation removed. 
borrower_address | chr | All proper-case, punctuation removed
borrower_city | chr | All proper-case, punctuation removed
borrower_state | chr | 2-character upper case postal code
borrower_zip | chr | five-digit zip code of the borrower
franchise_name | chr | A "franchise" is a licensed outlet of a larger corporation, such as a McDonald's store. 
loan_status | chr | "Paid in Full", "Active Un-Disbursed" , "Charged Off", or "Exemption 4". . Exemption 4 means that it is still active and has time to apply for forgiveness or payback. 
loan_status_date | date |
amount | numeric | The most recent amount approved by the SBA for this loan
forgiveness_amount | numeric | The amount forgiven in the loan (paid by taxpayers, not the business). This is NA if it has not been forgiven.
forgiveness_date | date | the date the loan was forgiven. NA if it has not been forgiven. 
lender | chr | The name of the original lender. It might have been transferred to another company for further servicing. 
rural_urban | chr | "U" = Urban, "R" = "Rural" The federal governemnt prioritizes loans to rural areas. 
low_income_area | chr | "Y" or "N". These are areas that are considered low-to-moderate income communities that are priorities for the federal government to help finance.
project_county | chr | upper-case name of the county that the project is in. 
project_state | chr | 2-character postal abbreviation for the project city
project_cong_dist | chr | a 5-character congressional district indicator, such as "AZ-04"
employees | num | The number of employees used to compute the loan. 
business_type | chr | One of 24 categories of business, such as "501(c)3 - Non Profit" or "Corporation" or "Sole Proprietership"
naics_code | chr | A 6-digit code indicating the industry of the recipient or project. This will be translated into words using another data set. 

There were other columns in the original data set, but many of them were almost never filled in, or were shown to be inaccurate estimates. 
For example, out of  nearly 170,000 loans, 120,000 of them had no information on race or ethnicity of the business owner. None were marked as veteran-owned or had an owner's gender filled out. Some other columns, such as the current lender (as opposed to the one that made the loan) added complexity without adding much for our purposes. 















