library(reactable)
library(timevis)
calendar_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "calendar",
          fluidRow(
            timevisOutput(ns("calendar"), width = "100%"),
            box(width = 3,
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
      
      df <- tibble(id = 1:5, 
                   content = str_c("event ", 1:5),
                   start = seq.Date(from = ymd(20240917),to =  ymd(20240921),by = "day")
      )
      
      schedule_data <- 
        data.table::fread(here("01_data", "table", "raw", "wnba_season_schedule_2024.csv")) 
      
      schedule_for_timevis <-
        schedule_data %>% 
        select(id, start = date, content = shortName) %>% 
        distinct(id, .keep_all = T) %>%
        mutate(
          start = str_replace_all(start, "T|Z", " "),
          type = NA
        )
      output$calendar <- renderTimevis({
        timevis(
          schedule_for_timevis,
          timezone = -4
        ) %>% 
          setWindow(Sys.Date()-13,Sys.Date()+6)
      })
      
      selected_game_details <- reactive({
        req(input$calendar_selected)
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
                    game_stats = game_stats))
      })
      
      create_game_details_ui <- function(full_name, date,location, broadcasting_on,game_stats){
        tagList(
          h2(full_name),
          h4(date),
          h4(location),
          h5(broadcasting_on),
          game_stats
        )
      }
      
      output$game_details <- renderUI({
        create_game_details_ui(selected_game_details()$full_name, 
                               selected_game_details()$date, 
                               selected_game_details()$location,
                               selected_game_details()$broadcasting_on,
                               selected_game_details()$game_stats)
      })
      
    } # end module function
  ) # end module
} # end server