########################################################################
## Example of global search in likelihood space 
########################################################################
library(dplyr)
library(pomp)
library(parallel)
library(devtools)
install_github("cbreto/panelPomp")
library(panelPomp)
library(RSQLite)
source("utility_functions.R")

# IF running on a high-performance computing cluster --------------------------------------------------------
args = commandArgs(trailingOnly=TRUE)
chainId = as.numeric(args[1])
#------------------------------------------------------------------------------------------------------------

## Specify the HPV type for the analysis
this_type = "HPV16"

## Specify fixed parameters
FP_RATE = .99
FN_RATE = .96
TIMESTEP = 2/52 # 2 week timestep for the simulations 

# Specify MIF parameters for this chain
n_mif = 200
n_mif_updated <- n_mif
n_particles = 20e3
cooling_rate = .75
n_reps_pfilter = 10
n_particles_pfilter = 50e3
evaluate_Lhood = TRUE

data_filename <- "Data.sqlite"
results_db <- "./Results/results_additional_risk_model.sqlite"
table_name <- paste0("global_params_", this_type)
output_filename <- paste0("global_likelihood_search_", this_type, ".csv")
chain_filename <- paste0("chain_global_likelihood_search_",chainId,"_",this_type,".rda") 
pomp_filename <- paste0("./pomp_objects/pomp_object_",this_type,".rda")

source("perform_global_search.R")
