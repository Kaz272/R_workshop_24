tictoc::tic()
library(tidyverse)
library(httr)
library(jsonlite)
library(here)
library(tidyjson)

# helper functions ------------------------
download_image <- function(id, url, category){
  file_type <- str_sub(url, -3,-1)
  file_name <- paste0(id, ".", file_type)
download.file(url, here(... = "www", category, file_name ), mode = "wb")
}

# teams to query ---------------------------
team_IDs<- c(3,5,6,8,9,11,14,16,17,18,19,20)

# Get team data -----------------------------
get_team_meta <- function(team_id){
response <- GET(paste0("http://sports.core.api.espn.com/v2/sports/basketball/leagues/wnba/seasons/2024/teams/", team_id, "?lang=en&region=us"))

team_list <- response$content %>% 
  rawToChar() %>% 
  fromJSON()

team_list$logos<-list(team_list$logos)
team_list$venue<-list(team_list$venue)
team_list$links<-list(team_list$links)

team_list %>% 
  as_tibble(.name_repair = 'unique') %>% 
  unnest(cols = 'logos', names_repair = 'unique', names_sep = "_") %>% 
  # unnest(cols = 'logos', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'logos_rel', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'ranks', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'statistics', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'leaders', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'links', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'links_rel', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'injuries', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'notes', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'awards', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'franchise', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'alternateIds', names_repair = 'unique', names_sep = "_") %>% 
  # unnest(cols = 'coaches', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'events', names_repair = 'unique', names_sep = "_")  %>% 
  unnest(cols = 'venue', names_repair = 'unique', names_sep = "_") %>% 
  # unnest(cols = 'venue', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'groups', names_repair = 'unique', names_sep = "_") %>% 
  unnest(cols = 'record', names_repair = 'unique', names_sep = "_") %>% 
  mutate(venue_fullname = venue$fullName,
         venue_state = venue$address$state,
         venue_city = venue$address$city,
         venue_image = venue$image) %>% 
  select(-venue)

}

team_meta <- team_IDs %>% 
  purrr::map_dfr(get_team_meta) %>% 
  distinct_all() 

## team-conference reference table ----------------------------
#team_conference_xwalk <- 
  team_meta %>% 
  distinct(id, displayName) %>% 
  arrange(as.double(id)) %>% 
  mutate(conference = c("Western Conference", 
                        "Eastern Conference",
                        "Western Conference", 
                        "Western Conference", 
                        "Eastern Conference",
                        "Western Conference",
                        "Western Conference",
                        "Eastern Conference",
                        "Western Conference", 
                        "Eastern Conference",
                        "Eastern Conference",
                        "Eastern Conference")) %>% 
  data.table::fwrite(here(... = "01_data", "table", "clean","team_conference_xwalk.csv"))

# download team logos
team_meta %>% 
  select(id, url = logos_href) %>% 
  mutate(category = "team") %>% 
  mutate(dark = str_detect(url, '-dark')) %>% 
  distinct_all() %>% 
  filter(!dark) %>% 
  select(-dark) %>% 
  purrr::pwalk(download_image)

logo_filepaths <- 
  list.files(here(... = "www","team"), full.names = T) %>% 
  as_tibble() %>% 
  mutate(id = str_remove(value, "(.*)team/"),
         id = str_remove(id, "\\.png")) %>% 
  rename(team_logo_filename = value) 
  
team_meta_final <- team_meta %>% 
  # select(-team_logo_filename) %>% 
  left_join(logo_filepaths) %>% 
  select(-where(is_list))

team_meta_final %>%
  data.table::fwrite(here(... = "01_data", "table", "raw","team_meta.csv"))



