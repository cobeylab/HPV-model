## Take in data and create a pomp object for each individual # ---------------------------------------------------
make_pomp_panel <- function(i, infection_data = data, times_data = times, covariates = covartable, n_cov = n_covariates, test_params = guess, rprocess = rprocess_homologous_immunity, init = init_homologous_immunity ){
  log_paramnames <- names(test_params)
  cat("i is: ", i , "\n")
  n.cov <- length(grep("cov",names(covariates)))
  data_i <- infection_data[i,grep("y",names(infection_data))]
  ind <- which(!is.na(data_i))
  data_i_complete <- data_i[ind]
  covariates_i <- subset(covariates, subjectId == infection_data[i,]$subjectId)
  times_i <- times_data[i,grep("v",names(times_data))]
  times_i_complete <- times_i[ind]
  covs <- covariates_i[ind, grep("cov|c_i",names(covariates_i))]
  
  n.vis <- length(times_i_complete)
  print(n.vis)
  t <- as.numeric(get_tbv(times_i_complete))
  stopifnot(t[1] == 0)
  t <- t[-1]

  covartab <- data.frame(tbv = c(t,0) ,
                         covs
  )
  
  names(covartab) <- c("tbv", paste0("cov",c(1:n_cov)),"c_i","cov_7_2","cov_8_2")
  covartab$visit <- c(1:n.vis)

  pomp_data <- data.frame(y = as.numeric(data_i_complete[1:n.vis]),
                          visit = c(1:n.vis))
    
  statenames = c("x","duration_remaining", "previously_cleared", "t_activate", "t_cum")
  obsnames = "y"
  
  pomp_object <- pomp(
      data = pomp_data,
      times ="visit",
      t0=1,
      params=unlist(test_params),
      rprocess = discrete.time.sim(step.fun=rprocess,delta.t=1),
      dmeasure = dmeasure,
      rmeasure = rmeasure,
      covar = covartab,
      tcovar = "visit",
      obsnames = obsnames,
      statenames = statenames,
      paramnames = log_paramnames,
      initializer = init
    ) 

  return(pomp_object)
}
