## Parameter script for analyses
library(dplyr)
library(pomp)
library(parallel)
library(devtools)
install_github("cbreto/panelPomp")
library(panelPomp)
library(RSQLite)
source("utility_functions.R")

type_index = 4
HPV_types <- c("HPV62", "HPV84", "HPV89", "HPV16", "HPV51", "HPV6")
n_covariates = 11
filter_clearance_events = TRUE
this_type = HPV_types[type_index]
data_filename <- paste0("../../Data/Data.sqlite")
infection_data_table_name <- paste0("infection_data_",this_type)

## Read in the data  ------------------------------------------------------------------------------------------------
db <- dbConnect(SQLite(), data_filename)
data <- as.data.frame(dbReadTable(db,infection_data_table_name))
covartable <- as.data.frame(dbReadTable(db, "covariate_data"))
times <- as.data.frame(dbReadTable(db,"visit_dates"))
clearance_params <- as.data.frame(dbReadTable(db,"infection_duration_parameters"))
dbDisconnect(db)


## Generate the pomp object ------------------------------------------------------------------------------------------------
source("rprocess.R")
source("./data_processing/make_one_panel_pomp_unit.R")
pomp_filename <- paste0("./pomp_objects/pomp_object_",this_type,"_test.rda")
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
           logit_d = logit(runif(1,0.0001,.999)),
           log_w = log(runif(1,0.0001,5)),
           logit_FP = logit(.99),
           logit_FN = logit(.96),
           logit_p_initial = logit(runif(1,0.001,.999)),
           logit_fraction_remaining_initial = logit(runif(1,0.001,.999)),
           logit_p_prev = logit(runif(1,0.001,.999)),
           logit_f_prev = logit(runif(1,0.001,.999)),
           time_step = .5
)
source("./data_processing/data_to_pomp_object.R")

