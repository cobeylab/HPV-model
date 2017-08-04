#######################################################################################################
## Global expoloration of the likelihood surface ------------------------------------------------------ 
#########################################################################################################

#Specify random walk :
rw_sd_vec <- rw.sd(
  log_lambda0= 0.01,
  log_var_gam= 0,
  log_mean_gam = 0,
  log_alpha_cov_1 = 0.01,
  log_alpha_cov_2 = 0.01,
  log_alpha_cov_3 = 0.01,
  log_alpha_cov_4 = 0.01,
  log_alpha_cov_5 = 0.01,
  log_alpha_cov_6 = 0.01,
  log_alpha_cov_7 = 0.01,
  log_alpha_cov_8 = 0.01,
  log_alpha_cov_9 = 0.01,
  log_alpha_cov_10 = 0.01,
  log_alpha_cov_11 = 0.01,
  log_d0 = 0.01,
  log_d1 = 0.01,
  log_d2 = 0.01,
  log_w =0.01,
  logit_p_initial = ivp(.05),
  logit_fraction_remaining_initial = ivp(.05),
  logit_p_prev = ivp(.05),
  logit_f_prev = ivp(.05),
  logit_FP = 0,
  logit_FN = 0,
  time_step = 0
)

db <- dbConnect(SQLite(), data_filename)
clearance_params <- as.data.frame(dbReadTable(db,"infection_duration_parameters"))
dbDisconnect(db)
mean_dur = clearance_params %>% filter(Type == this_type) %>% select(Mean_duration)
var_dur = clearance_params %>% filter(Type == this_type) %>% select(Variance_duration)

guess <- c(log_lambda0= log(runif(1,0.0001,1)),
           log_mean_gam = log(as.numeric(mean_dur)),
           log_var_gam = log(as.numeric(var_dur)),
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

source("global_search_methods.R")

