#1.) Plot d across sexual subclasses for each type 
d_params <- mle_df_all_types %>% filter(param_name %in% paste0("log_d",c(0:2))) %>% select(type, cov_name,MLE, LCI, UCI) 
d_params$type <- toupper(d_params$type)
d_params$type_f <- factor(d_params$type, levels = toupper(c("hpv16","hpv62", "hpv51", "hpv89","hpv84","hpv6")))
d_params$d_param <- factor(d_params$cov_name, levels = c(as.character(unique(d_params)$cov_name[1]), as.character(unique(d_params)$cov_name[2]), as.character(unique(d_params)$cov_name[3])))
p <- ggplot(d_params, aes(x = (type_f), y = MLE)) + geom_point(aes(color=d_param), position = position_dodge(width = .5), size = 4) + geom_errorbar(aes(ymin = LCI, ymax = UCI, width = .5, color=d_param),position = position_dodge(width = .5)) 
p_d <- p  + ylab("Log MLE") + xlab("")  + scale_color_viridis(discrete = TRUE, option = "magma", end = .7)
p_d <- p_d + plot_themes +  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.title = element_blank())

save_plot("./figures/d_params.pdf",p_d, base_aspect_ratio = 1.3)

#2.)  Bivariate profile of log_d0 and log_lambda0
this_type <- "HPV16"
results_db <- paste0("../model_results_",this_type,".sqlite")
param_names <- c("log_d0", "log_lambda0")
table_name <- paste0("bivariate_profile_",param_names[1],"_",param_names[2])
biv_surface <- dbReadTable(db, table_name)
params <- biv_surface
params$focal_param_1 <- params[,names(params) == param_names[1]]
params$focal_param_2 <- params[,names(params) == param_names[2]]
params <- params %>% filter(loglik > (max(loglik) - 200)) 
max_sub <- aggregate(loglik ~ focal_param_1 + focal_param_2, data = params, FUN = max)

data.loess <- loess(loglik ~ focal_param_1 * focal_param_2, data = max_sub)
xgrid <-  seq(min(max_sub$focal_param_1), max(max_sub$focal_param_1), 0.1)
ygrid <-  seq(min(max_sub$focal_param_2), max(max_sub$focal_param_2), 0.1)
data.fit <-  expand.grid(focal_param_1 = xgrid, focal_param_2 = ygrid)
mtrx3d <-  predict(data.loess, newdata = data.fit)
mtrx.melt <- melt(mtrx3d)
names(mtrx.melt) <- c("focal_param_1", "focal_param_2", "loglik")
mtrx.melt$focal_param_1 <- as.numeric(str_sub(mtrx.melt$focal_param_1, str_locate(mtrx.melt$focal_param_1, "=")[1,1] + 1))
mtrx.melt$focal_param_2 <- as.numeric(str_sub(mtrx.melt$focal_param_2, str_locate(mtrx.melt$focal_param_2, "=")[1,1] + 1))

p_d0_lambda0 <- ggplot() + 
  geom_point(data= max_sub, aes(x = focal_param_1, y = focal_param_2, color = loglik), size = 3.5) + scale_color_viridis(option = "magma") + 
  geom_contour(data = mtrx.melt, aes(x = focal_param_1, y = focal_param_2, z = loglik), color = "black", linetype = 1) +  
  geom_dl(data = mtrx.melt, aes(x = focal_param_1, y = focal_param_2, z = loglik, label = ..level..), stat = "contour", method = list("bottom.pieces", cex = .75), color = "black") 
p_d0_lambda0 <- p_d0_lambda0 + plot_themes 
p_d0_lambda0 <-   p_d0_lambda0 + xlab(bquote(lambda[0])) + ylab(bquote(d[celibate])) + labs(color = paste0("Log","\n","likelihood"))

if(save_plots){
  save_plot("./figures/profile_d0_lambda0.pdf", p_d0_lambda0)
} 

#3.) Combine the results for the d params 
p_d_results <- plot_grid(p_d, p_d0_lambda0, labels = c("A", "B"), nrow = 2, align = "v")
if(save_plots){
  save_plot("./figures/d_results.pdf", p_d_results)
}
