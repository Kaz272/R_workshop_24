#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(bslib)

example_theme <- bs_theme(
  # Controls the default grayscale palette
  bg = "#202123", fg = "#B8BCC2",
  # Controls the accent (e.g., hyperlink, button, etc) colors
  primary = "#EA80FC", secondary = "#48DAC6",
  base_font = c("Grandstander", "sans-serif"),
  code_font = c("Courier", "monospace"),
  heading_font = "'Helvetica Neue', Helvetica, sans-serif",
  # Can also add lower-level customization
  "input-border-color" = "#EA80FC"
)

# Define UI for application that draws a histogram
ui <- navbarPage( 
  "App Title",   
  theme = example_theme,
  tabPanel("panel 1", 
           fluidPage(
             h1("Header 1"),
             h2("Header 2"),
             h3("Header 3"),
             h4("Header 4"),
             h5("Header 5"),
             h6("Header 6"),
             p("regular text")
           )
  ),
  tabPanel("panel 2", ... = "two"),
  tabPanel("panel 3", ... = "three"),
  navbarMenu("subpanels", 
             tabPanel("panel 4a", "four-a"),
             tabPanel("panel 4b", "four-b"),
             tabPanel("panel 4c", "four-c")
  )
)
  
  
# Define server logic required to draw a histogram
server <- function(input, output) {
  
}

# Run the application 
shinyApp(ui = ui, server = server)
