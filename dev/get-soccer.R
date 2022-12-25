#===============================================================================
# 2022-12-10 -- oddor
# get soccer data
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================


source("dev/prepare-session.R")
library(oddor)



# world cup ---------------------------------------------------------------

urls <- c(
    paste0(
        "https://www.oddsportal.com/soccer/world/world-cup-",
        seq(2010, 2018, 4),
        "/results/#/page/"
    ),
    paste0(
        "https://www.oddsportal.com/soccer/world/world-championship-",
        2022,
        "/results/#/page/"
    )
) %>%
    map(function(x) x %>% paste0(1:2)) %>%
    unlist()

# for some reason these two lines work really unstable, I have to try several times before it works
odds_set_up_virtual_browser(port = 4445)
soccer_world_cup_raw <- urls %>% map_df(odds_table_from_url)
#
# # fix the error with future matches
# soccer_world_cup_raw <- soccer_world_cup_raw %>%
#     filter(! x %in% c("Croatia - Brazil", "Netherlands - Argentina"))

save(soccer_world_cup_raw, file = "~/Downloads/raw_data_wc.rda")

soccer_world_cup <- soccer_world_cup_raw %>%
    odds_clean_tournament_dataframe()

# get rid of qualification records
soccer_world_cup <- soccer_world_cup %>%
    filter(!stage == "Qualification")

usethis::use_data(soccer_world_cup, overwrite = TRUE)



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


# Europa league / UEFA cup -----------------------------------------------------------
# https://www.oddsportal.com/soccer/europe/europa-league/results/

urls_europa_league <- paste0(
    "https://www.oddsportal.com/soccer/europe/europa-league-",
    2009:2022, "-", 2019:2023,
    "/results/#/page/"
) %>%
    map(function(x) x %>% paste0(1:11)) %>%
    unlist()

urls_uefa_cup <- paste0(
    "https://www.oddsportal.com/soccer/europe/uefa-cup-",
    2003:2008, "-", 2004:2009,
    "/results/#/page/"
) %>%
    map(function(x) x %>% paste0(1:8)) %>%
    unlist()

urls <- c(urls_uefa_cup, urls_europa_league)


odds_set_up_virtual_browser(port = 4445, browser = "firefox")
soccer_europa_league_raw <- urls %>% map_df(odds_table_from_url)

soccer_europa_league <- soccer_europa_league_raw %>%
    odds_clean_tournament_dataframe()

usethis::use_data(soccer_europa_league)



# Europa Conference League ------------------------------------------------
# https://www.oddsportal.com/soccer/europe/europa-conference-league/results/

urls_europa_conference_league <- paste0(
    "https://www.oddsportal.com/soccer/europe/europa-conference-league-",
    2021:2022, "-", 2022:2023,
    "/results/#/page/"
) %>%
    map(function(x) x %>% paste0(1:9)) %>%
    unlist()


odds_set_up_virtual_browser(port = 4445, browser = "firefox")
soccer_europa_conference_league_raw <- urls_europa_conference_league %>%
    map_df(odds_table_from_url)

soccer_europa_conference_league <- soccer_europa_conference_league_raw %>%
    odds_clean_tournament_dataframe()

usethis::use_data(soccer_europa_conference_league)



# English Premier League -------------------------------------------------

# https://www.oddsportal.com/soccer/england/premier-league-2003-2004/results/

urls_premier_league <- paste0(
    "https://www.oddsportal.com/soccer/england/premier-league-",
    2003:2022,
    "-",
    2004:2023,
    "/results/#/page/"
) %>%
    map(function(x) x %>% paste0(1:8)) %>%
    unlist()

odds_set_up_virtual_browser(port = 4445, browser = "firefox")
soccer_premier_league_raw <- urls_premier_league %>%
    map_df(odds_table_from_url)

soccer_premier_league <- soccer_premier_league_raw %>%
    odds_clean_tournament_dataframe()

usethis::use_data(soccer_premier_league)
