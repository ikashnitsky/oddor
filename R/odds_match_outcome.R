#===============================================================================
# 2022-12-08 -- oddor
# match outcome function
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================


#' A simple function to determine the outcome of a match
#'
#' The function takes \code{oddsportal} score sting of the type "2:1" and parses it into the goals the outcome variable: eaither "home", "away", or "draw".
#' @param score_string a text input from the score column of the \code{oddsportal} dataset
#'
#' @importFrom magrittr %>%
#' @importFrom stringr str_detect
#' @importFrom stringr str_extract
#' @export
odds_match_outcome <- function(score_string) {

    if(score_string == "canc."){
        return("-")
    } else {
        draw_extra_time <- score_string %>% str_detect("ET")
        draw_penalty <- score_string %>% str_detect("pen.")
        home_goals <- score_string %>%
            str_extract("\\(?[0-9,.]+\\)*(?=:)") %>%
            as.numeric()
        away_goals <- score_string %>%
            str_extract("(?<=:).*") %>%
            str_extract("\\(?[0-9,.]+\\)?") %>%
            as.numeric()
        if (
            (home_goals == away_goals)
        ){
            outcome = "draw"
        } else if (
            draw_extra_time |
            draw_penalty
        ) {
            outcome = "draw"
        } else if (
            (home_goals > away_goals) &
            !draw_extra_time & !draw_penalty
        ) {
            outcome = "home"
        } else if (
            (home_goals < away_goals) &
            !draw_extra_time & !draw_penalty
        ) {
            outcome = "away"
        }
        return(outcome)
    }

}
