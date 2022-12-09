#===============================================================================
# 2022-12-04 -- misc
# get oddsportal data
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================

library(tidyverse)
library(magrittr)
library(ggrepel)
library(sysfonts)
library(showtext)
library(prismatic)
library(wdman)
library(RSelenium)
library(rvest)

# Below goes a compicated solution how to parse a dynamic web page
# With lots of trials, errors, and cursing I made it work on my machine (Mac)
# First part comes from here
# https://stackoverflow.com/questions/55731769/undefined-error-in-httr-call-httr-output-recv-failure-connection-was-reset
# Second part (from remDr$navigate(url) -- line 36) comes from
# https://stackoverflow.com/questions/45759790/web-scrape-with-rvest-from-a-table-that-is-not-defined

# set up the virtual browser
pjs <- wdman::phantomjs(port=8912L)

eCap <- list(phantomjs.page.settings.userAgent
             = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:29.0) Gecko/20120101 Firefox/29.0", phantomjs.page.settings.loadImages = FALSE, phantomjs.phantom.cookiesEnabled = FALSE, phantomjs.phantom.javascriptEnabled = TRUE)


remDr<-remoteDriver(port=8912L, browser="phantomjs", extraCapabilities = eCap)

odds_table_from_url <- function(url) {
    remDr$open()

    remDr$navigate(url)

    page <- remDr$getPageSource()
    remDr$close()
    year <- url %>% str_sub(51, 54)

    table <- page[[1]] %>%
        read_html() %>%
        html_nodes(xpath='//table[@id="tournamentTable"]') %>%
        html_table(fill = T) %>%
        as.data.frame() %>%
        set_colnames(letters[1:7]) %>%
        mutate(h = year) %>%
        mutate(across(.cols = everything(), ~ .x %>% paste))

    return(table)
}


urls <- paste0(
    "https://www.oddsportal.com/soccer/world/world-cup-",
    seq(2006, 2022, 4),
    "/results/#/page/"
) %>%
    map(function(x) x %>% paste0(1:2)) %>%
    unlist()

raw_data <- urls %>% map_df(odds_table_from_url)

# fix the error with England-Senegal
raw_data <- raw_data %>% filter(! c == 'England - Senegal')

save(raw_data, file = "~/Downloads/raw_data.rda")


# a tiny function to identify outcome in the main time from the score
match_outcome <- function(score_string) {
    # 0 = draw; 1 = 1 team win; 2 =  2 team win
    draw_extra_time <- score_string %>% str_detect("ET")
    draw_penalty <- score_string %>% str_detect("pen.")
    team_1_goals <- score_string %>%
        str_extract("\\(?[0-9,.]+\\)*(?=:)") %>%
        as.numeric()
    team_2_goals <- score_string %>%
        str_extract("(?<=:).*") %>%
        str_extract("\\(?[0-9,.]+\\)?") %>%
        as.numeric()
    if (
        (team_1_goals == team_2_goals)
    ){
        outcome = 0
    } else if (
        draw_extra_time |
        draw_penalty
    ) {
        outcome = 0
    } else if (
        (team_1_goals > team_2_goals) &
        !draw_extra_time & !draw_penalty
    ) {
        outcome = 1
    } else if (
        (team_1_goals < team_2_goals) &
        !draw_extra_time & !draw_penalty
    ) {
        outcome = 2
    }
    return(outcome)
}



# clean the downloaded data
foo <- raw_data %>%
    # remove empty rows
    filter(! d == "NA") %>%
    # clean date and stage variables
    mutate(
        x = case_when(
            nchar(a) > 5 ~ a
        )
    ) %>%
    fill(x) %>%
    separate(x, into = c("date", "stage"), sep = " - ") %>%
    mutate(
        stage = stage %>% replace_na("Group")
    ) %>%
    # remove date rows
    filter(! nchar(a) > 5) %>%
    # remove qulification games (I didn't load them all initiallly)
    filter(! stage == "Qualification") %>%
    # remover weird empty rows at the end
    filter(!seq_along(a) %in% c(297, 299)) %>%
    # identify the outcomes of the games, inc draws in main time
    group_by(id = seq_along(a)) %>%
    mutate(
        et_or_pen = c %>% str_to_lower() %>%  str_extract("[a-z]+"),
        outcome = c %>% match_outcome
    ) %>%
    ungroup() %>%
    # separate columns
    separate(b, into = c("team_1", "team_2"), sep = " - ") %>%
    separate(c, into = c("goals_1", "goals_2")) %>%
    # arrange(date, a) %>%
    # scores to numeric
    transmute(
        year = h,
        stage,
        team_1, team_2,
        goals_1 = goals_1 %>% as.numeric,
        goals_2 = goals_2 %>% as.numeric,
        et_or_pen, outcome,
        odds_1 = d %>% as.numeric,
        odds_d = e %>% as.numeric,
        odds_2 = f %>% as.numeric
    ) %>%
    rowwise() %>%
    mutate(my_bet = max(odds_1, odds_d, odds_2)) %>%
    ungroup() %>%
    mutate(
        winning_bet = case_when(
            outcome == 1 ~ odds_1,
            outcome == 2 ~ odds_2,
            TRUE ~ odds_d
        ),
        # THE LOGIC: whenever I lose the bet, I just lose 1 coin
        # whenever my unlikely bet works, I receive the odds amount
        # minus my initially risked coin
        bet_result = case_when(
            my_bet == winning_bet ~ my_bet - 1,
            TRUE ~ -1
        )
    ) %>%
    group_by(year, stage) %>%
    mutate(id = {n() - seq_along(year)}+1) %>%
    arrange(year, stage, id) %>%
    mutate(
        balance = bet_result %>% cumsum()
    ) %>%
    ungroup()