# get team stats ---------------------------
get_team_stats <- function(team_id=3){
  
response <- GET(paste0("http://sports.core.api.espn.com/v2/sports/basketball/leagues/wnba/seasons/2024/types/2/teams/", team_id ,"/statistics?lang=en&region=us"))

stats_list <- response$content %>% rawToChar() %>% fromJSON()

defensive_stats <- stats_list$splits$categories$stats [[1]] %>% mutate(categories = 'Defensive')
general_stats <- stats_list$splits$categories$stats [[2]] %>% mutate(categories = 'General')
offensive_stats <- stats_list$splits$categories$stats [[3]] %>% mutate(categories = 'Offensive')

level1 <- 
  response$content %>% 
  rawToChar() %>% 
  spread_all %>% 
  mutate(join_col = "1") %>% 
  janitor::clean_names()

bind_rows(defensive_stats, general_stats, offensive_stats) %>% 
  as_tibble() %>%
  mutate(team_id = team_id, join_col = "1") %>% 
  left_join(level1)
}

all_team_stats <- team_IDs %>% purrr::map_dfr(get_team_stats) %>% select(-where(is_list))
all_team_stats %>% data.table::fwrite(here(... = "01_data", "table", "raw","team_stats.csv"))

# get team injuries -------------------------
get_athlete_injuries <- function(api_call){
response <- GET(paste0(api_call))
injury_list <- response$content %>% 
  rawToChar() %>% 
  fromJSON()

date <- injury_list$date
status <- injury_list$status
side <- injury_list$details$side
type <- injury_list$details$type
return_date <- injury_list$details$returnDate
athlete_id <- api_call %>% 
  str_remove("http://sports.core.api.espn.com/v2/sports/basketball/leagues/wnba/seasons/2024/athletes/") %>% 
  str_remove("/injuries/(.*)")

return(tibble(athlete_id = athlete_id, 
              date = date, 
              status = status, 
              side = side, 
              type = type, 
              return_date = return_date))
}

get_team_injuries <- function(team_id=3){
  
  response <- GET(paste0("http://sports.core.api.espn.com/v2/sports/basketball/leagues/wnba/teams/", team_id ,"/injuries?lang=en&region=us"))
  injury_list <- response$content %>% 
    rawToChar() %>% 
    fromJSON()

  injury_list$items <- list(injury_list$items)
  
  injury_list_tbl <- injury_list %>% 
    as_tibble(.name_repair = 'unique') %>% 
    unnest(cols = 'items', names_repair = 'unique', names_sep = "_")
  
  if(!is_null(injury_list_tbl$`items_$ref`)){
  athlete_injury_api <- injury_list_tbl$`items_$ref`
  
  injury_by_athlete <- 
    athlete_injury_api %>% 
    purrr::map_dfr(get_athlete_injuries)
  
  return(injury_by_athlete)
}
}  

injuries_by_athlete <- team_IDs %>% purrr::map_dfr(get_team_injuries)

injuries_by_athlete %>% data.table::fwrite(here(... = "01_data", "table", "raw","athlete_injury.csv"))



# Athlete Data -----------------

## First get API endpoints for basic athlete data ----------
get_athlete_APIs <- function(){
  response <- GET("http://sports.core.api.espn.com/v2/sports/basketball/leagues/wnba/athletes?limit=1000")
  
  athlete_APIs <- response$content %>% 
    rawToChar() %>% 
    fromJSON() %>% 
    .$items %>% 
    .$`$ref`
  
  return(athlete_APIs)
}

## Get individual athlete stats ---------------------------
get_athlete_stats <- function(athlete_id=2529205){
  response <- GET(paste0("http://sports.core.api.espn.com/v2/sports/basketball/leagues/wnba/seasons/2024/types/3/athletes/",athlete_id,"/statistics/0?lang=en&region=us"))
  athlete_stats_list <- 
    response$content %>% 
    rawToChar() %>% 
    fromJSON()
  
  defensive_stats <- athlete_stats_list$splits$categories$stats[[1]] %>% as_tibble() %>% mutate(athlete_stats_category = "Defensive")
  offensive_stats <- athlete_stats_list$splits$categories$stats[[2]] %>% as_tibble() %>% mutate(athlete_stats_category = "General")
  general_stats <- athlete_stats_list$splits$categories$stats[[3]] %>% as_tibble() %>% mutate(athlete_stats_category = "Offensive")
  
  athlete_stats <- 
    bind_rows(defensive_stats,offensive_stats,general_stats) %>% 
    mutate(athlete_id = athlete_id)
  
  return(athlete_stats)
}

