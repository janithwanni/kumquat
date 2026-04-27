library(tidyverse)
set.seed(1253)
n <- 5000

d_multitwo <- tibble(x = runif(n, -1, 1), y = runif(n, -1, 1)) |>
  mutate(
    class = factor(case_when(
      x < (-0.5) & y < (-0.3) ~ "A",
      x >= -0.5 & x < 0.4 & y < 0.1 + 0.8 * x ~ "A",
      x >= 0.4 ~ "A",
      .default = "B"
    ))
  ) |>
  mutate(class = factor(if_else(y < (-1) + 0.8 * x, "B", class)))

usethis::use_data(d_multitwo, overwrite = TRUE)
