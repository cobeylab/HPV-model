################################################
## Generate figures from the raw data
################################################
library(tidyverse)
library(ggplot2)
library(cowplot)
library(RSQLite)
library(directlabels)
library(reshape)
library(tidyr)
library(viridis)
select <- dplyr::select
summarize <- dplyr::summarise
source(".././Figures/plot_themes.R")
source("./data_formatting/HIM_dataset_functions.R")
# Do you want to save the figures?
save_plots = 1

################################################
# Load in the data:
################################################
dbFilename <- "../Analysis/inference/Data/Data.sqlite"
db <- dbConnect(SQLite(), dbFilename)
tableNames <- dbListTables(db)
inf_status <- dbReadTable(db,"infection_status_complete")
visit_dates <- dbReadTable(db,"visit_dates_complete")
clearance_params <- dbReadTable(db, "infection_duration_parameters")
dbDisconnect(db)

HPV_types <- unique(inf_status$type)
Model_types <- paste0("hpv",c(62,84,89,16,51,6))

################################################
# Mean prevalence, all types:
################################################
visit_prev <- data.frame()
types <- HPV_types
for( i in 1:length(types)){
  this_type <- types[i]
  inf_df <- inf_status[inf_status$type == this_type,] %>% select(-country)
  inf_df$type<- NULL
  inf <- reshape(inf_df, idvar = "subjectId", timevar = "visitId", direction = "wide" )
  prev <- as.numeric(colMeans(inf[names(inf)!="subjectId"], na.rm=T))
  visit_prev <- rbind(visit_prev,prev)
  visit_prev$type[i] <- this_type
}

names(visit_prev) <- c(paste0("v", c(1:10)), "type")
dfm <- melt(visit_prev, id.vars = "type")
names(dfm) <- c("type","visit","prev")
dfm$type <- toupper(dfm$type)

mean_prev_df <- dfm %>% group_by(type) %>% summarize(mean = mean(prev), sd = sd(prev))

plot_mean_prev <- ggplot(mean_prev_df, aes(x = reorder(type, -mean), y = mean)) + 
  plot_themes+ 
  geom_point() + 
  geom_errorbar(aes(ymin = mean -sd, ymax = mean + sd)) + 
  ylab("Mean prevalence") + xlab("") +
  ylim(0,.12) + 
  theme(axis.text.x = element_text(angle=90, vjust = 0.5))
  

###############################################
# Prevalence over time, model types ##
###############################################

visit_dates <- reshape(visit_dates, timevar= "visitId", idvar = "subjectId", direction = "wide")
numeric_vis_dates <- data.frame(visit_dates$subjectId, apply(visit_dates[,2:11],2,get_numeric_dates))
names(numeric_vis_dates) <- c("subjectId",paste0("v",c(1:10)))
names(visit_dates) <- c("subjectId",paste0("v",c(1:10)))
dfm_dates <- melt(visit_dates, id.vars = "subjectId")
names(dfm_dates) <- c("subjectId", "visitId","date")
min_date <- min(as.numeric(as.Date(dfm_dates$date)), na.rm=T)
max_date <- max(as.numeric(as.Date(dfm_dates$date)), na.rm=T)

date_seq <- seq(to = max_date, from = min_date, by = .6*365)
df_all <- data.frame()

for ( i in 1:length(HPV_types)){
  df <- data.frame(date = date_seq[-1],
                   Type =HPV_types[i],
                   prev = get_prev(HPV_types[i], date_seq)
  )
  df_all <- rbind(df_all,df)
}
df_all <- subset(df_all , df_all$Type %in% Model_types)#paste0("hpv",c(62,84,89,16,51,6)))
df_all$Type <- toupper(df_all$Type)
dates <- as.Date(unique(df_all$date), origin = '1970-1-1')
p <- ggplot(df_all, aes(x = as.Date(date, origin = '1970-1-1'), y = prev, group = Type)) + geom_line(aes(color = Type))
plot_prev <- p + xlab("") +  scale_color_viridis(discrete = TRUE, option = "magma", end = .8) + xlim(dates[1], dates[length(dates) -2 ]) +
  scale_y_continuous(limits = c(0, 0.16), breaks = c(0, 0.02, 0.04, 0.06, 0.08,.1,.12,.14,.16)) +
  plot_themes + 
  theme(axis.line.x = element_line(),
        axis.line.y = element_line(),
        axis.text.x = element_text(angle=45, vjust = 0.5),
        legend.text = element_text(size = 7, color = "black"),
        legend.title= element_blank(),
        legend.position = c(.2,.82), legend.direction = "horizontal", legend.justification = "left") + 
        labs(x = "", y = "Prevalence")


## Generate Figure corresponding to prevalence data 
if(save_plots){
save_plot("./Figures/raw_data_prevalence.pdf",
          plot_grid(plot_mean_prev, plot_prev, nrow=2 , align = "h", labels = c("A","B")),
          base_aspect_ratio = .9
          )
}

###############################################
# Compare prevalence between countries ##
###############################################
countries <- unique(inf_status$country)
visit_prev <- data.frame()

