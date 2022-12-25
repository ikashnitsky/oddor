#===============================================================================
# 2022-12-25 -- oddor
# example -- World cups
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================

library(tidyverse)
library(magrittr)
library(wdman)
library(RSelenium)
library(rvest)
library(ggrepel)
library(sysfonts)
library(showtext)
library(prismatic)
sysfonts::font_add_google("Atkinson Hyperlegible", "ah")
showtext_auto()

remotes::install_github("ikashnitsky/oddor")
library(oddor)



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
    group_by(year) %>%
    mutate(id = {n() - seq_along(year)}+1) %>%
    arrange(year, stage, id) %>%
    mutate(
        balance = bet_result %>% cumsum()
    ) %>%
    ungroup()



# Only filer group-stage games and remove year 2006 as it was not complete

set.seed(911)
df_test %>%
    ggplot(aes(id, balance, color = year))+
    geom_hline(yintercept = c(0), size = .5, color = 2)+
    # make Play-offs visually distinctive
    annotate(
        "rect",
        xmin = 49, xmax = 64, ymin = -Inf, ymax = Inf,
        fill = "#dfff00", alpha = .1
    )+
    geom_step(size = 1, alpha = .5)+
    geom_point(data = . %>% filter(my_bet == odds_win))+
    geom_text_repel(
        data = . %>% filter(year == "2022", my_bet == odds_win),
        aes(label = paste(home, goals_home, ":", goals_away, away)),
        size = 2.4, color = "#002F2F", hjust = 1, fontface = 2
    )+
    scale_x_continuous(breaks = seq(0, 64, 8), position = "top")+
    scale_y_continuous(position = "right")+
    scale_color_viridis_d(option = "F", begin = .1, end = .7, direction = -1)+
    labs(
        x = "All games of FIFA World Cups, ordered chronologically",
        y = "Net balance",
        title = "Were there too many unlikely results in Qatar?",
        caption = "Data: oddsportal.com // Design: @ikashnitsky@fosstodon.org"
    )+
    theme_minimal(base_family = "ah")+
    theme(
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "#ccffff"),
        legend.position = "bottom",
        plot.background = element_rect(fill = "#eeffff", color = NA),
        plot.title = element_text(size = 20, face = 2, color = "#074949"),
        plot.caption = element_text(color = "#074949"),
        axis.title = element_text(color = "#074949")
    )+
    annotate(
        "text", label = "Imagine, I put 1 coin per game\nbetting against the odds",
        size = 5, color = "#074949", alpha = .85,
        x = 1, y = 72, hjust = 0, vjust = 1,
        family = "ah", lineheight = .9, fontface = 2
    )+
    annotate(
        "text", label = "I start with a 0 net balance, and every game it reduces by one coin... unless a real surprise happens and my balance increases as I win the unlikely bet" %>% str_wrap(42),
        size = 3.2, color = "#074949", alpha = .85,
        x = 1, y = 54, hjust = 0, vjust = 1,
        family = "ah", lineheight = .9
    )+
    annotate(
        "text", label = "If I'm above the zero line that means I'm in a net profit, benefiting from betting at the least likely outcomes" %>% str_wrap(34),
        size = 3.4, color = "#074949", alpha = .75,
        x = 1, y = -12, hjust = 0, vjust = 1,
        family = "ah", lineheight = .9
    )+
    annotate(
        "label", label = "It seems that the World Cup 2022 in Qatar was really exceptional" %>% str_wrap(33),
        size = 5, color = "#269292", fill = "#dfff00", alpha = .85,
        x = 64, y = -32, hjust = 1, vjust = 0,
        family = "ah", lineheight = .9, fontface = 2
    )+
    annotate(
        "text", label = "Play-offs",
        size = 5, color = "#269292", alpha = .85,
        x = 56, y = 72, hjust = 0.5, vjust = 1,
        family = "ah", lineheight = .9, fontface = 2
    )

set.seed(911)
ggsave("inst/figures/world-cup-odds-since-2010.pdf",
       width = 6.4, height = 5,
       bg = "#eeffff")


