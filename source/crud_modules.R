crud_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "crud")
}

crud_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {}
    
  )
  
}