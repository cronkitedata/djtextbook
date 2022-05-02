library(bookdown)

clean_book(TRUE)

render_book("index.Rmd", output_format = "bookdown::bs4_book",
            output_dir = "docs",  config_file = "_bookdown.yml")


#had to add webshot before this would work. and webshot::install something js.
#also tinytex, then tinytex::install_tinytex() I don't understand why.
#


render_book("index.Rmd", output_format="bookdown::pdf_book")

# To stage all, go to a terminal window and say git add .
# add to output yaml:
#
#bookdown::pdf_book:
#  keep_tex: true

# to preview:
serve_book()
servr::daemon_stop(2)


#after building the book, just look at one chapter change.
preview_chapter("r-advanced-scrape1.Rmd")
