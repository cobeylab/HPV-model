
### ----------------------------------------------------------------------------------------------------------------------------
evaluate_profile_point <- function(chainId, 
                                  guess, 
                                  starts, 
                                  n_part, 
                                  n_mif, 
                                  n_mif_updated,
                                  rw_sd_vec,
                                  coolng_rate,
                                  n_particles_pfilter,
                                  n_reps_pfilter,
                                  mif_chain_filename,
                                  table_name, 
                                  results_db,
                                  output_filename,
                                  evaluate_Lhood){
  init_params <- unlist(starts %>% select(-chainId))
  guess[names(init_params)] <- init_params
  guess.shared <- guess[names(guess) %in% names(init_params)]
  guess.specific <- guess[!(names(guess) %in% names(init_params))]
  cat("i is: ",i,"\n")
  start <- Sys.time()
  mf <- mif2(
      panelHPVShared,
      Nmif = n_mif,
      shared.start = guess.shared,
      specific.start = matrix(
        data =  guess.specific,
        nrow = length(guess.specific),
        ncol = length(panelHPVShared@unit.objects),
        dimnames = list(names(guess.specific),
        names(panelHPVShared@unit.objects))                 
      ),
      rw.sd = rw_sd_vec,
      cooling.type = "geometric",
      cooling.fraction.50 = cooling_rate,
      Np = n_part
    )
    end <- Sys.time()
  print(end-start)
  save(mf, file = mif_chain_filename)
  
  ## Evaluate the likelihood ----------------------------------------------------------------
  if(evaluate_Lhood == TRUE){
    ll <- logmeanexp(replicate(n_reps_pfilter,logLik(pfilter(mf,Np=n_particles_pfilter))),se=TRUE)
    output <- (data.frame(as.list(coef(mf)$shared),loglik=ll[1],loglik.se=ll[2], n_mif = n_mif_updated, n_part = n_particles_pfilter, chain = chainId))
    write.table(output, file = output_filename, sep = ",",col.names = FALSE, append=TRUE)
    db <- dbConnect(SQLite(), results_db)
    dbWriteTable(db, table_name, output, append = T)
    dbDisconnect(db)
  }
}