for( j in 1:length(countries)){
  this_country <- countries[j]
  visit_prev_local <- data.frame()
  for( i in 1:length(HPV_types)){
    this_type <- HPV_types[i]
    inf_df <- inf_status %>% filter(type == this_type & country == this_country) %>% select(-c(type,country))
    inf <- reshape(inf_df, idvar = "subjectId", timevar = "visitId", direction = "wide" )
    prev <- c(as.numeric(colMeans(inf[names(inf)!="subjectId"], na.rm=T)))
    visit_prev_local <- rbind(visit_prev_local,prev)
  }
  visit_prev_local$Type <- HPV_types 
  visit_prev_local$Country <- this_country
  names(visit_prev_local) <- c(paste0("v", c(1:10)), "Type","Country")
  visit_prev <- rbind(visit_prev,visit_prev_local)
}

names(visit_prev) <- c(paste0("v", c(1:10)), "Type","Country")
dfm <- melt(visit_prev, id.vars = c("Type","Country"))
names(dfm) <- c("Type","Country","Visit","Prev")
dfm$Type <- toupper(dfm$Type)

mean_prev_countries <- dfm %>% 
  group_by(Type,Country) %>% 
  summarize(mean = mean(Prev)) %>% 
  spread(Country,mean)

p1 <- ggplot(mean_prev_countries, aes(x = Mexico, y = USA)) + geom_point() + geom_abline(linetype = 2)
cor1 <- cor.test( ~ Mexico + USA, 
                  data=mean_prev_countries,
                  method = "pearson",
                  continuity = FALSE,
                  conf.level = 0.95)
p1 <- p1 + annotate("text",x= .06, y = .03, label = paste("rho ==", round(cor1$estimate,3)),parse=T)+ xlab("Mexico") + ylab("USA") + labs(color = "HPV type") #+ plot_themes

p2<- ggplot(mean_prev_countries, aes(x = Mexico, y = Brazil)) + geom_point() + geom_abline(linetype = 2)
cor2 <- cor.test( ~ Mexico + Brazil, 
                  data=mean_prev_countries,
                  method = "pearson",
                  continuity = FALSE,
                  conf.level = 0.95)
p2 <- p2 + annotate("text",x= .06 , y = .03, label = paste("rho ==", round(cor2$estimate,3)),parse=T) + xlab("Mexico") + ylab("Brazil") + labs(color = "HPV type") #+ plot_themes

p3<- ggplot(mean_prev_countries, aes(x = USA, y = Brazil)) + geom_point() + geom_abline(linetype = 2)
cor3 <- cor.test( ~ USA + Brazil, 
                  data=mean_prev_countries,
                  method = "pearson",
                  continuity = FALSE,
                  conf.level = 0.95)
temp <- paste("Spearman ",expression(rho),":" ,round(cor3$estimate,3), "**")
est <- round(cor3$estimate,3)

p3 <- p3 + annotate("text",x= .06, y = .03,label= paste("rho ==", est),parse=T) + xlab("USA") + ylab("Brazil") + labs(color = "HPV type") #+ plot_themes

p <- plot_grid(p1 + xlim(0,.125) + ylim(0,.125) + theme(aspect.ratio = 1),p2 +  xlim(0,.125) + ylim(0,.125) + theme(aspect.ratio = 1),p3 + xlim(0,.125) + ylim(0,.125) + theme(aspect.ratio = 1),
               align = "v",
               ncol=3
              )

## Generate Figure corresponding to prevalence data 
if(save_plots){
  save_plot("./Figures/cor_prevalences.pdf",p, base_aspect_ratio=3)
}

#################################################
# Plot the distribution of infection durations ##
#################################################

## 1.) Distribution of infection durations 
infection_durations <- data.frame()
df_densities <- data.frame()
for(i in c(1:length(Model_types))){
  this_type = Model_types[i]
  infection_table <- paste0("infection_data_",toupper(this_type))
  inf_dur <- get_duration_dist(type = this_type, table_name_infections = infection_table, table_name_visits = "visit_dates", dbFilename = dbFilename)
  inf_dur$type = toupper(this_type)
  dur <- as.numeric(clearance_params %>% filter(Type == toupper(this_type)) %>% select(Mean_duration))
  var <- as.numeric(clearance_params %>% filter(Type == toupper(this_type)) %>% select(Variance_duration))
  df <- data.frame(x=seq(0,max(inf_dur$durations),length.out = 1000),
                   y=dgamma(seq(0,max(inf_dur$durations),length.out = 1000), shape = dur^2/var, scale = var/dur),
                   type = toupper(this_type))
  
  infection_durations <- rbind(infection_durations,inf_dur)
  df_densities <- rbind(df_densities,df)
}

p <- ggplot() +
  geom_histogram(data = infection_durations, aes(group = type, x=durations,y=..density..),bins=17) +
  geom_line(data = df_densities, aes(x=x, y=y), color="red", size = .5) + 
  facet_wrap(~type) +
  xlab("Infection duration (yrs)") + 
  ylab("Density") + 
  plot_themes + 
  theme(strip.background = element_rect(fill = NA, color = NA))

## Generate Figure corresponding to infection_duration_distribution 
if(save_plots){
  save_plot("./Figures/infection_durations.pdf", p, base_aspect_ratio = 1.3)
}

