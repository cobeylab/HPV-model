
 # Filter data to require two negative visits after infection for a clearance event 
if(filter_clearance_events){
  for( i in 1:nrow(data)){
    this_vec <- data[i,names(data)!="subjectId"]
    new_vec <- filter_zeros(this_vec)
    data[i, names(data)!="subjectId"] <- new_vec
  }
}
  
# Center and scale the continuous covariates (corresponding to age, age at sexual debut, and educational status) 

names(covartable) <- c(paste0("cov",c(1:11)), "subjectId", "c_i","cov7_2","cov8_2","visit")
cont_covariates = paste0("cov",c(1:3))
cont_covs <- covartable[,names(covartable) %in% cont_covariates]
cont_covs_scaled <- apply(cont_covs,2, scale, center =T)
covartable[,names(covartable) %in% cont_covariates] <- cont_covs_scaled
  
## Construct panel pomp object ---------------------------------------------

# Don't overwrite an existing file
if(file.exists(pomp_filename)){
  print("pomp object exists")
}

if(!file.exists(pomp_filename)){
  pompList <- list()
  pats <- c(1:nrow(data))
  n.pat = length(pats)
  pompList <- lapply(as.list(pats), FUN = make_pomp_panel)
  names(pompList) <- paste0("individual_",c(1:n.pat))
  hpv <- pompList[[1]]
  shared_params <- coef(hpv)[1:(length(coef(hpv)))]
  specific_params <- coef(hpv)[!(names(coef(hpv)) %in% names(shared_params)) ]
  
  ## make panel pomp object from individual objects
  panelPomp(
    object = pompList,
    shared = shared_params,
    specific = matrix(
      data =  specific_params,
      nrow = length(specific_params),
      ncol = n.pat,
      dimnames = list(names(specific_params),
                      names(pompList))
    )
  ) -> panelHPVShared
  save(panelHPVShared , file = pomp_filename) 
}
