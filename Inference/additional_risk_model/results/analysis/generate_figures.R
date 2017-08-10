################################################
## Figures from the best-fit model
################################################
#!/usr/bin/Rscript

library(gridExtra)
library(ggplot2)
library(pomp)
library(tidyr)
library(plyr)
library(dplyr)
library(RSQLite)
library(viridis)
library(reshape2)
library(stringr)
library(cowplot)
select <- dplyr::select
load("../cov_names_complete.rda")
source("../utility_functions.R")
source("plot_themes.R")
library(gplots)
HPV_types <- c("HPV62", "HPV84", "HPV89", "HPV16", "HPV51","HPV6")
save_plots <- TRUE

## Post-processing: generate smoothed likelihood profiles, calculate the distribution of the FOI among individuals, 
##  calculate the contribution of d to the FOI among individuals 
source("extract_profiles_and_MLEs.R")
source("calculate_FOI_distribution.R")

## Distribution of force of infection in naive population
source("plot_dist_FOI_naive_population.R")

## Covariate results 
source("plot_covariate_results.R")

## Additional risk results 
source("plot_additional_risk_results.R")

## Generate histogram showing the fraction of the total force of infection made up by the additional risk
source("plot_distribution_d_FOI.R")

## Plot the likelihood profiles for all parameters for one HPV type
# Example: HPV16
this_type <- "HPV16"
source("plot_profiles.R")



