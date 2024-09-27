library(tidyverse)
# library(ffscrapr)
library(httr)
library(jsonlite)
# library(glue)
library(here)
library(tidyjson)

# helper functions ------------------------
download_image <- function(id, url, category){
  file_type <- str_sub(url, -3,-1)
  file_name <- paste0(id, ".", file_type)
download.file(url, here(... = "01_data", "image", category, file_name ), mode = "wb")
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

team_meta <- team_IDs %>% purrr::map_dfr(get_team_meta) %>% distinct_all()

team_meta %>% write_csv(here(... = "01_data", "table", "team_meta.csv"))

# download team logos
team_meta %>% 
  select(id, url = logos_href) %>% 
  mutate(category = "team") %>% 
  mutate(dark = str_detect(url, '-dark')) %>% 
  distinct_all() %>% 
  filter(!dark) %>% 
  select(-dark) %>% 
  purrr::pwalk(download_image)



# get team stats ---------------------------
get_team_stats <- function(team_id=3){
  
response <- GET(paste0("http://sports.core.api.espn.com/v2/sports/basketball/leagues/wnba/seasons/2024/types/2/teams/", team_id ,"/statistics?lang=en&region=us"))
stats_content <- response$content %>% 
  rawToChar()

level1 <- 
  response$content %>% 
  rawToChar() %>% 
  spread_all %>% 
  mutate(join_col = "1") %>% 
  janitor::clean_names()

stats_list <- response$content %>% rawToChar() %>% fromJSON()

defensive_stats <- stats_list$splits$categories$stats [[1]] %>% mutate(categories = 'Defensive')
general_stats <- stats_list$splits$categories$stats [[2]] %>% mutate(categories = 'General')
offensive_stats <- stats_list$splits$categories$stats [[3]] %>% mutate(categories = 'Offensive')
  
bind_rows(defensive_stats, general_stats, offensive_stats) %>% 
  as_tibble() %>%
  mutate(team_id = team_id, join_col = "1") %>% 
  left_join(level1)
}

all_team_stats <- team_IDs %>% purrr::map_dfr(get_team_stats)
all_team_stats %>% write_csv(here(... = "01_data", "table", "team_stats.csv"))

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

injuries_by_athlete %>% write_csv(here(... = "01_data", "table", "athlete_injury.csv"))



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

# write to csv
all_athlete_data %>% write_csv(here(... = "01_data", "table", "athlete_full.csv"))

# download headshots 
all_athlete_data %>% 
  select(id = athlete_id, url = headshot) %>% 
  mutate(category = "athlete") %>% 
  distinct_all() %>% 
  filter(!is.na(url)) %>% 
  purrr::pwalk(download_image)

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

image_urls_tbl <-
  purrr::map2_dfr(.x = image_urls, .y = id, ~mutate(.x, id=.y)) %>% 
  select(url, id) %>% 
  as_tibble

news_tbl <- tibble(id = id,
                   description = description, 
                   news_link = news_link) %>% 
  left_join(image_urls_tbl) %>% 
  mutate(category = 'news')

news_tbl %>% 
  select(id,url,category) %>% 
  purrr::pwalk(download_image)



