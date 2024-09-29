library(ggimage)
# library(fresh)
# library(here)
# library(dplyr)
# library(tidyr)
# library(readr)
# library(stringr)
# library(odbc)
# library(DBI)
# library(pins)
# library(markdown)
# library(rsconnect)
# library(shinyjs)
# library(shinyWidgets)
library(shiny)
# library(bs4Dash)
# library(reactablefmtr)
# library(DT)
# library(shinyBS)
# library(rhandsontable)
### Also load these: ####
# library(mailR)
# library(shinycssloaders)
options(dplyr.summarise.inform = FALSE)
# dbDisconnect(con)
# library(shinydashboardPlus)
library(shinydashboard)
library(tidyverse)
library(here)
library(shinyWidgets)

# tictoc::tic()
# team_stats <- read_csv(here("01_data","table","clean","clean_team_stats.csv"))
# wins_losses_by_team <- read_csv(here("01_data","table","clean", "wins_losses_by_team.csv"))
# recent_games <- read_csv(here("01_data","table","clean", "clean_recent_games.csv"))
# news <- read_csv(here(... = "01_data", "table", "raw","latest_news.csv")) %>%
#   mutate(news_image_filepath = str_remove(news_image_filepath, "C:/Users/Maxin/OneDrive/Documents/programming/R_workshop/01_data/image/"))
# theme_set(theme_minimal())
# tictoc::toc()


# Read in Data ---------------------
## using data.table::fread because it's very fast: <0.1 second rather then 4.5 seconds with read_csv
tictoc::tic()
team_stats <- data.table::fread(here("01_data","table","clean","clean_team_stats.csv"))
wins_losses_by_team <- data.table::fread(here("01_data","table","clean", "wins_losses_by_team.csv"))
recent_games <- data.table::fread(here("01_data","table","clean", "clean_recent_games.csv"))
news <- data.table::fread(here(... = "01_data", "table", "raw","latest_news.csv")) %>%
  mutate(news_image_filepath = str_remove(news_image_filepath, "C:/Users/Maxin/OneDrive/Documents/programming/R_workshop/01_data/image/"))
theme_set(theme_minimal())
tictoc::toc()

# tictoc::tic()
# data_to_plot %>% 
#   ggplot(aes(x = fct_reorder(team_name,stat_value), y = stat_value)) + 
#   geom_col(aes(fill = team_name)) + 
#   # geom_image(aes(y = 0, image=team_logo_filename), size = 0.1) + 
#   # geom_text(aes(y = stat_value + y_offset_for_images, label = round(stat_value, 0))) + 
#   # scale_x_discrete(labels = str_c(unique(data_to_plot$team_name), "<img src='",unique(data_to_plot$team_logo_filename),"' height=25 />")) + 
#   theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0)) + 
#   scale_fill_manual(values =unique(data_to_plot$color_hex) ) + 
#   labs(title = data_to_plot$stat_display_name[1], 
#        x = element_blank()) +
#   theme(legend.position = 'none',
#         axis.text.x = ggtext::element_markdown()) 
# tictoc::toc()


