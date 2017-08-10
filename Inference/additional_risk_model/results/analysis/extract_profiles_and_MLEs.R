##################################################################################
## Calculate the smoothed profiles with associated MLE and 95% confidence interval
##################################################################################
#!/usr/bin/Rscript

library(ggplot2)
library(cowplot)
library(RSQLite)
library(reshape)
library(tidyr)
library(viridis)
library(polycor)
library(corrplot)
library(dplyr)
select <- dplyr::select
summarize <- dplyr::summarise
rename <- dplyr::rename
source("plot_themes.R")
source("../../utility_functions.R")
source("mcap_algorithm.R")
load("parameter_names.rda")
HPV_types <- paste0("HPV",c(62,84,89,16,51,6))

# Select HPV type (example HPV16)
this_type = "HPV16"

# Do you want to save the figures?
save_plots = 1

#####################################################################################################################################
# Pull the profile results for the desired type and parameter, compute the smoothed profile, and calculate the MLE/CI
######################################################################################################################################
results_db <- paste0("../../results/model_results_", this_type, ".sqlite")

profile_param_names <- unique(par_names$param_name)

df_all <- data.frame()
mcap_predictions <- data.frame()

for(i in 1:length(profile_param_names)){
  profile_param_name <- profile_param_names[i]
  table_name <- paste0("profile_results_", profile_param_name)
  db <- dbConnect(SQLite(), dbFilename)
  df_full <- dbReadTable(db,table_name)
  dbDisconnect(db)
  
  df_profile$focal_param <- df_full[,names(df_full) == profile_param_name]
  pred <- predict(loess(loglik~focal_param,data = df_profile))
  mcap_full<- mcap(lp = sub$loglik, parameter = df_profile$focal_param)
  mcap_pred <- mcap_full$fit
  mcap_pred$type = this_type
  mcap_pred$param_name = profile_param_name
  mcap_pred$cov_name <- par_names[which(par_names$param_name == profile_param_name),]$cov
  mcap_pred$smoothed = mcap_pred$smoothed - max(mcap_pred$smoothed)
  mcap_pred$quadratic = mcap_pred$quadratic - max(mcap_pred$quadratic)
  mcap_pred$MLE = mcap_full$mle
  mcap_pred$LCI = mcap_full$ci[1]
  mcap_pred$UCI = mcap_full$ci[2]
  df <- data.frame(focal_param = df_full$focal_param,
                   param_name = profile_param_name,
                   par_name = par_names[which(par_names$param_name == profile_param_name),]$cov,
                   loglik = df_full$loglik,
                   smoothed_LL = pred,
                   delta_LL = df_full$loglik - max(df_full$loglik),
                   delta_LL_smoothed = pred-max(pred),
                   type = this_type)
  df_all <- rbind(df_all,df)
  mcap_predictions <- rbind(mcap_predictions, mcap_pred)
  
}                 
                   
save(df_all, mcap_pred, file = paste0("profile_results_", this_type, ".rda"))
mle_df <- mcap_predictions %>% select(type,param_name, cov_name, MLE, LCI, UCI) %>% distinct
save(mle_df, file = paste0("MLE_with_CI_", this_type,".rda"))

