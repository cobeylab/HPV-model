################################################
## Generate figures from the raw data
################################################
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
source("../../utility_functions.R")
HPV_types <- paste0("HPV",c(62,84,89,16,51,6))

# Select HPV type (example HPV16)
this_type = "HPV16"
load(paste0("MLE_with_CI_", this_type,".rda"))
dbFilename <- "../../../../Data/Data.sqlite"
db <- dbConnect(SQLite(), dbFilename)
covartable <- dbReadTable(db, "covariate_data") %>% filter(visit == "v1") 
dbDisconnect(db)
cov_table <- covartable %>% select(-c(subjectId, visit,current_smoker_2, steady_partner_2))
names(cov_table) <- c(paste0("cov",c(1:(ncol(cov_table)-1))),"sexual_subclass")
cov_table[,1:3]    <- apply(cov_table[,1:3],2,scale, center =T) 

df_all <- data.frame()
time_points <- c(0,1,3) 
for( i in c(1:length(HPV_types))){
  for( k in c(1:length(time_points))){
    this_type = HPV_types[i]
    test_params <- mle_df %>% filter(type == this_type)
    test_params_covs <- test_params[grep("cov",test_params$param_name),]
    test_params_covs$order <- as.numeric(sapply(strsplit(test_params$param_name,"_"),"[[",4))
    cov_alphas <- as.numeric(unlist(test_params_covs %>% arrange(order) %>% select(MLE)))
    cov_values <- cov_table[,grep("cov", names(cov_table))]
    log_lambda0 <- as.numeric(unlist(test_params %>% filter(param_name == "log_lambda0") %>% select(MLE)))
    log_w <- as.numeric(unlist(test_params %>% filter(param_name == "log_w") %>% select(MLE)))
    log_d0 <- as.numeric(unlist(test_params %>% filter(param_name == "log_d0") %>% select(MLE)))
    log_d1 <- as.numeric(unlist(test_params %>% filter(param_name == "log_d1") %>% select(MLE)))
    log_d2 <- as.numeric(unlist(test_params %>% filter(param_name == "log_d2") %>% select(MLE)))
    time_from_infection <- time_points[k]
    lambda2 <- array(NA, nrow(cov_table))
    frac_d <- array(NA, nrow(cov_table))
    print(time_from_infection)
    for( j in 1:nrow(cov_table)){
      if(cov_table$sexual_subclass[i] == 0){
        log_d = log_d0
      }
      if(cov_table$sexual_subclass[i] == 1){
        log_d = log_d1
      }
      if(cov_table$sexual_subclass[i] == 2){
        log_d = log_d2
      }
      lambda2[j] = exp(log_lambda0*exp(sum((cov_values[j,])*(cov_alphas))))
      frac_d[j] <- exp(log_d)*exp(-exp(log_w)*(time_from_infection))/(lambda2[j] + exp(log_d)*exp(-exp(log_w)*(time_from_infection)))
    }
    
    df <- data.frame(type = this_type, 
                     FOI = unlist(lambda2), 
                     frac_d0 =unlist(frac_d))
    df$time <- time_points[k]
    df_all <- rbind(df_all,df)
  }
}
save(df_all, file = "distribution_FOI_d.rda")

