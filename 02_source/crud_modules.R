library(rhandsontable)
crud_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "crud")
}

crud_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      schedule_data <-  
        data.table::fread(
          here("01_data", "table", "raw", "wnba_season_schedule_2024.csv"),
          colClasses = c("integer",
                         "character",
                         "character",
                         "integer",
                         "integer",
                         "character",
                         "character",
                         "character",
                         "character",
                         "character",
                         "double",
                         "integer",
                         "character",
                         "double",
                         "integer",
                         "character",
                         "character",
                         "character")) 
      
      schedule_data_modified <-
      schedule_data %>% as_tibble() %>% 
        distinct(id, date, shortName, displayName, broadcast, city, state) %>%
        mutate(city_state = paste0(city,", ", state)) %>% 
        mutate(date = format(ymd_hm(date), "%Y-%m-%d")) %>% 
        group_by(id) %>%
        ungroup() %>% 
        mutate(competition_team_index = paste0("Team ", row_number())) %>% 
        mutate_at(c("city", "state", "displayName"),
                  .funs = ~factor(., levels = sort(unique(.)))) %>% 
        pivot_wider(#id_cols = c("id", "date", "shortName", "broadcast", "city", "state"), 
                    names_from = "competition_team_index", 
                    values_from = "displayName") %>% 
        select(Date = date, Game = shortName, Location = city_state, `Team 1`, `Team 2`)
        # summarize(date = date[1], 
        #          shortName = shortName[1],
        #          displayName = paste(displayName[1], displayName[2], collapse = "vs"),
        #          city = city[1], 
        #          state = state[1]) %>% 
      
      v <- reactiveValues(schedule = schedule_data)
    # v <- list(schedule = schedule_data_modified) # for trouble shooting, use this line.
      
      
      
      # output$rhandsontable <- 
        rhandsontable(v$schedule) 
      
    }
    
  )
  
}