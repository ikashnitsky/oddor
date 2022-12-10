#===============================================================================
# 2022-12-08 -- oddor
# set up the virtual browser
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================


# Below goes a compicated solution how to parse a dynamic web page
# With lots of trials, errors, and cursing I made it work on my machine (Mac)
# First part comes from here
# https://stackoverflow.com/questions/55731769/undefined-error-in-httr-call-httr-output-recv-failure-connection-was-reset
# Second part (from remDr$navigate(url) -- line 36) comes from
# https://stackoverflow.com/questions/45759790/web-scrape-with-rvest-from-a-table-that-is-not-defined

#' set up the virtual browser
#' @param port an integer or numeric 4 digit input
#'
#' @importFrom wdman phantomjs
#' @importFrom RSelenium remoteDriver
#' @export
odds_set_up_virtual_browser <- function(port = 8912L) {

    port <- as.integer(port)

    pjs <- wdman::phantomjs(port=port)

    eCap <- list(phantomjs.page.settings.userAgent
                 = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:29.0) Gecko/20120101 Firefox/29.0", phantomjs.page.settings.loadImages = FALSE, phantomjs.phantom.cookiesEnabled = FALSE, phantomjs.phantom.javascriptEnabled = TRUE)

    # return to the global environment
    .GlobalEnv$remDr<-remoteDriver(port=port, browser="phantomjs", extraCapabilities = eCap)

}
