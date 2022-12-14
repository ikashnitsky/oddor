% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/odds_match_outcome.R
\name{odds_match_outcome}
\alias{odds_match_outcome}
\title{A simple function to determine the outcome of a match}
\usage{
odds_match_outcome(score_string)
}
\arguments{
\item{score_string}{a text input from the score column of the \code{oddsportal} dataset}
}
\description{
The function takes \code{oddsportal} score sting of the type "2:1" and parses it into the goals the outcome variable: eaither "home", "away", or "draw".
}