## Get athlete basic data ----------------------
get_athlete_data <- function(athlete_api){

response <- GET(athlete_api)
# response <- GET(athlete_APIs[1])
athlete_list <- 
response$content %>% 
  rawToChar() %>% 
  fromJSON()

athlete_tbl <- tibble(
  athlete_id = athlete_list$id,
  displayName = athlete_list$displayName,
  age = athlete_list$age,
  college = athlete_list$college$`$ref`,
  position_id = athlete_list$position$id,
  position_displayName = athlete_list$position$displayName,
  team = athlete_list$team$`$ref`,
  experience = athlete_list$experience$years,
  active = athlete_list$active,
  status = athlete_list$status$name,
  headshot = athlete_list$headshot$href
)

## call the function to get individual stats if the athlete is active
if(!is_null(athlete_list$statisticslog) & athlete_tbl$active){
  athlete_stats <-
    athlete_tbl$athlete_id %>%
    # 3917450 %>% 
    get_athlete_stats()
  
athlete_tbl <- athlete_tbl %>% 
    left_join(athlete_stats, by = 'athlete_id', relationship = "many-to-many")
return(athlete_tbl)

}
}

# get athlete api endpoints
athlete_APIs <- get_athlete_APIs()

# run those endpoints through the get_athlete_data function

all_athlete_data <- athlete_APIs %>% 
  purrr::map_dfr(get_athlete_data)


# download headshots 
all_athlete_data %>% 
  select(id = athlete_id, url = headshot) %>% 
  mutate(category = "athlete") %>% 
  distinct_all() %>% 
  filter(!is.na(url)) %>% 
  purrr::pwalk(download_image)

headshot_filepaths <- 
  list.files(here(... = "www","athlete"), full.names = T) %>% 
  as_tibble() %>% 
  mutate(athlete_id = str_remove(value, "(.*)athlete/"),
         athlete_id = str_remove(athlete_id, "\\.png|\\jpg"),
         athlete_id = as.double(athlete_id)) %>% 
  rename(player_headshot_filename = value) %>% 
  distinct(athlete_id, .keep_all = T)

all_athlete_data %>% 
  left_join(headshot_filepaths %>% mutate(athlete_id = as.character(athlete_id)), relationship = 'many-to-many') %>% 
  data.table::fwrite(here(... = "01_data", "table", "raw","athlete_full.csv"))


# Get news -------------------------------------
response <- GET("now.core.api.espn.com/v1/sports/news?limit=10&league=wnba")
news_list <- 
  response$content %>% 
  rawToChar() %>% 
  fromJSON()

news_list$headlines %>% 
  as_tibble(.name_repair = 'unique') %>% 
  unnest(cols = 'video', names_repair = 'unique', names_sep = "_")

id <- news_list$headlines$dataSourceIdentifier 
description <-news_list$headlines$description
news_link <- news_list$headlines$links$web$href
image_urls <- news_list$headlines$images 
titles <- news_list$headlines$title

image_urls_tbl <-
  purrr::map2_dfr(.x = image_urls, .y = id, ~mutate(.x, id=.y)) %>% 
  select(url, id) %>% 
  as_tibble

news_tbl <- tibble(id = id,
                   title = titles,
                   description = description, 
                   news_link = news_link) %>% 
  left_join(image_urls_tbl) %>% 
  mutate(category = 'news')

news_tbl %>% 
  select(id,url,category) %>% 
  filter(!is.na(url)) %>% 
  purrr::pwalk(download_image)


news_image_filepaths <- 
  list.files(here(... = "www","news"), full.names = T) %>% 
  as_tibble() %>% 
  mutate(id = str_remove(value, "(.*)news/"),
         id = str_remove(id, "\\.jpg")) %>% 
  rename(news_image_filepath = value) %>% 
  distinct(id, .keep_all = T) %>% 
  mutate(news_image_filepath = str_remove(news_image_filepath, "(.*)www/"))

