calendar_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "calendar")
}

calendar_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {}
    
  )
  
}