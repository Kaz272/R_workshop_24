dashboard_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "dashboard",
          fluidRow(
            valueBoxOutput(ns("value1")),
            valueBoxOutput(ns("value2")),
            valueBoxOutput(ns("value3"))
          ))
}

dashboard_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      output$value1 <- renderValueBox({
        valueBox(
          value = tags$p("90k", style = "font-size: 200%;"), "Approval", icon = icon("thumbs-up", lib = "glyphicon"),
          color = "warning"
        )
        })
      output$value2 <- renderValueBox({
        valueBox(value = "4", subtitle = "progress", icon("thumbs-up", lib = "glyphicon"), color = 'primary')
      })
      output$value3 <- renderValueBox({
        valueBox(value = "4", subtitle = "progress", icon("thumbs-up", lib = "glyphicon"), color = )
      })
      
    }
    
  )
  
}