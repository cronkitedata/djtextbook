# Glossary  {#appendix-glossary}

This is a work in progress - I'll add terms as they're  needed

## Glossary


attribute in HTML

~ Part of a tag that further defines it. The common ones are 

   - class: A CSS definition that provides formatting information whenever it's mentioned inside a tag. A tag can have many classes defined. So if your web designer wants a specific font for a type of paragraph, along with a specific color for other pieces of content, they may use classes. They look like this in a tag: `<p class="myfont mycolor">, and they are referenced using a period in CSS selectors : `.myfont`. 
   - id: A CSS definition that locates a specific item on a page. They should be unique within a page -- no two elements should have the same ID. It's referenced with a hashtag in CSS selectors `#myid`
   - href: The URL of a link, used inside an "a" tag. 


CSS

~ Cascading Style Sheets. A sub-language that styles elements according to pre-defined definition. These can be supplied to the HTML page as a separate file or inline in the heading of the HTML.   

CSS selector

~  A method used to find elements in an HTML page using their CSS definitions. 


csv; tsv

~ two file extensions, suggesting that the contents are *comma-separated* or *tab-separated* plain text files. This is the most common open source method of sharing tabular data. 



HTML

~ Hypertext markup language, the code underneath most web pages, which gets rendered into your browser as a formatted page including text, images, videos, and audio. It's a specific form of the generalized XML data format, which we're not covering. But you may see references to XML when you work with scraping. (This is how we get to "markdown" documents -- they get translated into "markup" when they go through an engine like the knitting function in R. )  


Javascript

~ The language used for interactivity on web pages. It's hard to learn but the most useful thing you could learn if you chose to delve into another language. Like R, javascript has many libraries and frameworks that extend its usefulness. Two common libraries are  JQuery for interactive tables, and D3 for interactive visualizations. 

json

~  Javascript Object Notation, the format used to transfer datasets across the web and into your phone or your browser. It is the international language of web development for data. It is text-based and not tabular -- each item in a table or set of tables is presented as a list of columns, which can have sub-lists. JSON can be quite simple or quite complex, but it's a reliable way to transfer complicated information and whole documents between computers and operating systems. 




tag; element; node

~  An HTML tag is the word used to define an element on an HTML page. Some people use the terms "element" and "node" interchangeably.  

The tag, or element name, defines different types of items on the page once it's rendered in your browser. A tag begins with `<`, and ends with `>`, and each tag should have an opening and closing item, with the closing item preceded with `/`. Example: `<p>This is a paragraph</p>`. Common elements are: 

  - h1, h2, ... : headline levels. There is usually only one `h1` tag on a page, which is its headline. `h5` is lowest level heading that is allowed. 
  - p, div: Two ways to create blocks of text ("paragraph" or "division")
  - a : A link , which contains the URL as an href attribute and some text to show
  - img: An image, which is loaded from another file. (HTML itself is only text. Images, sound and video are actually loaded through links to other files.) 
  - table, tr, td : A table has rows (tr) and rows have cells (td)
  - ul, ol: Unordered (bulleted) and ordered (numbered) lists. Lists contain items using the `li` tag. 


variable 

~ 1. In R, every *object* is a variable in the environment - you can see them in that part of the RStudio interface. A variable can be simple, such as a word, or it can be more complex, such as a data frame. The words "variable" and "object" are often used interchangeably, but it's more common to refer to objects when they are complex, such as the result of parsing an HTML page. 

2. In statistics, a variable is something that "varies" from case to case. It's the same thing as a column in a well-formed spreadsheet or an R data frame. 

This can get confusing in R. The custom is this book is to reserve the word "variable" for an object, and use the word "column" for a variable in a data frame.


XPath
~  A language used to navigate pages by their position and characteristics.  It's more powerful than CSS selectors, but also more difficult to learn. It works in both XML and HTML pages. 


