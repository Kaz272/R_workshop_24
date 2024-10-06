library(reactable)
library(timevis)
library(ggmap)
calendar_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "calendar",
          fluidRow(
            timevisOutput(ns("calendar"), width = "100%"),
            box(width = 6,
                uiOutput(ns("game_details"))
            )
          )
  )
}

calendar_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      ns <- session$ns
      
      # Read Data ---------------
      schedule_data <- 
        data.table::fread(here("01_data", "table", "raw", "wnba_season_schedule_2024.csv"))
      
      # Prep Data ---------------
      schedule_for_timevis <-
        schedule_data %>% 
        select(id, start = date, content = shortName) %>% 
        distinct(id, .keep_all = T) %>%
        mutate(
          start = str_replace_all(start, "T|Z", " "),
          type = NA
        )
      
      message("finished reading and prepping schedule data")
      
      # Build calendar --------------------
      output$calendar <- renderTimevis({
        timevis(
          schedule_for_timevis,
          timezone = -4
        ) %>% 
          setWindow(as.Date("09/25/2024", "%m/%d/%Y"),as.Date("10/11/2024", "%m/%d/%Y"))
      })
      
      # React to calendar selection -----------------
      selected_game_details <- reactive({
        req(input$calendar_selected)
        message("calendar item selected")
        game_data <- schedule_data %>%
          filter(id == input$calendar_selected)%>%
          select(date, broadcast, shortName,city, state, team_id, game_stat_value, game_stat_display_name, team_score) %>% 
          distinct(team_id, game_stat_display_name, .keep_all = T) %>% 
          mutate(is_score = game_stat_display_name == 'PTS') %>% 
          arrange(desc(is_score)) %>% 
          left_join(team_conference_xwalk %>% rename(team_id = id, team_name = displayName))
        
        full_name <- paste(unique(game_data$team_name), collapse = ' vs ')
        date <- (ymd_hm(game_data$date[1])-hours(4)) %>% format("%A, %B %d, %Y, %H:%m") %>% paste0(., " EST")
        location <- paste0(game_data$city[1], ", ", game_data$state[1])
        broadcasting_on <-  game_data$broadcast[1]
        future_game <- ifelse(ymd_hm(game_data$date[1])>ymd(20241005),"Historical Team Stats", "Game Stats")
        
        game_stats <-
          game_data %>%
          select(team_id, game_stat_value, game_stat_display_name, team_score) %>% 
          distinct(team_id, game_stat_display_name, .keep_all = T) %>% 
          mutate(is_score = game_stat_display_name == 'PTS') %>% 
          arrange(desc(is_score)) %>% 
          left_join(team_conference_xwalk %>% rename(team_id = id, team_name = displayName)) %>% 
          select(team_name, Stat = game_stat_display_name, game_stat_value ) %>% 
          pivot_wider( names_from = 'team_name', values_from = 'game_stat_value') %>% 
          reactable::reactable(width = '100%',pagination = F)
        
        return(list(full_name = full_name, 
                    date = date, 
                    location = location, 
                    broadcasting_on = broadcasting_on, 
                    game_stats = game_stats, 
                    future_game = future_game))
      })
      
      # Define function to build game stats UI --------------------
      create_game_details_ui <- function(full_name, date,location, broadcasting_on,game_stats, future_game){
        tagList(
          h2(full_name),
          h4(date),
          h4(location),
          h5(broadcasting_on),
          h4(future_game),
          game_stats
        )
      }
      
      # Build game stats UI
      output$game_details <- renderUI({
        create_game_details_ui(selected_game_details()$full_name, 
                               selected_game_details()$date, 
                               selected_game_details()$location,
                               selected_game_details()$broadcasting_on,
                               selected_game_details()$game_stats,
                               selected_game_details()$future_game)
      })
      
    } # end module function
  ) # end module
} # end server