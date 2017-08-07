#######################################################################################################
## Maximize the likelihood at one profile point  ------------------------------------------------------ 
## Note: must update the profile parameter and range for each parameter
#########################################################################################################
library(dplyr)
library(pomp)
library(parallel)
library(devtools)
install_github("cbreto/panelPomp")
library(panelPomp)
library(RSQLite)
source("utility_functions.R")

if(!CONTINUATION){
  select <- dplyr::select
  
  # # Get profile starting params
  db <- dbConnect(SQLite(), results_db)
  loglik_query <- dbSendQuery(db, paste0("SELECT MAX(loglik) FROM ",table_name))
  max_loglik <- as.numeric(dbFetch(loglik_query, n = -1))
  dbClearResult(loglik_query)
  param_set_query <- dbSendQuery(db, paste0("SELECT * FROM ",table_name," WHERE loglik > ", (max_loglik-LOGLIK_THRESH))) #loglik> (max(loglik)-50)")
  profile_param_set <- dbFetch(param_set_query, n = -1) %>% select(-c(n_mif, chain, loglik,loglik_se))
  dbClearResult(param_set_query)
  dbDisconnect(db)
  
  # Update this to profile over the parameter of interest. Update the range of the profile sweep for the parameter of interest. 
  profile_param_set %>% select(-c(log_d0,
                                  logit_FP, 
                                  logit_FN,
                                  n_part
  )) %>% 
    melt(id=NULL) %>% 
    daply(~variable,function(x)range(x$value)) -> starting_params
    starts <- profileDesign(log_d0 = seq(from = -1, to = 6, length.out = n_profile_points),
                          lower=starting_params[,1],upper=starting_params[,2],
                          nprof=n_profile_reps)
  
   starts$logit_FP <- logit(FP_RATE)
   starts$logit_FN <- logit(FN_RATE)
  #Specify random walk : Set the random walk of the profile parameter to zero. 
  rw_sd_vec <- rw.sd(
    log_lambda0= 0.0075,
    log_var_gam= 0,
    log_mean_gam = 0,
    log_alpha_cov_1 = 0.0075,
    log_alpha_cov_2 = 0.0075,
    log_alpha_cov_3 = 0.0075,
    log_alpha_cov_4 = 0.0075,
    log_alpha_cov_5 = 0.0075,
    log_alpha_cov_6 = 0.0075,
    log_alpha_cov_7 = 0.0075,
    log_alpha_cov_8 = 0.0075,
    log_alpha_cov_9 = 0.0075,
    log_alpha_cov_10 = 0.0075,
    log_alpha_cov_11 = 0.0075,
    log_d0 = 0, 
    log_d1 = 0.0075,
    log_d2 = 0.0075,
    log_w =0.0075,
    logit_p_initial = ivp(.02),
    logit_fraction_remaining_initial = ivp(.02),
    logit_p_prev = ivp(.02),
    logit_f_prev = ivp(.02),
    logit_FP = 0,
    logit_FN = 0,
    time_step = 0
  )
  starts$chainId <- c(1:nrow(starts))
  n_mif_updated <- n_mif
}

if(CONTINUATION){
  db <- dbConnect(SQLite(), results_db)
  params <- dbReadTable(db,table_name) %>% filter(chain == chainId) %>% arrange(-c(n_mif))
  n_mif_completed <- params[1,]$n_mif
  params <- params[1,]  %>% select(-c(loglik, loglik_se, n_mif, n_part,type))
  dbDisconnect(db)
  starts <- params
  rm(params)
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
    log_d0 = 0,
    log_d1 = 0.005,
    log_d2 = 0.005,
    log_w =0,
    logit_p_initial = ivp(.02),
    logit_fraction_remaining_initial = ivp(.02),
    logit_p_prev = ivp(.02),
    logit_f_prev = ivp(.02),
    logit_FP = 0,
    logit_FN = 0,
    time_step = 0
  )
  n_mif_updated <- n_mif_updated + n_mif
}

## Initialize an empty dataframe of params to be filled in with the initial profile params. The values in this dataframe are arbitrary 
## because they will be filled in by the values in "starts"
guess <- c(log_lambda0= log(runif(1,0.0001,1)),
           log_mean_gam = log(1),
           log_var_gam = log(1),
           log_alpha_cov_1 = log(runif(1,0.0001,5)),
           log_alpha_cov_2 = log(runif(1,0.0001,5)),
           log_alpha_cov_3 = log(runif(1,0.0001,5)),
           log_alpha_cov_4 = log(runif(1,0.0001,5)),
           log_alpha_cov_5 = log(runif(1,0.0001,5)),
           log_alpha_cov_6 = log(runif(1,0.0001,5)),
           log_alpha_cov_7 = log(runif(1,0.0001,5)),
           log_alpha_cov_8 = log(runif(1,0.0001,5)),
           log_alpha_cov_9 = log(runif(1,0.0001,5)),
           log_alpha_cov_10 = log(runif(1,0.0001,5)),
           log_alpha_cov_11 = log(runif(1,0.0001,5)),
           log_d0 = log(runif(1,0.0001,5)),
           log_d1 = log(runif(1,0.0001,5)),
           log_d2= log(runif(1,0.0001,5)),
           log_w = log(runif(1,0.0001,5)),
           logit_FP = logit(FP_RATE),
           logit_FN = logit(FN_RATE),
           logit_p_initial = logit(runif(1,0.001,.999)),
           logit_fraction_remaining_initial = logit(runif(1,0.001,.999)),
           logit_p_prev = logit(runif(1,0.001,.999)),
           logit_f_prev = logit(runif(1,0.001,.999)),
           time_step = TIMESTEP
           )

source("profile_likelihood_methods.R")
load(pomp_filename)
fit <- evaluate_profile_point(this_chain = chainId, 
                             guess = guess, 
                             starts = starts, 
                             n_part = n_particles, 
                             n_mif = n_mif,
                             n_mif_updated = n_mif_updated,
                             rw_sd_vec = rw_sd_vec,
                             n_particles_pfilter = n_particles_pfilter,
                             n_reps_pfilter = n_reps_pfilter,
                             mif_chain_filename = chain_filename,
                             table_name = results_table_name, 
                             results_db = results_db, 
                             output_filename = output_filename,
                             evaluate_Lhood = TRUE
)