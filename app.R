tictoc::toc()
source(here::here("02_source", "utility.R"))
source(here::here("02_source", "crud_modules.R"))
source(here::here("02_source", "calendar_modules.R"))
source(here::here("02_source", "dashboard_modules.R"))

# UI ====================================

## Header --------------------------------
header <- dashboardHeader(title = "WNBA Dashboard")

## Sidebar -------------------------------
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(text = "Dashboard",icon = icon('chart-simple'),tabName = 'dashboard'),
    menuItem(text = "Calendar",icon = icon('calendar'),     tabName = 'calendar'),
    menuItem(text = "Manage Data",icon = icon('wrench'),    tabName = 'crud')
  )
)

## Body ----------------------------------
body <- dashboardBody(
  tabItems(
    ### Calling module UI functions ----------------------------
    dashboard_ui("dashboard"),
    calendar_ui("calendar"),
    crud_ui("crud")
  )
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
  dashboard_server("dashboard")
  calendar_server("calendar")
  crud_server("crud")
  
  print(session$user)
  
  ## Menu -----------------------
  output$menu <- renderMenu({
    
  })
  
}

shinyApp(ui, server)

