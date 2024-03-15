library(tibble)
library(tidyr)
library(dplyr)
library(readr)

## Define simulation parameters
param_matrix <- crossing(
  N = 1000,
  M = 1500,
  k = 21,
  omega = c(0.3, 0.5, 0.7),
  theta = c(0.1, 0.15, 0.3, 0.5),
  pa = c(0.1, 0.3, 0.5),
  pb = c( 0.25, 0.55, 0.75)
) %>%
  rowid_to_column("sim_id")

write_csv(param_matrix, "./parameter_matrix.csv")


