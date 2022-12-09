# <img src="inst/figures/hex-oddor.png" align="right" width="130" height="150" />  oddor: historical odds data from oddsportal, ready for R


The website [oddsportal.com](https://www.oddsportal.com) provides historical data for the outcomes of various sport events and the betting odds associated with them. The website is dynamically generated, which makes it difficult to scrape the data from it. `oddor` provides functions to scrape this data and stores some popular competitions data within the package, ready to be used in R.

# How to use `oddor`

Install the package from github, load it and use the data. 


```{r}
# install
devtools::install_github("ikashnitsky/oddor")

# load
library(oddor)

# use
View(soccer_world_cup)
```


