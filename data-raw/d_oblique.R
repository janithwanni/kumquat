library(tidyverse)
set.seed(1253)
n <- 5000

d_oblique <- tibble(x = runif(n, -1, 1), y = runif(n, -1, 1)) |>
  mutate(class = factor(if_else(y > 0.1 + 1.4 * x, "A", "B")))

usethis::use_data(d_oblique, overwrite = TRUE)
