## 
load("distribution_FOI_d.rda")
lambda_dist <- df_all %>% filter(time == 0)
p <- ggplot(lambda_dist, aes(x = log(1/(FOI)))) + geom_histogram(position= "identity", aes(y=..density..), bins =50,alpha = .5) + 
  xlab(bquote(Log~expected~time~(yrs)~until~first~infection~(1/lambda[ijt[0]]))) + 
  ylab("Frequency")

if(save_plots){
  p <- p + plot_themes + geom_vline(aes(xintercept = log(11)), linetype = 3) + xlim(0,10) + facet_wrap(~toupper(type), scales = "free_y", ncol = 3) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  p <- p +  theme(strip.background = element_rect(fill = NA, color = NA))
  save_plot("./figures/FOI_dist.pdf",p,base_aspect_ratio=1.3)
}

