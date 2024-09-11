dashboard_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "dashboard")
}

dashboard_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {}
    
  )
  
}