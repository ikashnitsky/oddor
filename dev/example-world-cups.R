#===============================================================================
# 2022-12-08 -- oddor
# example -- World cups
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================

source("dev/prepare-session.R")
sysfonts::font_add_google("Atkinson Hyperlegible", "ah")
showtext_auto()

library(oddor)


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

# fix the error with furure matches
soccer_world_cup_raw <- soccer_world_cup_raw %>%
    filter(! x %in% c("Croatia - Brazil", "Netherlands - Argentina"))

save(soccer_world_cup_raw, file = "~/Downloads/raw_data_wc.rda")

soccer_world_cup <- soccer_world_cup_raw %>%
    odds_clean_tournament_dataframe()

# get rid of qualification records
soccer_world_cup <- soccer_world_cup %>%
    filter(!stage == "Qualification")

usethis::use_data(soccer_world_cup)



# test betting on the underdog --------------------------------------------

df_test <- soccer_world_cup %>%
    rowwise() %>%
    mutate(my_bet = max(odds_home, odds_draw, odds_away)) %>%
    ungroup() %>%
    mutate(
           # THE LOGIC: whenever I lose the bet, I just lose 1 coin
           # whenever my unlikely bet works, I receive the odds amount
           # minus my initially risked coin
           bet_result = case_when(
               my_bet == odds_win ~ my_bet - 1,
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



# Only filer group-stage games and remove year 2006 as it was not complete

set.seed(911)
df_test %>%
    filter(stage == "Group", ! year == "2006") %>%
    ggplot(aes(id, balance, color = year))+
    geom_hline(yintercept = c(0), size = .5, color = 2)+
    geom_step(size = 1, alpha = .5)+
    geom_point(data = . %>% filter(my_bet == odds_win))+
    geom_text_repel(
        data = . %>% filter(year == "2022", my_bet == odds_win),
        aes(label = paste(home, goals_home, ":", goals_away, away)),
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
ggsave("inst/figures/world-cup-odds-since-2010.pdf",
       width = 6.4, height = 5,
       bg = "#dadada")


