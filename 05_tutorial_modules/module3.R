module3_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "module3_tab",
          selectInput(inputId = ns("selected_number"), label = "Choose Numbers", choices = -1:-100, selected = NULL, multiple = T),
          actionButton(inputId = ns("submit"), label = "Submit"),
          uiOutput(ns("number"))
  )
}

module3_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      ns <- session$ns
      
      number <- eventReactive(input$submit, 
                              log(as.double(input$selected_number))
      )
      
      
      output$number <- renderUI(
        p(paste("log = ", number()))
      )
      
      return(number)
      
    } # end module function
    
  ) # end module
  
} # end server