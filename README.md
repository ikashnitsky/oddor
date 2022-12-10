# **oddor: historical odds data from oddsportal, ready for R**  <a href='https://www.reddit.com/r/dataisbeautiful/comments/zcm4r0'><img src='inst/figures/hex-oddor.png' align="right" width="20%" min-width="200px"/></a>

<!-- badges: start -->
[![Version-Number](https://img.shields.io/github/r-package/v/ikashnitsky/oddor?label=oddor&logo=R&?style=flat-square)](https://github.com/ikashnitsky/oddor) 
[![R-CMD-check](https://github.com/ikashnitsky/oddor/actions/workflows/R-CMD-check.yml/badge.svg?style=flat-square)](https://github.com/ikashnitsky/oddor/actions/workflows/R-CMD-check.yml) 
[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999?style=flat-square&logo=github)](https://github.com/ikashnitsky/oddor) 
[![Contributors](https://img.shields.io/github/contributors/ikashnitsky/oddor?style=flat-square)](https://github.com/ikashnitsky/oddor/graphs/contributors) 
[![Twitter Follow](https://img.shields.io/twitter/follow/ikashnitsky?color=blue&label=%40ikashnitsky&logo=twitter&style=flat-square)](https://twitter.com/ikashnitsky) 

<!-- badges: end -->


The website [oddsportal.com](https://www.oddsportal.com) provides historical data for the outcomes of various sport events and the betting odds associated with them. The website is dynamically generated, which makes it difficult to scrape the data from it. `oddor` provides functions to scrape this data and stores some popular competitions data within the package, ready to be used in R.

# How to use `oddor`

Install the package from github, load it and use the data. 


```{r}
# install
remotes::install_github("ikashnitsky/oddor")

# load
library(oddor)

# use
View(soccer_world_cup)
```


