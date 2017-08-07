library(dplyr)
library(pomp)
library(parallel)
library(devtools)
install_github("cbreto/panelPomp")
library(panelPomp)
library(RSQLite)
source("utility_functions.R")
this_type <- "HPV16"
chainId = 1

# If running on a high-performance computing cluster ------------------------------------------------------
#args = commandArgs(trailingOnly=TRUE)
#chainId = as.numeric(args[1])
# ---------------------------------------------------------------------------------------------------------

## Find the starting parameters for this chain
results_db <- paste0("./results/model_results_", this_type, ".sqlite")
table_name <- paste0("global_params_",this_type)
db <- dbConnect(SQLite(), dbFilename)
params <- dbReadTable(db,table_name) %>% filter(chain == chainId) %>% arrange(-c(n_mif))
n_mif_completed <- params[1,]$n_mif
params <- params[1,]  %>% select(-c(loglik, loglik_se, n_mif, n_part,chain,type))
dbDisconnect(db)
guess <- unlist(params)

#Specify random walk :
rw_sd_vec <- rw.sd(
  log_lambda0= 0.005,
  log_var_gam= 0,
  log_mean_gam = 0,
  log_alpha_cov_1 = 0.005,
  log_alpha_cov_2 = 0.005,
  log_alpha_cov_3 = 0.005,
  log_alpha_cov_4 = 0.005,
  log_alpha_cov_5 = 0.005,
  log_alpha_cov_6 = 0.005,
  log_alpha_cov_7 = 0.005,
  log_alpha_cov_8 = 0.005,
  log_alpha_cov_9 = 0.005,
  log_alpha_cov_10 = 0.005,
  log_alpha_cov_11 = 0.005,
  logit_d = 0.005,
  log_w = 0.005,
  logit_p_initial = ivp(.02),
  logit_fraction_remaining_initial = ivp(.02),
  logit_p_prev = ivp(.02),
  logit_f_prev = ivp(.02),
  logit_FP = 0,
  logit_FN = 0,
  time_step = 0
)

# specify cooling rate
cooling_rate = .75
n_mif = 200
n_mif_updated = n_mif_completed + n_mif
n_particles = 20e3
n_particles_pfilter = 100e3
n_reps_pfilter = 5
evaluate_Lhood = TRUE
pomp_filename <- paste0("./pomp_objects/pomp_object_", this_type, "_test.rda")
chain_filename <- paste0("chain_",chainId,"_",this_type,".rda") 
output_filename <- paste0("global_likelihood_search_", this_type, ".csv")
source("global_search_methods.R")
