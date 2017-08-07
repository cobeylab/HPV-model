
rprocess_additional_risk <- Csnippet("
                            double time_between_visits = tbv; // time between visits 
                            double covs[11] = {cov1, cov2, cov3, cov4, cov5, cov6, cov7, cov8, cov9, cov10, cov11};
                            double t_tot = 0;
                            
                            //Transform parameters
                            double lambda0 = exp(log_lambda0);
                            double var_gam = exp(log_var_gam);
                            double mean_gam = exp(log_mean_gam);
                            double rate_waning;
                            double d ;
                            
                            // Select the relevant risk parameter d based on sexual subclass c_i
                            if(c_i== 0){
                              d = exp(log_d0);
                            }
                            if(c_i == 1){
                              d = exp(log_d1);
                            }
                            if(c_i == 2){
                              d = exp(log_d2);
                            }
                
                            rate_waning = exp(log_w);

                            // Declare local parameters
                            double p_infection; // probability of infection
                            double duration; // duration of infection
                            double duration_remaining_new; //update the remianing duration of infection
                            int infected = x; 
                            double t_clear; //time at which infection will clear
                            double t_new; 
                            double status;
                            double lambda;
                            
                            while(t_tot < (time_between_visits)){
                             
                             // For two covariates (smoking status and condom use), update the variable half way between visits with the value at the next visit
                             if(t_tot > tbv/2){
                                covs[6] = cov_7_2; 
                                covs[7] = cov_8_2;
                              }

                              if(duration_remaining > 0){
                                if((duration_remaining) < (time_between_visits)){
                                  infected = 0;
                                  duration_remaining_new = 0;
                                  t_new = duration_remaining + t_tot;
                                  previously_cleared = 1;
                                  t_activate = t_new + t_cum;
                                }
                            
                                if((duration_remaining) >= (time_between_visits)){
                                  infected = 1;
                                  duration_remaining_new = duration_remaining - time_between_visits;
                                  t_new = time_between_visits;
                                  previously_cleared = 0;
                                }
                                
                                duration_remaining = duration_remaining_new;
                                t_tot = t_new;
                              }
                            
                            if(duration_remaining == 0){
                            
                              if(infected == 0){
                                lambda = lambda0*exp(log_alpha_cov_1*covs[0] + log_alpha_cov_2*covs[1]  + log_alpha_cov_3*covs[2] + log_alpha_cov_4*covs[3] + log_alpha_cov_5*covs[4] + log_alpha_cov_6*covs[5] + log_alpha_cov_7*covs[6] + log_alpha_cov_8*covs[7] + log_alpha_cov_9*covs[8] + log_alpha_cov_10*covs[9] + log_alpha_cov_11*covs[10]);
                                t_new = t_tot + time_step;
                              
                                if(previously_cleared == 1){
                                  lambda = lambda + d*exp(-rate_waning*(t-t_activate));
                                }

                                p_infection =  (1-exp(-lambda*time_step));

                                status = (int) rbinom(1,p_infection);
                              
                                if(status == 0){
                                  infected = 0;
                                  duration_remaining_new = 0;
                                }
                              
                                if(status == 1){
                                  infected = 1;
                                  duration = rgamma((mean_gam * mean_gam)/var_gam, var_gam/mean_gam);
                                  t_clear = t_new + duration;
                                  t_activate = t_clear + t_cum;
                              
                                  if(t_clear < time_between_visits){
                                    infected = 0;
                                    previously_cleared = 1;
                                    t_new = t_clear;
                                    duration_remaining_new = 0;
                                  }
                              
                                  if(t_clear > time_between_visits){
                                    infected = 1;
                                    previously_cleared = 0;
                                    duration_remaining_new = duration -  (time_between_visits - t_new);
                                  t_new = time_between_visits;
                                  }
                                }
                                duration_remaining = duration_remaining_new;
                                t_tot = t_new;
                            
                              }
                            }
                            
                          }
                          x = infected;
                          t_cum = t_cum + tbv;
                          
                        ")

init_additional_risk <- Csnippet("
                   double p_initial = exp(logit_p_initial)/(1 + exp(logit_p_initial));
                   double p_prev = exp(logit_p_prev)/(1 + exp(logit_p_prev));
                   double fraction_prev = exp((logit_f_prev)/(1 + exp(logit_f_prev)));
                   double full_duration;
                   double var_gam = exp(log_var_gam);
                   double mean_gam = exp(log_mean_gam);
                   double lambda;
                   double infection_time;
                   
                   x = rbinom(1,p_initial);
                   t_activate = 0;
                   t_cum = 0;
                   
                   if(x == 1){
                      full_duration = rgamma((mean_gam * mean_gam)/var_gam, var_gam/mean_gam);
                      previously_cleared = 0;
                      duration_remaining = (exp(logit_fraction_remaining_initial)/(1 + exp(logit_fraction_remaining_initial)))*full_duration;
                   }
                   
                   if(x == 0){
                     duration_remaining = 0;
                     previously_cleared = rbinom(1,p_prev);
                    
                     if(previously_cleared ==1){
                       lambda = exp(log_lambda0)*exp(log_alpha_cov_1*cov1 + log_alpha_cov_2*cov2  + log_alpha_cov_3*cov3 + log_alpha_cov_4*cov4 + log_alpha_cov_5*cov5 + log_alpha_cov_6*cov6 + log_alpha_cov_7*cov7 + log_alpha_cov_8*cov8 + log_alpha_cov_9*cov9 + log_alpha_cov_10*cov10 + log_alpha_cov_11*cov11);
                       infection_time = rexp(1/lambda);
                       t_activate = -fraction_prev*infection_time;
                      }
                   }
                 ")


## --- Measurement model -------------------------------------------------------------
dmeasure <- Csnippet("
                     double eta_FP;
                     double eta_FN;
                     eta_FP = exp(logit_FP)/(1 + exp(logit_FP));
                     eta_FN = exp(logit_FN)/(1 + exp(logit_FN));
                     
                     if(x == 0){
                      lik = dbinom(y, 1,(1 - eta_FP)*(1-x), 1);
                     }
                     if(x == 1){
                      lik = dbinom(y,1, eta_FN*x,1);
                     }
                     lik = give_log ? lik : exp(lik);
                     ")


rmeasure <- Csnippet("
                     double eta_FP;
                     double eta_FN;
                     eta_FP = exp(logit_FP)/(1 + exp(logit_FP));
                     eta_FN = exp(logit_FN)/(1 + exp(logit_FN));
                     
                     if(x == 0){
                      y = rbinom(1,  (1- eta_FP)*(1-x));
                     }
                     if(x == 1){
                      y = rbinom(1,  eta_FN*x);
                     }
                     ")
