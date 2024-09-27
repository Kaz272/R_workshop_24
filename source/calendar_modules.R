calendar_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "calendar",
          timevisOutput(ns("calendar")))
}

calendar_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      library(lubridate)
      df <- tibble(id = 1:5, 
                   content = str_c("event ", 1:5),
                   start = seq.Date(from = ymd(20240917),to =  ymd(20240921),by = "day")
      )
      library(timevis)
      
      output$calendar <- renderTimevis({
        timevis(
          df,
          options = list(
            editable = TRUE,
            onAdd = htmlwidgets::JS('function(item, callback) {
                    item.content = "Hello!" + item.content;
                    callback(item);}')
          )
        )
      })
      
    }
    
  )
  
}