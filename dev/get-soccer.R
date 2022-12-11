#===============================================================================
# 2022-12-10 -- oddor
# get soccer data
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================


source("dev/prepare-session.R")
library(oddor)



# world cup ---------------------------------------------------------------

urls <- paste0(
    "https://www.oddsportal.com/soccer/world/world-cup-",
    seq(2006, 2022, 4),
    "/results/#/page/"
) %>%
    map(function(x) x %>% paste0(1:2)) %>%
    unlist()

# for some reason these two lines work really unstable, I have to try several times before it works
odds_set_up_virtual_browser(port = 8912)
soccer_world_cup_raw <- urls %>% map_df(odds_table_from_url)

# fix the error with future matches
soccer_world_cup_raw <- soccer_world_cup_raw %>%
    filter(! x %in% c("Croatia - Brazil", "Netherlands - Argentina"))

save(soccer_world_cup_raw, file = "~/Downloads/raw_data_wc.rda")

soccer_world_cup <- soccer_world_cup_raw %>%
    odds_clean_tournament_dataframe()

# get rid of qualification records
soccer_world_cup <- soccer_world_cup %>%
    filter(!stage == "Qualification")

usethis::use_data(soccer_world_cup)



# champions league --------------------------------------------------------

# https://www.oddsportal.com/soccer/europe/champions-league/results/

urls <- paste0(
    "https://www.oddsportal.com/soccer/europe/champions-league-",
    2003:2022, "-", 2004:2023,
    "/results/#/page/"
) %>%
    map(function(x) x %>% paste0(1:5)) %>%
    unlist() %>%
    # remove non-existing links # uneecessary
    as_tibble() %>%
    filter(! seq_along(value) %in% c(2:5, 10, 90, 100)) %>%
    pull(value)

odds_set_up_virtual_browser(port = 4445, browser = "firefox")
soccer_champions_league_raw <- urls %>% map_df(odds_table_from_url)

soccer_champions_league <- soccer_champions_league_raw %>%
    odds_clean_tournament_dataframe()

usethis::use_data(soccer_champions_league)

#
# foo_urls <- paste0(
#     "https://www.oddsportal.com/soccer/europe/champions-league-",
#     2003:2022, "-", 2004:2023,
#     "/results/#/page/"
# ) %>%
#     map(function(x) x %>% paste0(1:5)) %>%
#     unlist() %>%
#     # remove non-existing links
#     as_tibble() %>%
#     slice(1:4) %>%
#     pull(value)
#
# oddor::odds_set_up_virtual_browser(port = 8912)
#
# soccer_champions_league_raw <- foo_urls %>% map_df(odds_table_from_url)
