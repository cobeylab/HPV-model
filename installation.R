################################################
## Install packages for the analysis 
################################################
#!/usr/bin/Rscript

## Create the personal library if it doesn't exist. Ignore a warning if the directory already exists.
dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)


## Install multiple packages
install.packages(c("plyr",
                 "dplyr",
                 "tidyr",
                 "reshape2",
                 "stringr",
                 "parallel",
                 "ggplot2",
                 "cowplot",
                 "RSQLite",
                 "corrplot",
                 "viridis",
                 "polycor",
                 "gridExtra",
                 "devtools",
                 "pomp"),
                 Sys.getenv("R_LIBS_USER"), 
                 repos = "http://cran.case.edu"
                 )