news_tbl %>% 
  left_join(news_image_filepaths) %>% 
  filter(!is.na(title)) %>% 
  data.table::fwrite(here(... = "01_data", "table", "raw","latest_news.csv"))



# Get Calendar data -------

date_sequence <- 
seq.Date(from = ymd(20240401), 
         to = ymd(20241101),
         by = 'days') %>% 
  format(., "%Y%m%d") %>% 
  as.character()

get_schedule <- function(date){
response <- GET(paste0("http://site.api.espn.com/apis/site/v2/sports/basketball/wnba/scoreboard?dates=",date))
  
wnba_list <- response$content %>% 
  rawToChar() %>% 
  fromJSON()

# event_date <- 
dates <- wnba_list$events$date
shortName <- wnba_list$events$shortName
event_id <- wnba_list$events$id

schedule <-
wnba_list$events %>% 
  as_tibble(.name_repair = 'unique') %>% 
  unnest(cols = 'competitions', names_repair = 'unique', names_sep = '_') #%>% 
  # unnest(cols = 'competitions_venue', names_repair = 'unique', names_sep = '_') %>% 
  # unnest(cols = 'competitions_venue_address', names_repair = 'unique', names_sep = '_') %>% 
  # unnest(cols = 'competitions_competitors', names_repair = 'unique', names_sep = '_') %>%
  # unnest(cols = 'competitions_broadcasts', names_repair = 'unique', names_sep = '_') %>%
  # # unnest(cols = 'competitions_broadcasts_names', names_repair = 'unique', names_sep = '_') %>% 
  # select(id, date, shortName, 
  #        competitions_recent,
  #        competitions_venue_address_city,
  #        competitions_venue_address_state,
  #        competitions_competitors_score#, 
  #        # competitions_broadcasts_names
  #        )
  # mutate(venue_city = venue$address$city)

return(schedule)

}

response <- GET(paste0("http://site.api.espn.com/apis/site/v2/sports/basketball/wnba/scoreboard"))

wnba_list <- response$content %>% 
  rawToChar() %>% 
  fromJSON()

dates_in_2024_season <- wnba_list$leagues$calendar %>% unlist() %>% str_remove_all(.,"T(.*)|\\-")

season_schedule <- dates_in_2024_season %>% 
  purrr::map_dfr(get_schedule) %>% 
  distinct_all()

season_schedule_trimmed <-
  season_schedule %>% 
  unnest(cols = 'competitions_competitors', names_repair = 'unique', names_sep = '_') %>% 
  unnest(cols = 'competitions_venue', names_repair = 'unique', names_sep = '_') %>% 
    unnest(cols = 'competitions_venue_address', names_repair = 'unique', names_sep = '_') %>% 
  unnest(cols = 'competitions_competitors_leaders', names_repair = 'unique', names_sep = '_') %>%
    unnest(cols = 'competitions_competitors_leaders_leaders', names_repair = 'unique', names_sep = '_') %>% 
    unnest(cols = 'competitions_competitors_leaders_leaders_athlete', names_repair = 'unique', names_sep = '_') %>% 
    unnest(cols = 'competitions_competitors_leaders_leaders_team', names_repair = 'unique', names_sep = '_') %>%  
    unnest(cols = 'competitions_competitors_leaders_leaders_athlete_team', names_repair = 'unique', names_sep = '_') %>% 
    unnest(cols = 'competitions_competitors_statistics', names_repair = 'unique', names_sep = '_') %>% 
  select(id, date, shortName,
         team_id = competitions_competitors_id,
         team_score = competitions_competitors_score,
         broadcast = competitions_broadcast,
         city = competitions_venue_address_city,
         state = competitions_venue_address_state,
         game_stat_display_name = competitions_competitors_statistics_abbreviation,
         game_stat_name = competitions_competitors_statistics_name,      
         game_stat_value = competitions_competitors_statistics_displayValue,
         leader_team_id = competitions_competitors_leaders_leaders_team_id,
         leader_stat_name = competitions_competitors_leaders_displayName,
         leader_stat_value = competitions_competitors_leaders_leaders_value,
         leader_id = competitions_competitors_leaders_leaders_athlete_id,
         leader_display_name = competitions_competitors_leaders_leaders_athlete_displayName
         ) %>% 
  left_join(logo_filepaths %>% 
              mutate(id = as.character(id)), 
            by = c("team_id"  = "id")) %>% 
  left_join(team_meta %>%
              distinct(id, displayName),
            by = c("team_id" = "id"))

