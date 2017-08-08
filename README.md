# Summary
This model tests hypotheses about the dynamics of HPV infection by fitting type-specific models of HPV infection to longitudinal data in men. 
The model is implemented in R, using an interface with C++ for the dynamic model within the "pomp" [package](http://kingaa.github.io/pomp/install.html).

# Requirements and Setup 
The inference code was built and run using R version 3.3.2. R can be downloaded [here](https://www.r-project.org).
The code requires several packages that are not part of the base R installations. After installing R, navigate to the main repository directory and run the `installation.R` script. To run this script from the command line, simply navigate to the directory and execute:
```
R CMD BATCH ./installation.R 
```
The packages should be installed in your R library.

Before running any of the models, users may find it helpful to familiarize themselves with the *pomp* statistical inference software [1]. A helpful introduction can be found [here](https://kingaa.github.io/pomp/vignettes/getting_started.html).

# Visualizing the Raw Data
The data from the HPV in Men (HIM) study that was used in the modeling analysis is available in a Sqlite file in [Data](./Data). The [Raw data analysis](./Raw\ data\ analysis\ /) folder contains scripts to generate exploratory plots of the data. From the main repository directory, simply navigate to the [Raw data analysis](Raw data analysis /) folder and execute the `raw_data_figs.R` script:
```
cd Raw\ data\ analysis\ /
R CMD BATCH ./raw_data_figs.R 
```
The figures will appear as pdfs in the [Raw data analysis](.Raw\ data\ analysis\ /Figures) folder.

# Running the Model 
Each model runs separately from a self-contained directory. The underlying dynamic model and the observation model are specified in `rprocess.R`. The code was written to run each MIF search, or "chain", as a separate process, such that the exploration of the likelihood surface from different starting conditions can be parallelized across computing cores. The inference proceeds as follows for any candidate model:
1. **Generating a "pomp" object**  First, you will need to construct a pomp object with the data for the HPV type of interest. Update the parameters of the `generate_pomp_object.R` script to reflect the HPV type. The default is set to HPV16. Then run the `generate_pomp_object.R` script:
```
R CMD BATCH ./generate_pomp_object.R
```
The corresponding pomp object will be generated in the `pomp_objects` folder.

2. **Global exploration of the likelihood surface** Maximize the likelihood via a global exploration of the likelihood space from random starting parameter sets.  The`example_global_search_experiment.R` in the `example` folder of each model directory contains example code to set up and run one MIF search from a set of random model parameters. Here you can specify the HPV type and the parameters of the MIF search. The random walk of the standard deviation for each parameter can be changed in the `perform_global_search.R` script in the model directory. You can run any number of MIF searches in parallel. Each MIF search, or "chain" has an associated chain Id. This process will generate several output files in the `results` folder:
* A `.rda` file that stores the entire MIF chain.
* A SQLITE (`.sqlite`) database file that stores the output parameters of the global search, the likelihood (and associated standard error) for each ending parameter set, the chain Id, the number of particles used in the particle filter, and the total number of MIF iterations completed. As a default, the parameters from the global likelihood search will be saved to a "global_params" table, but this can be modified.
* A `.csv` file containing the output from the search (just in case there are overwrite issues with the SQLITE database due to many chains being run in parallel).

After the initial set of MIF iterations for each search, or chain, run the `continue_global_search.R` script to continue chains that have not converged. The parameters of the MIF search, including the random walk of the standard deviation for each parameter, can be updated within this script.

3. **Likelihood profiles** The [Additional risk model](./Inference/additional_risk_model) folder contains the code to construct likelihood profiles to calculate maximum likelihood parameter estiamtes and 95% confidence intervals. To profile over a parameter of interest for a given HPV type, first update the `perform_profile_likelihood.R` script to sweep over the desired range and parameter. Next, construct the profile by generating MIF searches from a series of starting parameter sets that sweep over the desired (fixed) range of the focal parameter. Example code to carry out a profile likelihood search is included in the `example_profile_likelihood.R` script in the `example` folder. As with the global likelihood search, this script generates one MIF chain for one profile point, and multiple profile points can be run in parallel by specifying a series of "chainId" variables. The output, generated in the `results` folder, consists of:
an associated chain Id. This process will generate several output files in the `results` folder:
* A `.rda` file that stores the entire MIF chain for the profile point.
* A SQLITE (`.sqlite`) database file that stores the output parameters of the profile search, the likelihood (and associated standard error) for the ending parameter set, the chain Id, the number of particles used in the particle filter, and the total number of MIF iterations completed. As a default, the results for each profile will be saved to a "profile_params" table that specifies the parameter of interest.
* A `.csv` file containing the output from the search (just in case there are overwrite issues with the SQLITE database due to many chains being run in parallel.)

## Calculating Confidence Intervals from Likelihood Profiles
Once the profile likelihood search has been completed, select the point of maximum likelihood for each value of the profile parameter to represent the inferred parameter. Then, use the Monte Carlo Adjusted Profile (MCAP) method<sup>1</sup> to calculate a smoothed estimate of the profile and the corresponding 95% confidence interval. A function containing the MCAP algorithm is given in the `MCAP_algorithm.R` script within the `analysis` folder of the `results` subdirectory.

# Figures from model results 


# References
1. Ionides EL, Breto C, Park J, Smith RA, King AA (2017) Monte Carlo profile confidence
 intervals for dynamic systems. Journal of The Royal Society Interface 14(132).
2. 

