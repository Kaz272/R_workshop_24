module2_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "module2_tab",
          uiOutput(ns("statement_output")))
}

module2_server <- function(id, input_sum) {
  moduleServer(
    id,
    
    function(input, output, session) {

      
      statement <-
        reactive(
          h3(
            paste("The sum of values selected in Module 1 =", input_sum()
            )
          )
        )
      
      output$statement_output <- renderUI(statement())
    }
    
  )
  
}