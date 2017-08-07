########################################################################
## Example of likelihood profile search
########################################################################
library(dplyr)
library(plyr)
library(pomp)
library(parallel)
library(reshape2)
library(devtools)
install_github("cbreto/panelPomp")
library(panelPomp)
library(RSQLite)
source("../utility_functions.R")

## Specify the HPV type for the analysis
this_type = "HPV16"
profile_param_name <- "log_d0"
chainId = 1


# IF running on a high-performance computing cluster --------------------------------------------------------
#args = commandArgs(trailingOnly=TRUE)
#chainId = as.numeric(args[1])
#------------------------------------------------------------------------------------------------------------

LOGLIK_THRESH = 10 
CONTINUATION = F
## Specify fixed parameters
FP_RATE = .99
FN_RATE = .96
TIMESTEP = 1 # 2 week timestep for the simulations 


n_profile_points <- 20
n_profile_reps <- 5
ind_df <- expand.grid(chain = c(1:(n_profile_points*n_profile_reps)),
                       type = this_type)

# specify MIF parameters
cooling_rate = .75
n_mif = 1
n_particles = 10
n_particles_pfilter = 5
n_reps_pfilter = 3
evaluate_Lhood = TRUE

k = ind_df[chainId,]$chain 


data_filename <- "../../Data/Data.sqlite"
results_db <- paste0("./results/model_results_", this_type, ".sqlite")
table_name <- paste0("global_params_", this_type)
results_table_name <- paste0("profile_results_", profile_param_name) 
chain_filename <- paste0("./results/chain_",k,"_",this_type,"_profile_",profile_param_name,".rda") 
pomp_filename <- paste0("./pomp_objects/pomp_object_",this_type,"_test.rda")
output_filename <- paste0("./results/profile_params_",profile_param_name,"_",this_type,".csv")

setwd("../")
source("perform_profile_likelihood.R")
