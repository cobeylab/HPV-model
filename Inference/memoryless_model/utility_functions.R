
##------------------------------------------------------------------------------------------------
## Functions used in the analysis 
##------------------------------------------------------------------------------------------------

## Parameter transforms ##------------------------------------------------------------------------------------------------
anti_logit <- function(x){
  return(exp(x)/(1+exp(x)))
}

logit <- function(x){
  return(log(x/(1-x)))
}

## Data manipulation functions ------------------------------------------------------------------------------------------------

## Standardize covariates
standardize <- function(vec){
  return((vec-mean(vec))/(sd(vec)))
}

## Shift elements in a vector by specified lag
shift <- function(x, lag) {
  n <- length(x)
  xnew <- rep(NA, n)
  if (lag < 0) {
    xnew[1:(n-abs(lag))] <- x[(abs(lag)+1):n]
  } else if (lag > 0) {
    xnew[(lag+1):n] <- x[1:(n-lag)]
  } else {
    xnew <- x
  }
  return(xnew)
}

## Get the time between visits from vector of visit dates
get_tbv <- function(vec){
  tbv <- array(0,length(vec))
  for(i in 2:length(vec)){
    tbv[i] <- vec[i] - vec[i-1]
  }
  return(tbv)
}

## Adjust the covariate values so that activity reported over the previous six months affects 
##    the dynamics during the correct visit interval
adjust_covariates <- function(subj, cov_data = covartable){
  df <- cov_data %>% filter(subjectId == subj)  
  df <- df %>% mutate(diff_female = shift(diff_female,lag = -1),
                      diff_male = shift(diff_male, lag = -1),
                      condom_use = shift(condom_use, lag = -1),
                      steady_partner_2 = shift(steady_partner, lag = 1),
                      current_smoker_2 = shift(current_smoker, lag = 1)
  )
  return(df)
}

## Replace missing values in covariate data by using values at most recent visit 
replace_missing_values <- function(vec){
  for( i in 2:length(vec)){
    if( is.na(vec[i])){
      vec[i] <- vec[i-1]
    }
  }
  return(as.numeric(vec))
}

## Remove 1-0-1 infection patterns to impose clearance criteria of 2 consecutive negative visits 
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

## Calculate the observed durations of infection for one individual
get_infection_durations <- function( i, data, times_full, count_ends = FALSE){
  pat_inf <- data[i,grep("y",names(data))]
  times <- as.numeric(times_full[i,grep("v",names(times_full))])
  #pat_vis <- sapply(times, as.Date, origin = '1970-1-1')
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

## Generate a data frame with the infection durations for one individual
get_individual_durations <- function(i, dataset , visit_times, ends = FALSE){
  durations <- data.frame(individual = i, 
                          durations = as.numeric(unlist(get_infection_durations( i, data = dataset, times_full=visit_times,count_ends = ends))))
  return(durations)
}


## MIF inference functions ##------------------------------------------------------------------------------------------------

## Calculate the random walk standard deviation of mif chains given cooling params and number of iterations
cooling_function <- function(alpha = .5,n=1,m,N=10){
  c = alpha^((n-1 + (m-1)*N)/(50*N))
  return(c)
}

get_rw_sd <- function(alpha = .75, sigma = .01, m, n=1, N=10){
  c <- alpha^((n-1 + (m-1)*N)/(50*N))
  return(c*sigma)
}




