d_dist <- df_all %>% filter(type == "hpv16") 
d_dist <- d_dist %>% group_by(time) %>% mutate(mean = mean(frac_d0), time_f = as.factor(paste0(time, " years")))
d_dist <- d_dist %>% filter(round(time,2) %in% c(0,1,3))
d_dist$time <- as.factor(d_dist$time)
p_t <- ggplot(d_dist, aes(x = frac_d0)) + geom_histogram(aes(y=..count../sum(..count..)),bins = 150, alpha = .8, color = "gray") #aes(fill = time)) + scale_fill_viridis()

p_t <- p_t + xlim(.93,1.0) + 
  plot_themes+ 
  geom_vline(aes(xintercept = mean),linetype = 2) + 
  facet_grid(time_f~.,scales = "free_y") + 
  xlab(bquote(Fraction~of~force~of~infection~due~to~additional~risk~(d[cij]/lambda[ij0])))  + ylab("Frequency") 

if(save_plots){
  save_plot("./figures/d_dist.pdf", p_t, base_height=3,base_aspect_ratio = 1.5)
}