
################################################
## Install packages for the analysis 
################################################
#!/usr/bin/Rscript

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

# usage
packages <- c("plyr",
              "dplyr",
              "tidyr",
              "reshape2",
              "stringr",
              "parallel",
              "polycor",
              "ggplot2",
              "cowplot",
              "RSQLite",
              "corrplot",
              "viridis",
              "gridExtra",
              "devtools",
              "pomp")
ipak(packages)