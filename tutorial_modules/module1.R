module1_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "module1_tab",
          selectInput(inputId = ns("selected_number"), label = "Choose Numbers", choices = 1:100, selected = NULL, multiple = T),
          actionButton(inputId = ns("submit"), label = "Submit"),
          uiOutput(ns("number"))
  )
}

module1_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      ns <- session$ns
      
      # number <- reactive(
      #   sum(as.double(input$selected_number))
      # )
      
      number <- eventReactive(input$submit, {
        sum(as.double(input$selected_number))
      })
      
      
      output$number <- renderUI({
        p(paste("Sum = ", number()))
        })
      
      return(number)
      
    } # end module function
    
  ) # end module
  
} # end server