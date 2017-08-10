mle_df_all_types <- data.frame()
for(k in 1:length(HPV_types)){
  load(paste0("MLE_with_CI_", this_type,".rda"))
  mle_df_all_types <- rbind(mle_df_all_types, mle_df)
}
mm <- mle_df_all_types %>% filter(param_name %in% paste0("log_alpha_cov_", c(1:11))) 
mm$order <- as.numeric(sapply(strsplit(mm$param_name,"_"),"[[",4))
mm <- mm%>% 
  arrange(order) %>% 
  select(type,cov_name, MLE,LCI,UCI)

mm <- mm %>% mutate(note = paste0(round(exp(MLE),1), "\n", "[",round(exp(LCI),1),",",round(exp(UCI),1),"]")) %>%   
  mutate(sig = ifelse((UCI < 0 & LCI < 0) | (UCI >0 & LCI > 0), 1, 0)) %>%
  mutate(sig = ifelse(sig == 1 & (UCI < 0 & LCI < 0), -1, sig)) %>% 
  mutate(magnitude = round(MLE * abs(sig),3))

mm_notation <- mm %>% select(type,cov_name, note)
mm_magnitude <- mm %>% select(type,cov_name, magnitude)
mm <- mm %>% select(c(type, cov_name, sig))
mm <- reshape(mm, idvar="type",timevar= "cov_name", direction="wide")
mm_notation <- reshape(mm_notation, idvar="type",timevar= "cov_name", direction="wide")
mm_magnitude <- reshape(mm_magnitude, idvar="type",timevar= "cov_name", direction="wide")
types <- mm$type
cov_names <- as.character(unlist(mle_df_all_types %>% filter(param_name %in% paste0("log_alpha_cov_", c(1:11))) %>% select(cov_name) %>% distinct))
cov_names <- c("Age", "Educational level", "Age at \n sexual debut","# Recent female \n sex partners", "# Recent male \n sex partners", "Circumcised","Current smoker", "Steady sex partner","Consistent \n condom use", "Mexico", "Brazil")
mm$type <- NULL
mm_notation$type <- NULL
mm_magnitude$type <- NULL 

mm <- apply(mm,2,as.numeric)
mm <- apply(mm,2,round,2)
rownames(mm_magnitude) <- toupper(types)
colnames(mm_magnitude) <- cov_names
mm <- t(mm)
mm_notation <- t(mm_notation)
mm_magnitude <- t(mm_magnitude)

if(save_plots){
  my_palette <- colorRampPalette(c("red", "white", "blue"))(n = 100)
  lmat = rbind(c(0,4),c(0,3),c(2,1))
  lhei=c(.5,1,6)
  lwid=c(1,6) 
  save_plot("./figures/cov_results.pdf", 
            heatmap.2(x = mm_magnitude, 
                      Rowv = FALSE, 
                      Colv = TRUE, 
                      dendrogram = "none",
                      symbreaks = T, 
                      breaks = 101,
                      col = my_palette, #c("coral1", "white","cyan"),
                      cellnote = mm_notation, 
                      notecol = "black", 
                      notecex = 1,
                      trace = "none", 
                      key = TRUE, 
                      key.title = "Magnitude",
                      key.ylab = "",
                      key.xlab = "",
                      key.par = list(cex=0.1),
                      keysize =.25,
                      cexRow = 1,
                      cexCol =1,
                      lhei=lhei,
                      lwid=lwid,
                      lmat = lmat,
                      margins = c(5,12)),
            base_height =5,
            base_width = 7
  )
}
