#===============================================================================
# 2022-12-04 -- oddor
# clean the raw oddsportal data
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================

#' Clean the dataframe downloaded from \code{oddsportal}
#'
#' @param oddsportal_raw raw dataframe from \code{odds_table_from_url()}
#'
#' @importFrom magrittr set_colnames extract
#' @importFrom magrittr %>%
#' @importFrom stringr str_to_lower str_extract
#' @importFrom dplyr mutate filter group_by ungroup case_when transmute
#' @importFrom tidyr fill separate replace_na
#' @importFrom rlang .data
#' @export
odds_clean_tournament_dataframe <- function(oddsportal_raw) {

    suppressWarnings(
        oddsportal_raw %>%
            # remove empty rows
            filter(! .data$w == "NA") %>%
            # clean date and stage variables
            mutate(
                a = case_when(
                    nchar(z) > 5 ~ z
                )
            ) %>%
            fill(a, .direction = "downup") %>%
            separate(a, into = c("date", "stage"), sep = " - ") %>%
            mutate(
                stage = stage %>% replace_na("Group")
            ) %>%
            # remove date rows
            filter(! nchar(z) > 5) %>%
            # identify the outcomes of the games, inc draws in main time
            group_by(id = seq_along(z)) %>%
            mutate(
                et_or_pen = x %>% str_to_lower() %>% str_extract("[a-z]+"),
                outcome = x %>% odds_match_outcome
            ) %>%
            ungroup() %>%
            # separate columns
            separate(y, into = c("home", "away"), sep = " - ") %>%
            separate(x, into = c("goals_home", "goals_away")) %>%
            # scores to numeric
            transmute(
                tournament = r,
                year = s,
                stage,
                home, away,
                goals_home = goals_home %>% as.numeric,
                goals_away = goals_away %>% as.numeric,
                et_or_pen,
                outcome,
                odds_home = w %>% as.numeric,
                odds_draw = v %>% as.numeric,
                odds_away = u %>% as.numeric,
                odds_win = case_when(
                    outcome == "home" ~ odds_home,
                    outcome == "away" ~ odds_away,
                    TRUE ~ odds_draw
                )
            )
    )
}
