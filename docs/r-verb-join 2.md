# Verbs in depth:  Matchmaking with joins { #r-verb-join}

:::{.alert .alert-secondary}

<p class="alert-heading font-weight-bolder fs-3">
In this chapter
</p>

*  A `join` combines two or more tables (data frames) by column 
*  joining to data frames requires exact matches on one or more columns. Close matches don't count. 
*  Use codes in one data frame to "look up" information in another, and attach it to a row, such as the translation of codes to words or demographics of a Census tract.  
*  Many public records databases come with "lookup tables" or "code sheets". Make sure to ask for the codes AND their translations in a data request. 
*  Reporters don't always stick to matchmaking the way the database designers intended. "Enterprise" joins are those that let you find needles in a haystack, such as bus drivers with a history of DUIs. 
*  Matching one data frame against an entirely different one will always produce errors. You can minimize the *kind* of error you fear most -- false positives or false negatives -- but you likely will have to report out your findings on the ground. 
::: 


## Join basics 

Here is a great explainer on joins made by a previous MAIJ student, Andy Blye. Be sure to watch it: 


<iframe width="560" height="315" src="https://www.youtube.com/embed/4xPrnDYZXw4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

`joins` in computer programming means adding columns to a data frame by combining it with another data frame or table.  Reporters use it in many ways, some intended by the people who made the data source, and some not.^[From now on, we'll start using the term "table" instead of "data frame", since we can talk about several different ones at the same time.] 

Many databases are created expecting you to join tables (data frames) because it's a more efficient way to store and work with large databases. This is what's called a "relational database", and they're everywhere (or at least everywhere that has updated its computer systems since 1980 or so).  

Here's an example, using campaign finance information. The Federal Elections Commission distributions campaign contribution in *related* tables, each referring to a different noun. One table lists donations, the other lists candidates and other political action committees. They link together using a common code: 

![Campaign finance join](assets/images/r-verb-join-diagram.png){width=100%}


The reason to do this is that you never have to worry that any changes to the candidate information -- the treasurer, the address or the office sought -- carries over to the donation. It's only listed once in the candidate table. Most large databases are constructed this way. For example:

* Your school records are held using your student ID, which means that your address and home email only needs to be changed once, not in every class or in every account you have with the school. 
* Inspection records, such as those for restaurants, hospitals, housing code violations and workplace safety, typically have at least *three* tables: The establishment (like a restaurant or a workplace), an inspection (an event on a date), and a violation (something that they found). They're linked together using establishment ID's. 
* A court database usually has many types of records: A master case record links to information on charges, defendants, lawyers, sentences and court hearings. 

Each table, then, is described using a different noun -- candidates or contributions; defendants or cases; students or courses. This conforms to the **tidy data** principle that different types of information are stored in different tables. 

### join syntax 

There are several kinds of joins, but the syntax is similar across them. 

```
  old_table_1 %>%
     inner_join (new_table , by=c("old table col. name" = "new table col. name") )
     
```

## Matchmaking with joins

The type of join described above is often referred to as a "lookup table". You'll match codes to their meanings in a way that was intended by the people who made the database. 
But there are other ways reporters use joins: 

###  "Enterprise" joins {-}

Journalists have taken to calling a specific kind of join "enterprise", referring to the enterprising reporters who do this. Here, you'll look for needles in  a haystack. Some of the most famous data journalism investigations relied on joining two databases that started from completely different sources, such as: 

* Bus drivers who had DUI citations 
* Donors to a governor who got contracts from the state
* Day care workers with criminal records 
* Small businesses that have defaulted on government backed loans that got a PPP loan anyway.

When you match these kinds of datasets, you will always have some error. You always have to report out any suspected matches, so they are time consuming stories. 

In the mid-2000s, when some politicians insisted that dead people were voting and proposed measures to restrict registration, almost every regional news organization sent reporters on futile hunts for the dead voters. They got lists of people on the voter rolls, then lists of people who had died through the Social Security Death Index or local death certificates. I never met anyone who found a single actual dead voter, but months of reporter-hours were spent tracking down each lead.

It's very common for two people to have the same name in a city. In fact, it's common to have two people at the same home with the same name -- they've just left off "Jr." and "Sr." in the database. In this case, you'll find matches that you shouldn't.  These are false positives, or Type I errors in statistics. 

Also, we rarely get dates of birth or Social Security Numbers in public records, so we have to join by name and sometimes location. If someone has moved, sometimes uses a nickname, or the government has recorded the spelling incorrectly, the join will fail -- you'll miss some of the possible matches. This is very common with company names, which can change with mergers and other changes in management, and can be listed in many different ways. 

These are false negatives, or Type II errors in statistics.^[I remember them by thinking of the boy who cried wolf. When the village came running and there was no wolf, it was a Type I error, or false positive ; when the village ignored the boy and there was a wolf, it was a Type II error, or false negative.]

In different contexts, you'll want to minimize different kinds of errors. For example, if you are looking for something extremely rare, and you want to examine every possible case -- like a child sex offender working in a day care center -- you might choose to make a "loose" match and get lots of false positives, which you can check. If you want to limit your reporting only to the most promising leads, you'll be willing to live with missing some cases in order to be  more sure of the joins you find. 

You'll see stories of this kind write around the lack of precision -- they'll often say, "we verified x cases of...." rather than pretend that they know of them all. 

### Find cases with interesting characteristics {-}

You'll often want to learn more about a geographic area's demographics or voting habits or other characteristics, and match it to other data. Sometimes it's simple: Find the demographics of counties that switched from Trump to Biden as a way to isolate places you might want to visit. Another example from voting might be to find the precinct that has the highest percentage of Latino citizens in the county, then match that precinct against the voter registration rolls to get a list of people you might want to interview on election day. In these instances, the `join` is used for a `filter`. 

This is also common when you have data by zip code or some other geography, and you want to find clusters of interesting potential stories, such as PPP loans in minority neighborhoods. 

### Summarize data against another dataset {-}

The previous examples all result in lists of potential story people or places. If you use join on summarized data, you can characterize a broad range of activity across new columns. Simplified, this is how you can write that more PPP money went to predominantly white neighborhoods than those that were majority Black.  

## Simple join using PPP industry codes





The PPP data has a code called the `naics_code`, which is a standardized code to identify industries. They are assigned by the company itself or by the bank, not by the government, but they are a good guide. Here is a data frame that contains the list of industries in the PPP data. It was derived from the `concordance` package in R, but is fully explained at the [Census website](https://www.census.gov/naics/?58967?yearbck=2017).

Here are the two tables: The original PPP data, and the industry code "lookup". 


```r
naics_codes <- readRDS( url ( "https://cronkitedata.s3.amazonaws.com/rdata/naics_lookup.RDS"))

ppp_orig <- readRDS (url ( "https://cronkitedata.s3.amazonaws.com/rdata/ppp_az_loans.RDS"))
```


Here is an example of looking at one sector -- the sector code "72" has subsectors and industry codes. Each digit in the code after the 72 refers to a different definition. Those tha end in zero are not as specific as those that have a digit.: 


```r
naics_codes %>% filter ( sector_code == "72") %>%
  select (-sector_code, -subsector_code)
```

<div class="kable-table">

|naics_code |sector_desc                     |subsector_desc                    |naics_desc                                           |
|:----------|:-------------------------------|:---------------------------------|:----------------------------------------------------|
|721110     |Accommodation and Food Services |Accommodation                     |Hotels (except Casino Hotels) and Motels             |
|721120     |Accommodation and Food Services |Accommodation                     |Casino Hotels                                        |
|721191     |Accommodation and Food Services |Accommodation                     |Bed-and-Breakfast Inns                               |
|721199     |Accommodation and Food Services |Accommodation                     |All Other Traveler Accommodation                     |
|721211     |Accommodation and Food Services |Accommodation                     |RV (Recreational Vehicle) Parks and Campgrounds      |
|721214     |Accommodation and Food Services |Accommodation                     |Recreational and Vacation Camps (except Campgrounds) |
|721310     |Accommodation and Food Services |Accommodation                     |Rooming and Boarding Houses                          |
|722110     |Accommodation and Food Services |Food Services and Drinking Places |NA                                                   |
|722211     |Accommodation and Food Services |Food Services and Drinking Places |NA                                                   |
|722310     |Accommodation and Food Services |Food Services and Drinking Places |Food Service Contractors                             |
|722320     |Accommodation and Food Services |Food Services and Drinking Places |Caterers                                             |
|722330     |Accommodation and Food Services |Food Services and Drinking Places |Mobile Food Services                                 |
|722410     |Accommodation and Food Services |Food Services and Drinking Places |Drinking Places (Alcoholic Beverages)                |
|722511     |Accommodation and Food Services |Food Services and Drinking Places |Full-Service Restaurants                             |
|722513     |Accommodation and Food Services |Food Services and Drinking Places |Limited-Service Restaurants                          |
|722514     |Accommodation and Food Services |Food Services and Drinking Places |Cafeterias, Grill Buffets, and Buffets               |
|722515     |Accommodation and Food Services |Food Services and Drinking Places |Snack and Nonalcoholic Beverage Bars                 |

</div>


To put this together with the PPP data, you "join" it using the column that it has in common -- the `naics_code`.  This is an example of an "inner join", in which only the rows that match are kept in the result. The result below uses just a few columns from the saved data frame, and then picks out some random rows to view: 





```r
loans_with_industry <- 
  ppp_orig %>%
  inner_join ( naics_codes, by=c("naics_code"="naics_code"))  
```


(In this case, they have the same column name, but they don't have to. As long as they CONTAIN the same thing, they can have different names. You can also join using more than one column, such as county and state together.)



```{=html}
<div id="htmlwidget-0c89b33167da5a2fb97f" class="reactable html-widget" style="width:auto;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-0c89b33167da5a2fb97f">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"Borrower":["NICOLL CONSTRUCTION LLC","RQ MEXICAN FOOD LLC","NATHAN SMOTHERSON","MATTHEW HARRISON","NAME RECOGNITION MEDIA LLC","EDUARDO ROMERO","MAUREEN MOORE","ROBERT R EYER LLC","MANCINI TUREK CONSULTING LLC","REDLINE TOOLS LLC","ALLEN MANAGEMENT GROUP LLC","PATRICK HARMES","JAIMES BARBER SHOP LLC","ROBERT SANTIESTEBAN OO","DALLAS ALLEN","M SCOTT FERRELL MD PC","1TV","GRACIELA GARCIA","GRANT DESTACHE","JILLIAN JORGENSEN","TONY RIVERA FLOORING LLC","DRIVEN ENTERPRISES AZ LLC","DAMEN FLAGG","PM PROFESSIONAL SERVICES CORPORATION","LYNN HARDER","MICHAEL MONTOYA REAL ESTATE LLC","GIAO PHAM","JOSHUA BUCKNER","SDTT INC","MARYANN REYNA","PIANO GALLERY LLC","YASIME WARD","COEBY BROWN","OLD PUEBLO ANESTHESIA PLLC","LOS LOCOS LLC","BRIAN DALEY","JESSE LEWIS","RAFAEL TIRADO ASSOCIATES PLC","BLINE DIRECTIONAL DRILLING LLC","MINYON HOLLY","MUTUAL PRODUCERS GROUP LLC","ZANAVEA GAINES","KAREN MAY","XAML ZOMBIES INC","CHRISTINA BORREGO","NELI FLORES","LAURA BURK PLLC","GOSERCO INC","MEJDRICH PHOTOGRAPHY LLC DBA SCHOOL PICS","LYDIA SEISE","SUN VALLEY DIESEL AMP AUTOMOTIVE LLC","GFSC INC","SHANE LEWTHWAITE","ELITE BEAUTY WELLNESS","HOT SHOT DELIVERY INC","HASSAN AHMED","KLINGER ENTERPRISE LLC","ARIZONA HEALTHY SMILES","RABADI AND SONS INC","ARIZONA MEDICAL CENTER PLC","SUPERIOR DRYWALL CO INC","BLAKE BOLSER","THE CYCLE DOCTOR","STRAIGHT LINE INSTALLATIONS LLC","CYNTHIA MANNING","TRUC NGUYEN","CARON MITCHELL","ISHA COGBORN","TUCSON EMBEDDED SYSTEMS INC","HOWE PRECAST CONCRETE BARRIER INC","NRG BUILDING SPECIALISTS LLC","LEMUEL TOVAR","BRUCE L NELSON DDS PC","ASHLEY ARMSTRONG","CINDI HAMWRIGHT","MOORE LAW PLLC","RISPOLI LAW PLLC","SHANNON CHI","GLOBAL FAMILY PHILANTHROPY","BBA SYSTEMS LLC","RNM SERVICES INC DBA DIGITALWIRE360","BRIAN GUBERNICK PLLC","LAQUANDRIA MILLER","BANKERS TITLE SERVICE","FLINK MEDICAL BILLING LLC","ORI HEYMAN","SUNDAY BUMPS INC","VAN METRE CHIROPRACTIC PLLC","RITO39S BURRITOS LLC","JESSE VIERA","ROWE ASSOCIATES DENTAL CARE PLLC","BPS TOTAL SOLUTIONS LLC","SPASCHEDULER LLC","PREMIER BACKHOE INC","PCM LLC","HIGH ALTITUDE PERSONAL TRAINING LLC","EAGLE SIGN AND ENGRAVING LLC","ARCELIA BANUELOS","HILLSONG PHOENIX LLC","GUBERNACULUM LLC"],"city":["Eagar","Phoenix","Phoenix","Gilbert","Fountain Hills","Mesa","Surprise","Tucson","Cornville","Tucson","Avondale","Laveen","Phoenix","Tucson","Clay Springs","Tucson","Miami","Chandler","Phoenix","Phoenix","Glendale","Mesa","Goodyear","Gilbert","Phoenix","Phoenix","Phoenix","Laveen","Phoenix","Phoenix","Scottsdale","Tucson","Phoenix","Tucson","Tucson","Glendale","Phoenix","Phoenix","Phoenix","Tolleson","Chandler","Laveen","Scottsdale","Cave Creek","Phoenix","Phoenix","Sun City","Mesa","Phoenix","Glendale","Prescott Valley","Phoenix","Camp Verde","Scottsdale","Phoenix","Phoenix","Casa Grande","Tempe","Phoenix","Yuma","Gilbert","San Tan Valley","Mesa","Phoenix","Phoenix","Queen Creek","Tucson","Chandler","Tucson","Mesa","Sedona","Phoenix","Phoenix","Phoenix","Chandler","Show Low","Phoenix","Tucson","Paradise Valley","Scottsdale","Chandler","Scottsdale","Maricopa","Tucson","Scottsdale","Tempe","Scottsdale","Surprise","Glendale","Tolleson","Glendale","Scottsdale","Surprise","Fort Mohave","Flagstaff","Flagstaff","Mesa","Peoria","Mesa","Scottsdale"],"naics_code":["236115","722511","448150","541990","541613","452319","812112","524210","611710","236210","236220","531390","812111","484121","236118","621112","334220","812199","621498","812112","238330","561740","453998","541611","541990","531210","531210","812111","812112","722320","423990","561499","484110","621111","722511","561790","512110","541110","237130","484230","524210","812112","711320","541990","485310","812199","531210","454390","541921","722320","811111","523120","711130","812199","484110","485310","531210","621399","424320","621111","238310","236118","236220","238290","812112","812113","541213","541990","541330","327390","236115","236115","621210","812112","812112","541110","541110","561720","813219","541330","541810","999990","812112","541191","621111","441310","541410","621310","722511","484230","621210","812990","446199","237110","721110","713940","561990","236220","813110","453998"],"sector_desc":["Construction","Accommodation and Food Services","Retail Trade","Professional and Technical Services","Professional and Technical Services","Retail Trade","Other Services","Finance and Insurance","Educational Services","Construction","Construction","Real Estate and Rental and Leasing","Other Services","Transportation and Warehousing","Construction","Health Care and Social Assistance","Manufacturing","Other Services","Health Care and Social Assistance","Other Services","Construction","Administrative and Waste Services","Retail Trade","Professional and Technical Services","Professional and Technical Services","Real Estate and Rental and Leasing","Real Estate and Rental and Leasing","Other Services","Other Services","Accommodation and Food Services","Wholesale Trade","Administrative and Waste Services","Transportation and Warehousing","Health Care and Social Assistance","Accommodation and Food Services","Administrative and Waste Services","Information","Professional and Technical Services","Construction","Transportation and Warehousing","Finance and Insurance","Other Services","Arts, Entertainment, and Recreation","Professional and Technical Services","Transportation and Warehousing","Other Services","Real Estate and Rental and Leasing","Retail Trade","Professional and Technical Services","Accommodation and Food Services","Other Services","Finance and Insurance","Arts, Entertainment, and Recreation","Other Services","Transportation and Warehousing","Transportation and Warehousing","Real Estate and Rental and Leasing","Health Care and Social Assistance","Wholesale Trade","Health Care and Social Assistance","Construction","Construction","Construction","Construction","Other Services","Other Services","Professional and Technical Services","Professional and Technical Services","Professional and Technical Services","Manufacturing","Construction","Construction","Health Care and Social Assistance","Other Services","Other Services","Professional and Technical Services","Professional and Technical Services","Administrative and Waste Services","Other Services","Professional and Technical Services","Professional and Technical Services","Unclassified establishments","Other Services","Professional and Technical Services","Health Care and Social Assistance","Retail Trade","Professional and Technical Services","Health Care and Social Assistance","Accommodation and Food Services","Transportation and Warehousing","Health Care and Social Assistance","Other Services","Retail Trade","Construction","Accommodation and Food Services","Arts, Entertainment, and Recreation","Administrative and Waste Services","Construction","Other Services","Retail Trade"],"subsector_desc":["Construction of Buildings","Food Services and Drinking Places","Clothing and Clothing Accessories Stores","Professional, Scientific, and Technical Services","Professional, Scientific, and Technical Services","General Merchandise Stores","Personal and Laundry Services","Insurance Carriers and Related Activities","Educational Services","Construction of Buildings","Construction of Buildings","Real Estate","Personal and Laundry Services","Truck Transportation","Construction of Buildings","Ambulatory Health Care Services","Computer and Electronic Product Manufacturing","Personal and Laundry Services","Ambulatory Health Care Services","Personal and Laundry Services","Specialty Trade Contractors","Administrative and Support Services","Miscellaneous Store Retailers","Professional, Scientific, and Technical Services","Professional, Scientific, and Technical Services","Real Estate","Real Estate","Personal and Laundry Services","Personal and Laundry Services","Food Services and Drinking Places","Merchant Wholesalers, Durable Goods","Administrative and Support Services","Truck Transportation","Ambulatory Health Care Services","Food Services and Drinking Places","Administrative and Support Services","Motion Picture and Sound Recording Industries","Professional, Scientific, and Technical Services","Heavy and Civil Engineering Construction","Truck Transportation","Insurance Carriers and Related Activities","Personal and Laundry Services","Performing Arts, Spectator Sports, and Related Industries","Professional, Scientific, and Technical Services","Transit and Ground Passenger Transportation","Personal and Laundry Services","Real Estate","Nonstore Retailers","Professional, Scientific, and Technical Services","Food Services and Drinking Places","Repair and Maintenance","Securities, Commodity Contracts, and Other Financial Investments and Related Activities","Performing Arts, Spectator Sports, and Related Industries","Personal and Laundry Services","Truck Transportation","Transit and Ground Passenger Transportation","Real Estate","Ambulatory Health Care Services","Merchant Wholesalers, Nondurable Goods","Ambulatory Health Care Services","Specialty Trade Contractors","Construction of Buildings","Construction of Buildings","Specialty Trade Contractors","Personal and Laundry Services","Personal and Laundry Services","Professional, Scientific, and Technical Services","Professional, Scientific, and Technical Services","Professional, Scientific, and Technical Services","Nonmetallic Mineral Product Manufacturing","Construction of Buildings","Construction of Buildings","Ambulatory Health Care Services","Personal and Laundry Services","Personal and Laundry Services","Professional, Scientific, and Technical Services","Professional, Scientific, and Technical Services","Administrative and Support Services","Religious, Grantmaking, Civic, Professional, and Similar Organizations","Professional, Scientific, and Technical Services","Professional, Scientific, and Technical Services","Unclassified","Personal and Laundry Services","Professional, Scientific, and Technical Services","Ambulatory Health Care Services","Motor Vehicle and Parts Dealers","Professional, Scientific, and Technical Services","Ambulatory Health Care Services","Food Services and Drinking Places","Truck Transportation","Ambulatory Health Care Services","Personal and Laundry Services","Health and Personal Care Stores","Heavy and Civil Engineering Construction","Accommodation","Amusement, Gambling, and Recreation Industries","Administrative and Support Services","Construction of Buildings","Religious, Grantmaking, Civic, Professional, and Similar Organizations","Miscellaneous Store Retailers"],"naics_desc":["New Single-Family Housing Construction (except For-Sale Builders)","Full-Service Restaurants","Clothing Accessories Stores","All Other Professional, Scientific, and Technical Services","Marketing Consulting Services","All Other General Merchandise Stores","Beauty Salons","Insurance Agencies and Brokerages","Educational Support Services","Industrial Building Construction","Commercial and Institutional Building Construction","Other Activities Related to Real Estate","Barber Shops","General Freight Trucking, Long-Distance, Truckload","Residential Remodelers","Offices of Physicians, Mental Health Specialists","Radio and Television Broadcasting and Wireless Communications Equipment Manufacturing","Other Personal Care Services","All Other Outpatient Care Centers","Beauty Salons","Flooring Contractors","Carpet and Upholstery Cleaning Services","All Other Miscellaneous Store Retailers (except Tobacco Stores)","Administrative Management and General Management Consulting Services","All Other Professional, Scientific, and Technical Services","Offices of Real Estate Agents and Brokers","Offices of Real Estate Agents and Brokers","Barber Shops","Beauty Salons","Caterers","Other Miscellaneous Durable Goods Merchant Wholesalers","All Other Business Support Services","General Freight Trucking, Local","Offices of Physicians (except Mental Health Specialists)","Full-Service Restaurants","Other Services to Buildings and Dwellings","Motion Picture and Video Production","Offices of Lawyers","Power and Communication Line and Related Structures Construction","Specialized Freight (except Used Goods) Trucking, Long-Distance","Insurance Agencies and Brokerages","Beauty Salons","Promoters of Performing Arts, Sports, and Similar Events without Facilities","All Other Professional, Scientific, and Technical Services","Taxi Service","Other Personal Care Services","Offices of Real Estate Agents and Brokers","Other Direct Selling Establishments","Photography Studios, Portrait","Caterers","General Automotive Repair","Securities Brokerage","Musical Groups and Artists","Other Personal Care Services","General Freight Trucking, Local","Taxi Service","Offices of Real Estate Agents and Brokers","Offices of All Other Miscellaneous Health Practitioners","Men's and Boys' Clothing and Furnishings Merchant Wholesalers","Offices of Physicians (except Mental Health Specialists)","Drywall and Insulation Contractors","Residential Remodelers","Commercial and Institutional Building Construction","Other Building Equipment Contractors","Beauty Salons","Nail Salons","Tax Preparation Services","All Other Professional, Scientific, and Technical Services","Engineering Services","Other Concrete Product Manufacturing","New Single-Family Housing Construction (except For-Sale Builders)","New Single-Family Housing Construction (except For-Sale Builders)","Offices of Dentists","Beauty Salons","Beauty Salons","Offices of Lawyers","Offices of Lawyers","Janitorial Services","Other Grantmaking and Giving Services","Engineering Services","Advertising Agencies","Unclassified","Beauty Salons","Title Abstract and Settlement Offices","Offices of Physicians (except Mental Health Specialists)","Automotive Parts and Accessories Stores","Interior Design Services","Offices of Chiropractors","Full-Service Restaurants","Specialized Freight (except Used Goods) Trucking, Long-Distance","Offices of Dentists","All Other Personal Services","All Other Health and Personal Care Stores","Water and Sewer Line and Related Structures Construction","Hotels (except Casino Hotels) and Motels","Fitness and Recreational Sports Centers","All Other Support Services","Commercial and Institutional Building Construction","Religious Organizations","All Other Miscellaneous Store Retailers (except Tobacco Stores)"],"amount":[32900,8640,20832,20800,30882,482,19522,5905,40400,1445,13000,2290,33500,5791,20832,20833,10333,20647,20833,9500,20833,60897,17890,90500,20743,8751,8397,20833,124507,6068,58737,20832,17700,1392142.08,2300,13812,13750,142420,413220,12915,11000,20833,20833,5727,5207,20000,10100,258000,52700,20833,46600,61912,1041,10854,97798,17135,20830,48400,36600,37800,1695557,11478,18332,62500,16530,6977,13896,4481.67,1036658.96,331000,58087,2732,48179.2,20832,10260,40900,20897,2559,8052,27400,26430,84765,20833,17907,4167,3750,86629.23,31399,20465,9907,66305,20832,2462,162569.17,55769,60456,35675,2082,514200,21000]},"columns":[{"accessor":"Borrower","name":"Borrower","type":"character"},{"accessor":"city","name":"city","type":"character"},{"accessor":"naics_code","name":"naics_code","type":"character"},{"accessor":"sector_desc","name":"sector_desc","type":"character"},{"accessor":"subsector_desc","name":"subsector_desc","type":"character"},{"accessor":"naics_desc","name":"naics_desc","type":"character"},{"accessor":"amount","name":"amount","type":"numeric"}],"defaultPageSize":10,"paginationType":"numbers","showPageInfo":true,"minRows":1,"style":{"fontSize":"smaller"},"dataKey":"48ca6af4f33635e5a8691f1c3103385c","key":"48ca6af4f33635e5a8691f1c3103385c"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
```


Think about what this  means: You now have another  thing for grouping, so you can see, for instance, how much went to restaurants, or which restaurants on your block got loans. 



## Joining risks 

### joining tl;dr 

There are lots of risks in joining tables that you created yourself, or that were created outside a big relational database system. Keep an eye on the number of rows returned every time that you join -- you should know what to expect. 

### Double counting with joins

We won't go into this in depth, but just be aware it's easy to double-count rows when you join.  Here's a made-up  example, in which a zip code is on the border and is in two counties:

Say you want to use some data on zip codes : 

zip code | county | info
--- | --- | ---
85232 | Maricopa | some data
85232 | Pinal | some more data

and match it to a list of restaurants in a zip code: 

zip code | restaurant name
--- | ---
85232 | My favorite restaurant
85232 | My second-favorite restaurant

When you match these, you'll get **4** rows: 

zip code | county | info | restaurant name
---  | --- | --- | --- 
85232  | Maricopa | some data | My favorite restaurant
85232  | Pinal    | some more data | My favorite restaurant
85232  | Maricopa | some data | My second-favorite restaurant
85232  | Pinal | some more data | My second-favority restaurant

Now, every time you try to count restaurants, these two will be double-counted.

In computing, this is called a "many-to-many" relationship -- there are many rows of zip codes and many rows of restaurants. In journalism, we call it spaghetti. It's usually an unintended mess.

### Losing rows with joins

The opposite can occur if you aren't careful and there are items you want to keep that are missing in your reference table. That's what happened in the immunization data above for the seven schools that I couldn't find. 

## Resources

* The "[Relational data](https://r4ds.had.co.nz/relational-data.html)" chapter in the R for Data Science textbook has details on exactly how a complex data set might fit together. 

* [An example using a superheroes dataset](https://stat545.com/join-cheatsheet.html#left_joinsuperheroes-publishers), from Stat 545 at the University of British Columbia
