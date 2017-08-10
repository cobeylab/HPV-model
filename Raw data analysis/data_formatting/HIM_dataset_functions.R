## Functions to format the raw data ###########################

# Takes character string dates and returns dates in years numerically (reference date 1/1/1970)
get_numeric_dates <- function(x){
  return(as.numeric(as.Date(x))/365)
}

# Returns the country based on conventions for subject IDs
countryFromSubjectId <- function(subjectId)
{
  country <- character(length(subjectId))
  country[subjectId < 20000] <- "USA"
  country[subjectId >= 20000 & subjectId < 30000] <- "Brazil"
  country[subjectId >= 30000] = "Mexico"
  return(country)
}


# Extracts prevalence given HPV type and sampling window 
get_prev <- function(this_type, st){
  inf <- inf_status %>% filter(type == this_type) %>% 
    select(-type)
  dfm <- merge(inf, visit_dates, by = c("subjectId","visitId"))
  #dfm$date <- as.numeric(as.Date(dfm$date))
  intervals <- sort(unique(dfm$int))
  prev <- array(NA, length(intervals))
  #for( i in 2:length(st)){
    #dfm %>% filter(date > st[i-1] & date < st[i] & !is.na(status)) -> dfm_sub
    #prev[i] <- sum(dfm_sub$status)/nrow(dfm_sub)
 # }
  for(i in c(1:length(intervals))){
    dfm %>% filter(int == intervals[i] & !is.na(status)) -> dfm_sub
    prev[i] <- sum(dfm_sub$status)/nrow(dfm_sub)
  }
  #prev <- prev[-1]
  return(prev)
}

formatDate <- function(datesCol){
  newDates <- numeric(length(datesCol))
  for(i in 1:length(datesCol)){
    newDates[i] <- as.Date(datesCol[i],"%m/%d/%y" )
  }
  return(newDates)
}

filter_zeros <- function(vec){
  
  validStatus <- !is.na(vec)
  vec2 <- vec[validStatus]
  if(length(vec2)>=3){
    for ( j in 2:(length(vec2)-1)){
      if (vec2[j-1] == 1 & vec2[j] == 0 & vec2[j+1] == 1){
        vec2[j] <- 1
        print("one filtering")
      }# end if 
    }## end j
  }## end if 
  vec[validStatus] <- vec2
  return(vec) 
}

#set values "Inf" to NA 
removeInf <- function(x){
  x[(!is.finite(x) & !is.na(x))] <- NA
  return(x)
}



makeBinaryCov <- function(covariate){
  covTable <- table(covariate)
  covNames <- names(covTable)
  covBinary <- matrix(NA, length(covariate), length(covNames))
  for (i in 1: length(covNames)){
    covBinary[,i] <- as.numeric(covariate == covNames[i])
  }
  colnames(covBinary) <- covNames
  return(covBinary)
}

# Generates the distribution of infection durations from the data 
get_duration_dist <- function(type = this_strain, 
                              filter_zero_visits = T,
                              table_name_infections,
                              table_name_visits,
                              dbFilename 
){
  
  db <- dbConnect(SQLite(), dbFilename)
  data <- dbReadTable(db, table_name_infections)
  times <- dbReadTable(db, table_name_visits)
  dbDisconnect(db)
  # Do we want to weed out the "false negatives"?
  
  if(filter_zero_visits){
    for( i in 1:nrow(data)){
      this_vec <- data[i,names(data)!="subjectId"]
      new_vec <- filter_zeros(this_vec)
      data[i, names(data)!="subjectId"] <- new_vec
    }
  }
  dfm <- melt(data, id.vars = "subjectId")
  data$type <- type
  dur_dist <- data.frame()
  for( i in 1:nrow(data)){
    cat("i is ", i, "\n")
    dur <- get_individual_durations(i,dataset = data,visit_times = times,ends = T)
    dur_dist <- rbind(dur_dist, dur)
  }
  dur_dist <- subset(dur_dist, durations > 0)
  dur_dist$data_type <- "empirical"
  return(dur_dist)
}

# Generate a dataframe for one individual listing the durations of all of their infections with a type
get_individual_durations <- function(i, dataset , visit_times, ends = FALSE){
  durations <- data.frame(individual = i, 
                          durations = as.numeric(unlist(get_infection_durations( i, data = dataset, times_full=visit_times,count_ends = ends))))
  return(durations)
}

# Get list of infection durations for one individual
get_infection_durations <- function( i, data, times_full, count_ends = FALSE){
  pat_inf <- data[i,grep("y",names(data))]
  times <- as.numeric(times_full[i,grep("v",names(times_full))])
  pat_vis <- times
  infected_visits <- which(pat_inf==1)
  infected_dates <- pat_vis[infected_visits]
  
  if(length(infected_dates) == 0){
    dur <- list(0)
  }
  if(length(infected_dates) > 0){
    dur <- list()
    this_inf <- 0
    inf <- 0
    while(this_inf < length(pat_inf)){
      inf <- this_inf + min(which(pat_inf[(this_inf+1): length(pat_inf)] == 1))
      if(is.finite(inf) & inf < length(pat_inf)){
        inf_date <- pat_vis[inf]
        cat("inf is: ", inf, "\n")
        clr <- inf + min(which(pat_inf[(inf+1):length(pat_inf)] == 0))
        if(is.finite(clr)){
          clr_date <- pat_vis[clr] 
          duration <- clr_date - inf_date
          cat("duration is: ", duration, "\n" )
          dur[[length(dur) + 1]] <- duration
          this_inf <- clr
        }
        if(!is.finite(clr)){
          if(count_ends == TRUE){
            clr_date = pat_vis[max(which(!is.na(pat_vis)))]
            duration <- clr_date - inf_date
            cat("duration is: ", duration, "\n" )
            dur[[length(dur) + 1]] <- duration
          }
          this_inf <- length(pat_inf)
        }
      }
      if(inf >= length(pat_inf)){
        this_inf = length(pat_inf)
      }
      
      if(length(dur) == 0){
        dur <- list(0)
      }
    }
  }
  if(count_ends == FALSE & length(dur) >0 ){
    if(min(infected_visits) == 1){
      dur[[1]] <- NULL
      cat("removed first infection")
    }
  }
  if(length(dur) == 0){
    dur <- list(0)
  }
  return(dur)
}

## Make factor variables from binary covariates
make_dummy_var <- function(vec,data){
  # Create dummy variables 
  for(level in unique(vec)){
    data[paste(level)] <- as.factor(ifelse(vec == level, 1, 0))
  }
  return(data)
}
