library(tictoc)
library(nimble)
library(dplyr)
library(Rlab)

#set working directionary
setwd("/Users/siyingma/Desktop/COVID/COVID-codes/Simplified-model-without-lag")
#source(paste0(getwd(),"/write_sim_data.R"))
source(paste0(getwd(),"/make_history.R"))
source(paste0(getwd(),"/build_nimble_model.R"))

# R script for running a simulation study. Uses a parameter matrix
# created by generate_parameter_matrix.R. Takes the task id as a command
# line argument,which corresponds to a row of the parameter matrix.
# Outputs model_statistics_* text files with the summary statistics for the coda
# samples.

#tic()

#print("finished loading libraries")

#args <- commandArgs(trailingOnly = TRUE)

#task_id_str <- args[1]
#task_id <- strtoi(args[1])

# number of repetitions for each simulation
#reps <- args[2]

#print(paste0("task id: ", task_id_str))

# parameter matrix from generate_parameter_matrix.R
#params_matrix <- read.csv("./parameter_matrix.csv")

#print("finished loading parameter matrix")

#params <- params_matrix[task_id, ]

params <- c(
  N = 1000,
  M = 1500,
  k = 14,
  omega = 0.4,
  pa = 0.5,
  pb = 0.3
)

# generate data

# true population size
N <- as.integer(params["N"])

# augmented population size
M <- as.integer(params["M"])

# number of sampling occasions / strata
k <- as.integer(params["k"])

# true severe symptoms availability probability
omega <- as.double(params["omega"])

# true lag of severe symptoms probability
#theta <- as.double(params["theta"])

# true lab test capture probability
pa <- as.double(params["pa"])

# true hospital capture probability
pb <- as.double(params["pb"])

# for (rep in 1:reps) { # uncomment this if want repetitions
# setting seed
seed <- as.integer(1e7 * runif(1))
set.seed(seed)

print(paste0("seed: ", seed))

# simulate capture histories
sim_out <- make_history(N, M, k, omega, pa, pb)

print(paste("sum(z_init_1) =", sum(sim_out$z_init_1 == 1, na.rm = T)))
print(paste("n =", sim_out$n))

# save simulation data for debugging
#write_sim_data(task_id_str, sim_out$h_aug, sim_out$h_2, sim_out$obs_a_aug, sim_out$obs_b_aug)

#-------------------- Call nimble from R -----------------------#
start_time <- Sys.time()
mcmc_out <- build_nimble_model(sim_out, chains = 1, iter = 50000, burnin = 10000)
end_time <- Sys.time()

mcmc_out$summary
end_time - start_time

if (is.null(mcmc_out)) {
  print("Error: model failed to work")
  next
}

# Get summary statistics
rbind(mcmc_out$summary, n = sim_out$n, n_2 = sim_out$n_2)
write.table(rbind(mcmc_out$summary, n = sim_out$n, n_2 = sim_out$n_2), file = paste0(task_id_str, "_model_statistics.csv"), sep = ",", col.names = F)

# Get posterior samples
write.table(mcmc_out$samples, file = paste0(task_id_str, "model_post_samples.csv"), sep = ",", row.names = F)

print(paste0("Done task #", task_id))
toc()
