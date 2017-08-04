
LOGLIK_THRESH = 10 
TIMESTEP = 1/52
CONTINUATION = T
n_profile_points <- 20
n_profile_reps <- 5
ind_df <- expand.grid( chain = c(1:(n_profile_points*n_profile_reps)),
                       type = c(5))
this_strain = HPV_types[ind_df[j,]$type]
k = ind_df[j,]$chain 

output_filename <- paste0("profile_params_d0_",this_strain,".csv")
evaluate_Lhood = TRUE
profile_param_name <- "log_d0"
results_table_name <- paste0("results_global_", this_strain) 
table_name <- paste0("results_global_", this_strain) 
dbResultsFilename <- paste0("./analysis_scripts/results_2.sqlite")
pomp_object_filename <- paste0("./pomp_objects/pomp_object_",this_strain,".rda")

# specify cooling rate
cooling_rate = .75
n_mif = 100
n_particles = 20e3
n_particles_pfilter = 30e3
evaluate_Lhood = TRUE
pomp_filename <- paste0("./pomp_objects/pomp_object_", this_strain, ".rda")
chain_filename <- paste0("chain_",k,"_",this_strain,"_prof_d0.rda") # mif chain name for output 