season_schedule_trimmed %>% data.table::fwrite(here("01_data", "table", "raw", "wnba_season_schedule_2024.csv"))

# response <- GET(paste0("http://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard"))#,date))
# 
# nba_list <- response$content %>% 
#   rawToChar() %>% 
#   fromJSON()
# 
# mens_dates_in_2024_season <- nba_list$leagues$calendar %>% unlist() %>% str_remove_all(.,"T(.*)|\\-")
# mens_season_schedule <- mens_dates_in_2024_season %>% 
#   purrr::map_dfr(get_schedule) %>% 
#   distinct_all()
# 





# cleaning data ------------------------------------------

## team_stats ------------------------------------------
# team_stats <- read_csv(here("01_data", "table","raw", "team_stats.csv"))
# team_meta <- read_csv(here("01_data", "table","raw", "team_meta.csv"))

raw_teams_full <- team_meta_final %>% 
  left_join(all_team_stats %>% mutate(team_id = as.character(team_id)), by = c('id' = 'team_id'), relationship = 'many-to-many') %>% 
  select(team_id = id, team_name = displayName.x,
         color,team_logo_filename,
         stat_name = name.y,
         stat_display_name = displayName.y,
         stat_desc= description,
         stat_value = value,
         stat_rank = rank, categories, 
         stat_rank_display =rankDisplayValue ) %>% 
  distinct_all() %>% 
  mutate(color_hex = str_c("#", color)) %>% 
  mutate(team_logo_filename = str_remove(team_logo_filename, "C:/Users/Maxin/OneDrive/Documents/programming/R_workshop/")) %>% 
  filter(stat_name != "rebounds")


clean_team_stats <- 
  raw_teams_full %>% 
  filter(stat_display_name %in% c('Points', 
                                  'Field Goal Percentage',
                                  'Free Throw Percentage',
                                  'Rebounds', 
                                  'Blocks', 
                                  'Steals', 
                                  # 'Games Played', 
                                  'Points Per Game')) %>%
  group_by(team_id) %>% 
  mutate(team_rank = stat_rank[stat_display_name=="Points"]) %>% 
  ungroup()

clean_team_stats %>% data.table::fwrite(here("01_data","table","clean", "clean_team_stats.csv"))


## recent games -----------------------------------
# raw_schedule <- read_csv(here("01_data", "table", "raw", "wnba_season_schedule_2024.csv"))

recent_games <-
  season_schedule_trimmed %>% 
  filter(date < today() & date > today()-6) %>% 
  group_by(id) %>% 
  mutate(winner = max(team_score )==team_score) %>% 
  ungroup() 

recent_games %>% data.table::fwrite(here("01_data","table","clean", "clean_recent_games.csv"))

upcoming_games <-
  season_schedule_trimmed %>% 
  filter(date > today() & date < today()+6)  %>% 
  left_join(raw_teams_full %>%
              distinct(team_id, team_name))


upcoming_games %>% data.table::fwrite(here("01_data","table","clean", "clean_upcoming_games.csv"))

## total wins and losses by team ----------------------------
wins_losses_by_team <- season_schedule_trimmed %>% 
  filter(date < today()) %>% 
  group_by(id) %>% 
  mutate(winner = max(team_score )==team_score) %>% 
  ungroup()  %>% 
  left_join(raw_teams_full %>%
              distinct(team_id, team_name) ) %>% 
  count(team_name, winner)

wins_losses_by_team %>% data.table::fwrite(here("01_data","table","clean", "wins_losses_by_team.csv"))

tictoc::toc()



