paste0("profile_results_", this_type, ".rda")
df_d <- df_all %>% filter(param_name %in% c("log_d0","log_d1","log_d2")) 
mcap_d <- mcap_predictions%>% filter(param_name %in% c("log_d0","log_d1","log_d2")) 
df_d$label <- factor(df_d$param_name, labels = c("d[celibate]","d[1~partner]", "d[multiple~partners]"))
mcap_d$label <- factor(mcap_d$param_name, labels = c("d[celibate]","d[1~partner]", "d[multiple~partners]"))

df_covs <- df_all %>% filter(param_name %in% paste0("log_alpha_cov_",c(1:11))) 
mcap_covs <- mcap_predictions %>% filter(param_name %in% paste0("log_alpha_cov_",c(1:11))) 
df_covs$cov_name <- revalue(df_covs$cov_name, c("age_sexual_debut" = "age~at~sexual~debut", 
                                                "condom_use" = "consistent~condom~use", 
                                                "current_smoker" = "current~smoker", 
                                                "diff_female" = "recent~female~sexual~partners", 
                                                "diff_male" = "recent~male~sexual~partners", 
                                                "steady_partner" = "steady~sexual~partner"))
mcap_covs$cov_name <- revalue(mcap_covs$cov_name, c("age_sexual_debut" = "age~at~sexual~debut", 
                                                    "condom_use" = "consistent~condom~use", 
                                                    "current_smoker" = "current~smoker", 
                                                    "diff_female" = "recent~female~sexual~partners", 
                                                    "diff_male" = "recent~male~sexual~partners", 
                                                    "steady_partner" = "steady~sexual~partner"))

mcap_covs$label <- paste0("alpha","[",as.character(mcap_covs$cov_name),"]")
df_covs$label <- paste0("alpha","[",as.character(df_covs$cov_name),"]")


df_other <- df_all  %>% filter(param_name %in% paste0("logit_p_initial", "log_lambda0","log_w"))
df_other$label <- factor(df_other$param_name, labels = c("logit~p[initial]","lambda[0]", "w" ))
mcap_other <- mcap_predictions  %>% filter(type == this_type)
mcap_other$label <- factor(mcap_other$param_name, labels = c("lambda[0]", "w", "logit~p[initial]"))

df_prof <- rbind(df_d,df_other,df_covs) 
mcap_predictions <- rbind(mcap_d,mcap_other,mcap_covs)

p_profs <- ggplot(df_prof, aes(x = (focal_param), y = delta_LL,group = type)) + geom_point(size = .5) +geom_line(data = mcap_predictions,  aes(x = (parameter), y = (smoothed)) ,linetype=1)
p_profs <- p_profs + plot_themes + facet_wrap(~ label,labeller=label_parsed, scales="free_x") + ylim(-60,0) + geom_hline(yintercept = -2,linetype = 2, color = "red") + xlab("") + ylab("") 
p_profs <- p_profs + ylab(bquote(Delta~log~likelihood))

if(save_plots){
  save_plot(paste0("./figures/profiles_",this_type,".pdf"), p_profs, base_width = 12, base_height = 8)
}
