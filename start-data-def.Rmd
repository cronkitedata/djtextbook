# Defining "Data" { #start-data-def}

>data /ˈdeɪ.tə/ :
>
>information in an electronic form that can be stored and used by a computer, or information, especially facts or numbers, collected to be examined and >considered and used to help decision-making
>
> -- Cambridge Dictionary -- sort of ^[I flipped the order of these two definitions!]


## The birth of a dataset 

Most journalism uses data collected for one purpose for something entirely different. Understanding its original uses -- what matters to the people who collected it, and what doesn't -- will profoundly affect its accuracy or usefulness. 

### Trace data and administrative records {-}

In "[The Art of Access](https://www.amazon.com/Art-Access-Strategies-Acquiring-Records/dp/1604265507)", David Cullier  and Charles N. Davis describe a process of tracking down the life and times of a dataset. Their purpose is to make sure they know how to request it from a government agency. The same idea applies to using data that we acquire elsewhere. 

Understanding how and why data exists is crucial to understanding what you, as a reporter, might do with it. 

Anything you can systematically search or analyze could be considered one piece of of data. As reporters, we usually deal with data that was created in the process of doing something else -- conducting an inspection, delivering a tweet, or scoring a musical. In the sciences, this flotsam and jetsom that is left behind is called "digital trace data" if it was born digitally.

In journalism and in the social sciences, many of our data sources were born during some government process -- a safety inspection, a traffic ticket, or the filing of a death certificate. These administrative records form the basis of much investigative reporting and they are often the subject of public records and FOIA requests. They were born as part of the government doing its job, without any thought given to how it might be used in another way. In the sciences, those are often called "administrative records". 

This trace data might be considered the first part of the definition above -- information that can be stored and used.  

Here's how Chris Bail from Duke University describes it: 

<iframe width="560" height="315" src="https://www.youtube.com/embed/uuSWQN7uYhk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### Data collected and curated for analysis {-}

Another kind of data is that which is compiled or collected specifically for the purpose of studying something. It might collected in the form of a survey or a poll, or it might be a system of sampling to measure pollution or weather. But it's there because the information has intrinsic value AS information. 

The video suggests a hard line between trace data and custom data. In practice, it's not that clear. Many newsrooms may curate data published in other sources or in administrative records, such as the Washington Post's police shooting dataset. In other cases, the agencies we are covering get already-compiled data from state and local governments.  

This type of data might be considered the second type in the definition -- tabular information that is used for decision-making.

## Granular and aggregated data 

One of the hardest concepts for a lot of new data journalists is the idea of *granularity* of your data source. There are a lot of ways to think about this: individual items in a list vs. figures in a table; original records vs. compilations; granular data vs. statistics. 

Generally, an investigative reporter is interested in getting data that is as close as possible to the most granular information that exists, at least on computer files. Here's an example , which might give you a little intuition about why it's so important to think this way: 

When someone dies in the US, a standard death certificate is filled out by a series of officials - the attending physician, the institution where they died and even the funeral direcor.  

