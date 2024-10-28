library(ggimage)
library(rhandsontable)
library(reactable)
library(timevis)
library(shiny)
options(dplyr.summarise.inform = FALSE)
library(bs4Dash)
library(tidyverse)
library(here)
library(shinyWidgets)
library(DT)
library(magrittr)
# also need data.table

# Read in Data ---------------------
## using data.table::fread because it's very fast

team_stats <- data.table::fread(here("01_data","table","clean","clean_team_stats.csv"))

wins_losses_by_team <- data.table::fread(here("01_data","table","clean", "wins_losses_by_team.csv"))

recent_games <- data.table::fread(here("01_data","table","clean", "clean_recent_games.csv"))

news <- data.table::fread(here(... = "01_data", "table", "raw","latest_news.csv")) %>%
  mutate(news_image_filepath = str_remove(news_image_filepath, "C:/Users/Maxin/OneDrive/Documents/programming/R_workshop/01_data/image/"))

theme_set(theme_minimal())

team_conference_xwalk <- data.table::fread(here(... = "01_data", "table", "clean","team_meta.csv"))

schedule_data <-  data.table::fread(here("01_data", "table", "raw", "wnba_season_schedule_2024.csv")) 

player_stats <- data.table::fread(here(... = "01_data", "table", "raw","athlete_full.csv"))

