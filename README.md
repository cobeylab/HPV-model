# Summary
This model tests hypotheses about the dynamics of HPV infection by fitting type-specific models of HPV infection to longitudinal data in men. 

The model is implemented in R, using an interface with C++ for the process model within the "pomp" package.

# Requirements and Setup 
The inference code was built and run using R version 3.3.2. R can be downloaded [here](https://www.r-project.org).
The code requires several packages that are not part of the base R installations. After installing R, navigate to the main repository directory and run the `installation.R` script. To run this script from the command line, simply navigate to the directory and execute:
```
Rscript installation.R
```
The packages should be installed in your R library.

# Visualizing the Raw Data
The data from the HPV in Men (HIM) study that was used in the modeling analysis is available in a Sqlite file in [Data](./Data). The [Raw data analysis](./Raw data analysis /) folder contains scripts to generate exploratory plots of the data. From the main repository directory, simply navigate to the [Raw data analysis](./Raw data analysis /) folder and execute the `raw_data_figs.R` script:
```
cd Raw\ data\ analysis\ /
R CMD BATCH ./raw_data_figs.R 
```
The figures will appear as pdfs in the [Raw data analysis](./Raw data analysis /Figures) folder.

# Running the Model 


