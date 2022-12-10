#===============================================================================
# 2022-12-08 -- oddor
# download tournament data from a url
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================

#' A function top download tournament results table from \code{oddsportal}
#'
#' The function takes \code{oddsportal} url as input and downloads the tournament data.
#' @param url a base text url leading to \code{oddsportal} results table
#'
#' @importFrom magrittr %>% set_colnames extract
#' @importFrom stringr str_detect str_remove_all str_trim
#' @importFrom stringr word str_remove str_extract str_replace_all
#' @importFrom rvest read_html html_nodes html_table
#' @importFrom dplyr mutate across
#' @importFrom tidyselect everything
#' @export
odds_table_from_url <- function(url) {

    # fix url if no page number is specified
    if (word(url, -2, sep = "/") == "results"){
        url_fix = paste0(url, "#/page/1/")
    } else if (word(url, -1, sep = "/") == "results"){
        url_fix = paste0(url, "/#/page/1/")
    } else {
        url_fix = url
    }

    remDr$open(silent = TRUE)
    remDr$navigate(url_fix)
    page <- remDr$getPageSource()
    remDr$close()

    foo <- url_fix %>%
        str_remove("/results/#/page/.*") %>%
        # https://stackoverflow.com/a/8374980/4638884
        str_extract("(?:[^\\/](?!(\\|/)))+$") %>%
        str_replace_all("-", " ")

    tournament <- foo %>%
        str_remove_all("([0-9]+).*$") %>%
        str_trim()

    year <- foo %>%
        str_extract_all("([0-9]+).*$") %>%
        unlist()

    table <- page[[1]] %>%
        read_html() %>%
        html_nodes(xpath='//table[@id="tournamentTable"]') %>%
        html_table(fill = T) %>%
        as.data.frame() %>%
        set_colnames(letters %>% rev %>% extract(1:7)) %>%
        filter(! z == "") %>%
        mutate(
            s = year,
            r = tournament
        ) %>%
        mutate(across(.cols = everything(), ~ .x %>% paste))

    return(table)
}

