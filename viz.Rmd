# (PART) Visualization as a reporting tool {-}


# Introduction {#viz-intro .unnumbered}

## In this section

The following chapters review ways of looking at your data while reporting. We're leaving publication quality graphic alone -- those often depend on using sites like <datawrapper.de> or D3 javascript to get high-performance visualizations, while static graphics often depend on using Adobe products to make typography and palettes acceptable to your publication. 

Much of this is done in R using the package `ggplot2`, which is part of the tidyverse. If you want to follow along with with interactive aspects, you'll want to install the `plotly` package. There may be others noted in individual sections.  

Working with geography is in the next section. 


* [Visualization as reporting tool](viz-reporting.html) - principles for using visualizations to report on stories

* [Visualization demo](viz-demo.html)


## Other resources

This sections just gets to the very basics of making plots in R. Consider the following resources if you want to get into it in more detail: 

* "[Visualization with R](https://socviz.co/)", by Kiernan Healy. an excellent introduction to both the concepts of visualization and how to do it in R using ggplot (mainly). 
* "[Data Visualization for Storytelling and Discovery"](https://www.journalismcourses.org/course/datavizforstorytelling/)", a free online course that was given by the Knight Center in 2018. The videos and assignments are still available, from Alberto Cairo. Parts of his book, The Truthful Art, are included for free in the materials for that course.
* "[Using data visualization to find insights in data](https://datajournalism.com/read/handbook/one/understanding-data/using-data-visualization-to-find-insights-in-data)", by Gregor Aisch, former New York Times assistant graphics editor. His examples were created before the Tidyverse became popular, so his R code may not translate well for you.
* [R graph gallery](https://www.r-graph-gallery.com/) has extensive examples and code help - I usually go there to find inspiration for what I want to do with examples on how to do it. There are a lot of extra packages you can add to R that create very specialized graphs. 


### Applications for visualization {-}

You can use a lot of different types of online and free applications to play around with graphics instead of R. They're less reproducible, and they often come and go as free options, but they're sometimes easier: 

* [Datawrapper.de](https://www.datawrapper.de) , which is used in a lot of newsrooms. If you want to publish a visualization, it can link directly from R. It's also easy to use on its own. If you want to eventually publish your visualizations, this is probably the one that is most compatible with newsrooms.
* [Flourish](https://flourish.studio) (recently purchased by Canva, so who knows? But you can now create private visualizations without paying. )
* [RAWGraphs](https://rawgraphs.io), made for designers to sketch their work before digging deep into Adobe Illustrator. It's a little hard to use unless your data is in just the right form. 
* [Tableau Public](https://public.tableau.com/en-us/s/), made mainly for business intelligence, but a free version is available. I haven't used it for a while for a few reasons: Newsrooms don't use it much because it doesn't scale well to mobile; it's hard to save drafts in the free version; it's a little hard to get used to the interface for a quick visualization. 
 * The underlying [D3](https://observablehq.com/@d3/learn-d3) language of graphics, which is written in Javascript, is what powers a lot of these products. It's what the professional visual storyteller use. (Aside: javascript is probably the second language you'd want to learn. It helps with scraping and is used extensively newsrooms because it's the language of the web and mobile, so there are people to help you. But it's not easy.)