[Click on this link](https://www.cdc.gov/nchs/data/dvs/death11-03final-acc.pdf) to see a blank version of the standard US death certificate form -- notice the detail and the detailed instructions on how it is supposed to be filled out. ^[You should do this whenever you get a dataset created from administrative records. That is, track down its origin and examine the pieces you were given and the pieces that were left out; look at what is written in free-form vs what is presented as a check box. You may need a copy of the template that an agency uses to collect the information, but many governments make these available on their websites or are willing to provide them without a fuss.]



A good reporter could imagine many stories coming out of these little boxes. Limiting yourself to just to COVID-19-related stories: You could profile the local doctor who signed the most COVID-19-related death certificates in their city, or  examine the number of deaths that had COVID as a contributing, but not underlying or immediate, cause of death. You could compare smoking rates in the city with the number of decedents whose tobacco use likely contributed to their death. Maybe you'd want to know how long patients suffered with the disease before they died. And you could map the deaths to find the block in your town most devastated by the virus. 

Early in the pandemic, Coulter Jones and Jon Kamp examined the records from one of the few states that makes them public, and concluded that "[Coronavirus Deaths were Likely Missed in Michigan, Death Certificates Suggest](https://www.wsj.com/articles/coronavirus-deaths-were-likely-missed-in-michigan-death-certificates-suggest-11590073280] ^[Wall Street Journal, May 21, 2020)"

But you probably can't do that. The reason is that, in most states, death certificates are not public records and are treated as secrets. ^[See "[Secrecy in Death Records: A call to action](https://www.researchgate.net/publication/348322257_Secrecy_in_Death_Records_A_Call_to_Action)", by Megain Craig and Madeleine Davison, Journal of Civic Information, December 2020]. Instead, state and local governments provide limited statistics related to the deaths, usually by county, with no detail.  Here's an example from Arizona: 

![](assets/images/start-data-def-01.png){width=90%}

That's the difference between granular data and aggregate data. Here are some of the typical (not universal) characteristics of each: 

Granular                      | Aggregate
-----                         | -----
Intended for some purpose other than your work  | Intended to be presented as is to the public
Many rows (records), few columns (variables)    | Many columns (variables), few rows (records)
Requires a good understanding of the source     | Explanatory notes usually come with the data
Easy to cross-reference and compile             | Often impossible to repurpose 
Has few numeric columns                         | May be almost entirely numerical
Is intended for use in a database               | Is intended for use in a spreadsheet

We often have to consider the trade-offs. Granular data with the detail we need - especially when it involves personally identifiable information like names and addresses - can take months or years of negotiation over public records requests, even when the law allows it. It's often much easier to convince an agency to provide summarized or incomplete data. Don't balk at using it if it works for you. But understand that in the vast majority of cases, it's been summarized in a way that's lost information that could be important to your story. 

## Nouns 

That brings us to one of the most important things you must find out about any data you begin to analyze: What "noun" does each row in a tabular dataset represent? In statistics, they might be called *observations* or *cases*.  In data science, they're usually called *records*. Either way, every row must represent the same thing -- a person, a place, a year, a water sample or a school. And you can't really do anything with it until you figure out what that is. 

In 2015, we did a story at The New York Times called ["More Deportation Follow Minor Crimes, Records Show"](https://www.nytimes.com/2014/04/07/us/more-deportations-follow-minor-crimes-data-shows.html) . The government had claimed it was only removing hardened criminals from the country, but our analysis of the data suggested that many of them were for minor infractions. 

In writing the piece, we had to work around a problem in our data: the agency refused to provide us anything that would help us distinguish individuals from one another. All we knew was that each row represented one deportation -- not one person! Without a column, or *field* or a *variable* or an *attribute* for an individual -- say, name and date of birth, or some scrambled version of an their DHS number --  we had no way to even estimate how often people were deported multiple times. If you read the story, you'll see the very careful wording, except when we had reported out and spoken to people on the ground. 

## Further reading

* ["Basic steps in working with data"](https://datajournalism.com/read/handbook/one/understanding-data/basic-steps-in-working-with-data), the Data Journalism Handbook, Steve Doig, ASU Professor. He describes in this piece the problem of not knowing exactly how the data was compiled. 

* "[Counting the Infected](https://www.nytimes.com/2020/07/08/podcasts/the-daily/coronavirus-data-united-states.html)" , Rob Gebellof on The Daily, July 8, 2020. 

* "[Spreadsheet thinking vs. Database thinking](https://eagereyes.org/basics/spreadsheet-thinking-vs-database-thinking)", by Robert Kosara, gets at the idea that looking at individual items is often a "database", and statistical compilations are often "spreadsheets". 

* "[Tidy Data](https://vita.had.co.nz/papers/tidy-data.pdf)",  in the Journal of Statistical Software (linked here in a pre-print) by Hadley Wickham , is the quintessential article on describing what we think of as "clean" data. For our purposes, much of what he describes as "tidy" comes when we have individual, granular records -- not statistical compilations. It's an academic article, but it has the underlying concepts that we'll be working with all year. 



## Exercises

* Get a copy of a parking ticket from your local government, and try to imagine what a database of those would look like. What would every row represent? What would every column represent? What's missing that you would expect to find, and what is included that surprises you? 

* The next time you get a government statistical report, scour all of the footnotes to find some explanation of where the data came from. You'll be surprised how often they are compilations of administrative records - the government version of trace data. 






