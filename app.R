tictoc::toc()
source(here::here("source", "utility.R"))
source(here::here("source", "crud_modules.R"))
source(here::here("source", "calendar_modules.R"))
source(here::here("source", "dashboard_modules.R"))

# UI ====================================

## Header --------------------------------
header <- dashboardHeader(h1(HTML("Company Dashboard")),
                          sidebarIcon = NULL)


## Sidebar -------------------------------
sidebar <- dashboardSidebar(
  collapsed=FALSE,
  minified=FALSE,
  expandOnHover = TRUE,
  div(style='top:10px;  margin-left: auto; margin-right: auto;  width: 50%;',
      p(img(src='logo.png',
            height=125,width=125)
      )
  ),
  sidebarMenu(
    menuItem(text = "Dashboard",icon = icon('chart-simple'),tabName = 'dashboard'),
    menuItem(text = "Calendar",icon = icon('calendar'),     tabName = 'calendar'),
    menuItem(text = "Manage Data",icon = icon('wrench'),    tabName = 'dashboard')
  )
  
)

shinyjs::useShinyjs()

## Body ----------------------------------
body <- dashboardBody(
  
  
  
  tabItems(
    ### Page Modules ----------------------------
    crud_ui("crud"),
    dashboard_ui("dashboard"),
    calendar_ui("calendar")
  )#,
  
)

## UI Consolidated -----------------------
ui <- dashboardPage(
  skin = 'red',dark = NULL,help = NULL,
  ## calling UI components
  header = header,
  sidebar = sidebar, 
  body = body
)


# Server ==================================
server <- function(input, output, session) {
  
  dashboard_server("dashboard")
  crud_server("crud")
  calendar_server("calendar")
  
  ## Menu -----------------------
  output$menu <- renderMenu({
    
  })
  
}

shinyApp(ui, server)