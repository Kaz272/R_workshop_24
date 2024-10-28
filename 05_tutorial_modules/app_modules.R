tictoc::toc()
library(shinydashboard)

source(here::here("05_tutorial_modules", "module1.R"))
source(here::here("05_tutorial_modules", "module2.R"))
source(here::here("05_tutorial_modules", "module3.R"))

# UI ====================================

## Header --------------------------------
header <- dashboardHeader(title = "Company Dashboard")


## Sidebar -------------------------------
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(text = "Module 1",tabName = 'module1_tab'),
    menuItem(text = "Module 2",tabName = 'module2_tab'),
    menuItem(text = "Module 3",tabName = 'module3_tab')
  )
  
)

## Body ----------------------------------
body <- dashboardBody(
  tabItems(
    ### Calling module UI functions ----------------------------
    module1_ui("module1"), #
    module2_ui("module2"), #
    module3_ui("module3")
  )#,
)

## UI Consolidated -----------------------
ui <- dashboardPage(
  ## calling UI components
  header = header,
  sidebar = sidebar,
  body = body
)

# Server ==================================
server <- function(input, output, session) {

  ## calling module server functions
 module1_output <-  module1_server(id = "module1")
 module2_server(id = "module2", input_sum = module1_output)
 module3_server(id = "module3")
}

shinyApp(ui, server)

