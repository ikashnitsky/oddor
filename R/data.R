# Data --------------------------------------------------------------------

#' FIFA World Cups
#'
#' Resulrs of FIFA World Cups 2006, 2010, 2014, 2018, and 2022
#'
#' @format
#'   A tibble with 303 rows and 13 variables:
#'   \describe{
#'     \item{tournament}{The name of the tournament.}
#'     \item{year}{Year of tournament.}
#'     \item{stage}{Stage at which the game was played: Group, or Play-offs. Qualification games are not inqluded in the dataset.}
#'     \item{home}{Team playing at home.}
#'     \item{away}{Team playing away.}
#'     \item{goals_home}{Number of goals scored by the team playing at home.}
#'     \item{goals_away}{Number of goals scored by the team playing away.}
#'     \item{et_or_pen}{For the Play-off stage games that ended witha  draw in main time, an indication whether the game spanned into extra time ("et") or whether it ended with a series of penalty shots ("pen")}
#'     \item{outcome}{The outcome of the game: "home", "draw", or "away".}
#'     \item{odds_home}{Odds for the win of the team playing at home in the main time.}
#'     \item{odds_draw}{Odds for a draw in main time.}
#'     \item{odds_away}{Odds for the win of the team playing away in the main time.}
#'     \item{odds_win}{The odds associated with the outcome of the game.}
#'   }
#'
#' @source
#'   oddsportal, (n.d.). [Portal]. Retrieved 2022-12-09, from https://www.oddsportal.com
#'   \url{https://www.oddsportal.com/soccer/world/world-cup-2022/results/}
#'
#' @examples
#'
#' \dontrun{
#' library(tidyverse)
#' library(oddor)
#'soccer_world_cup %>%
#' filter(year == "2022", stage == "Group") %>%
#'     rowwise() %>%
#'     mutate(my_bet = max(odds_home, odds_draw, odds_away)) %>%
#'     ungroup() %>%
#'     mutate(
#'         #' THE LOGIC: whenever I lose the bet, I just lose 1 coin
#'         #' whenever my unlikely bet works, I receive the odds amount
#'         #' minus my initially risked coin
#'         bet_result = case_when(
#'             my_bet == odds_win ~ my_bet - 1,
#'             TRUE ~ -1
#'         )
#'     ) %>%
#'     group_by(year, stage) %>%
#'     mutate(id = {n() - seq_along(year)}+1) %>%
#'     arrange(year, stage, id) %>%
#'     mutate(
#'         balance = bet_result %>% cumsum()
#'     ) %>%
#'     ungroup() %>%
#'     ggplot(aes(id, balance, color = year))+
#'     geom_hline(yintercept = c(0), size = .5, color = 2)+
#'     geom_step(size = 1, alpha = .5)+
#'     geom_point(data = . %>% filter(my_bet == odds_win))+
#'     geom_text_repel(
#'         data = . %>% filter(year == "2022", my_bet == odds_win),
#'         aes(label = paste(home, goals_home, ":", goals_away, away)),
#'         size = 2.7, color = "#444444", hjust = 1, fontface = 2
#'     )+
#'     scale_x_continuous(breaks = c(seq(0, 40, 10),48), position = "top")+
#'     scale_y_continuous(position = "right")+
#'     scale_color_viridis_d(option = "F", begin = .1, end = .7, direction = -1)+
#'     labs(
#'         x = "All the group-stage games of FIFA World Cups, ordered chronologically",
#'         y = "Net balance",
#'         title = "Were there too many sensations in Qatar?",
#'         caption = "Data: oddsportal.com // Design: @ikashnitsky@fosstodon.org"
#'     )+
#'     theme_minimal(base_family = "ah")+
#'     theme(
#'         panel.grid.minor = element_blank(),
#'         legend.position = "bottom",
#'         plot.background = element_rect(fill = "#dadada", color = NA),
#'         plot.title = element_text(size = 22, face = 2, color = "#444444")
#'     )

#' }
"soccer_world_cup"

