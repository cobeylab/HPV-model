########################################################################
## Example of global search in likelihood space 
########################################################################
library(dplyr)
library(reshape2)
library(plyr)
library(pomp)
library(parallel)
library(devtools)
install_github("cbreto/panelPomp")
library(panelPomp)
library(RSQLite)
source("../utility_functions.R")

## Specify the HPV type for the analysis
this_type = "HPV16"
chainId = 1

# IF running on a high-performance computing cluster --------------------------------------------------------
#args = commandArgs(trailingOnly=TRUE)
#chainId = as.numeric(args[1])
#------------------------------------------------------------------------------------------------------------

## Specify fixed parameters
FP_RATE = .99
FN_RATE = .96
TIMESTEP = 1 # 2 week timestep for the simulations 

# Specify MIF parameters for this chain
n_mif = 1
n_mif_updated <- n_mif
n_particles = 10
cooling_rate = .75
n_reps_pfilter = 3
n_particles_pfilter = 5
evaluate_Lhood = TRUE

data_filename <- "../../Data/Data.sqlite"
results_db <- paste0("./results/model_results_", this_type, ".sqlite")
table_name <- paste0("global_params_", this_type)
output_filename <- paste0("./results/global_likelihood_search_", this_type, ".csv")
chain_filename <- paste0("./results/chain_global_likelihood_search_",chainId,"_",this_type,".rda") 
pomp_filename <- paste0("./pomp_objects/pomp_object_",this_type,"_test.rda")

setwd("../")
source("perform_global_search.R")
