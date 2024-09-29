library(lubridate)
library(timevis)
calendar_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "calendar",
          # timevisOutput(ns("calendar")),
          timevisOutput(ns("calendar"), width = "75%"),
          box(width = 3, title = "Game Details",
              uiOutput(ns("game_details"))
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
          # id = row_number(),
          start = str_replace_all(start, "T|Z", " ")
          # start = str_remove(start, "T(.*)")#,
          # start = ymd(start)#,
          # type = 'point'
          )# %>% 
        # bind_rows(tibble(id = 1, content = '2024 Season', start = "20240504", end = "20241008"))#, type = 'background'))
        
      output$calendar <- renderTimevis({
        timevis(
          schedule_for_timevis,
          timezone = -4
        ) %>% 
          setWindow(Sys.Date()-13,Sys.Date()+6)
      })
      
      selected_game_details <- reactive({
        schedule_data %>% 
          filter(id == input$calendar_selected)
      })
      
    } # end module function
  ) # end module
} # end server