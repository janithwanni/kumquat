library(tidyverse)
set.seed(1253)
n <- 5000

d_vertical <- tibble(x = runif(n, -1, 1), y = runif(n, -1, 1)) |>
  mutate(class = factor(if_else(x > 0.3, "A", "B")))

usethis::use_data(d_vertical, overwrite = TRUE)
