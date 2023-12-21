no_1_songs <-
  top100 |>
  group_by ( performer,title) |>
  summarize  ( best_position = min(this_week),
               weeks = n(),
               first_chart_date = min(chart_date) ,
               .groups="drop") |>
  filter ( weeks >= 52, best_position == 1, first_chart_date >= "2000-01-01") |>
  mutate ( hit =  forcats::fct_reorder
           (
             paste
             (
               str_trunc(performer, 25, "right"),
               str_trunc(title, 25, "right"),
               sep=": "
             ),
             desc( first_chart_date))
  )

top_songs <-
  no_1_songs |>
  inner_join ( top100 , by=c("title", "performer")) |>
  select ( hit, this_week, chart_date)


saveRDS(top_songs , "scratch/top_songs.RDS")