# plot --------------------------------------------------------------------

# Only filer group-stage games and remove year 2006 as it was not complete

set.seed(911)
foo %>%
    filter(stage == "Group", ! year == "2006") %>%
    ggplot(aes(id, balance, color = year))+
    geom_hline(yintercept = c(0), size = .5, color = 2)+
    geom_step(size = 1, alpha = .5)+
    geom_point(data = . %>% filter(my_bet == winning_bet))+
    geom_text_repel(
        data = . %>% filter(year == "2022", my_bet == winning_bet),
        aes(label = paste(team_1, goals_1, ":", goals_2, team_2)),
        size = 2.7, color = "#444444", hjust = 1, fontface = 2
    )+
    scale_x_continuous(breaks = c(seq(0, 40, 10),48), position = "top")+
    scale_y_continuous(position = "right")+
    scale_color_viridis_d(option = "F", begin = .1, end = .7, direction = -1)+
    labs(
        x = "All the group-stage games of FIFA World Cups, ordered chronologically",
        y = "Net balance",
        title = "Were there too many sensations in Qatar?",
        caption = "Data: oddsportal.com // Design: @ikashnitsky@fosstodon.org"
    )+
    theme_minimal(base_family = "ah")+
    theme(
        panel.grid.minor = element_blank(),
        legend.position = "bottom",
        plot.background = element_rect(fill = "#dadada", color = NA),
        plot.title = element_text(size = 22, face = 2, color = "#444444")
    )+
    annotate(
        "text", label = "Imagine, I put 1 coin per game betting against the odds",
        size = 5, color = 2 %>% clr_darken(), alpha = .85,
        x = 1, y = 63, hjust = 0, vjust = 1,
        family = "ah", lineheight = .9, fontface = 2
    )+
    annotate(
        "text", label = "I start with a 0 net balance, and every game it reduces by one coin... unless a sensation happens and my balance increases as I win the unlikely bet" %>% str_wrap(60),
        size = 3.5, color = 2 %>% clr_darken(), alpha = .85,
        x = 1, y = 53, hjust = 0, vjust = 1,
        family = "ah", lineheight = .9
    )+
    annotate(
        "text", label = "If I'm above the zero line that means I'm in a net profit, benefiting from betting at the sensations" %>% str_wrap(40),
        size = 3.5, color = 2 %>% clr_darken(), alpha = .75,
        x = 1, y = -20, hjust = 0, vjust = 0,
        family = "ah", lineheight = .9
    )+
    annotate(
        "text", label = "It seems that the World Cup 2022 in Qatar is exceptional" %>% str_wrap(30),
        size = 5, color = 2 %>% clr_darken(), alpha = .85,
        x = 48, y = -25, hjust = 1, vjust = 0,
        family = "ah", lineheight = .9, fontface = 2
    )

set.seed(911)
ggsave("221202-world-cup-odds/world-cup-odds-since-2010.pdf",
       width = 6.4, height = 5,
       bg = "#dadada")

# Copy alt-text
# Plot all the group-stage game outcomes at FIFA World Cups 2010, 2014, 2018, and 2022. I'm running an experiment where I consistently bet at the least likely outcome and track how my fictional balance changes over time. If there are many unlikely outcomes, my balance increases. All 4 lines representing 4 World Cups end up with a positive balance, but the World Cup 2022 is clearly in outlier by the frequency of the unlikely game outcomes.

viridis::viridis(4, option = "F", begin = .1, end = .7, direction = -1) %>%
    prismatic::check_color_blindness()

