tictoc::toc()
source(here::here("source", "utility.R"))
source(here::here("source","study_modules.R"))
source(here::here("source","admin_modules.R"))
source(here::here("source","welcome_modules.R"))
source(here::here("source","about_modules.R"))
source(here::here("source","manage_data_module.R"))

# UI ====================================

## Header --------------------------------
header <- dashboardHeader(h1(HTML("ACA Data Entry Tool")),
                          sidebarIcon = NULL)
# header$children[[3]]$children[[3]] <- fluidRow(column(width = 11, actionButton("bug", "Report a Bug")), align = 'right', style = "padding-top: 8px")
## Sidebar -------------------------------
sidebar <- dashboardSidebar(
  # width = 250, 
  collapsed=FALSE,
  minified=FALSE,
  expandOnHover = TRUE,
  sidebarMenuOutput("menu"),
  # Add POC in sidebar
  div(style='position:absolute;bottom:10px;text-align:center;',
      # shiny::actionButton(inputId='link_button', label="Edit Database",
      #                     onclick ="window.open('https://apps.rstudio.futures.army.mil/aca_tool_development/', '_blank')"),
      # br(),br(),
      p(HTML(paste0('For dashboard inquiries, contact: \n','<br>',Contact)),
        img(src='ORSA2.png',
            height=100,width=100)
      )
  ))

shinyjs::useShinyjs()
## Body ----------------------------------
body <- dashboardBody(
  # dataTableOutput("test"),
  # selectInput("user_role", "For development, select your user role",
  #             c(read = "READ", write = "WRITE", admin = "admin")),
  
  tabItems(
    ### Page Modules ----------------------------
    crud_ui("welcome"),
    dashboard_ui("admin"),
    calendar_ui("about")
  )#,
  
  ### html -------------------------------------
  # tags$head(
  #   tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  # )
)

## UI Consolidated -----------------------
ui <- shinyUI(
  
  fluidPage(
    ## Use a preset CSS file to establish UI
    # includeCSS(here("www", "style.css")),
    
    # Include Logo in browser window
    tags$head(
      tags$link(rel = "icon", type = "image/png", href = "logo.png")),
    
    dashboardPage(      #title= titleText,
                        dark= NULL,header = header,
                        # controlbar = controlbarObj,
                        sidebar, 
                        body)
  )
)
# Server ==================================
server <- function(input, output, session) {

  ## Menu -----------------------
  output$menu <- renderMenu({
    if(user_df()[1,2] == "ADMIN"){
      sidebarMenu(id = "tabs",
        menuItem("Dashboard",   tabName = 'dashboard', icon = icon('chart')),
        menuItem("Calendar",    tabName = 'calendar', icon = icon('table')),
        menuItem("Manage Data", tabName = 'crud',   icon = icon("fa-solid fa-wrench", lib = "font-awesome")),
        )
    }else{
      sidebarMenu(id = "tabs",
        menuItem("Welcome",         tabName = 'welcome', icon = icon('fingerprint')),
        menuItem("Studies",         tabName = 'studies', icon = icon('table')),
        # menuItem("Manage Study Data",tabName ='manage_data_module', icon = icon('table')),
        # menuItem("About",           tabName = 'about',   icon = icon("fa-solid fa-question", lib = "font-awesome"))#,
        menuItem("Return to ACA Site", href = "https://apps.rstudio.futures.army.mil/connect/#/apps/1242/access", icon = icon("fa-sharp fa-solid fa-flag-usa", lib = "font-awesome"))
      )
    }
  })
  
  ## Call Server Modules ----------------------------------------
  welcome_page_server("welcome", user_df = reactive(user_df()))
  print("6"); print(tictoc::tic())
  
  observeEvent(input$tabs,{
    if(input$tabs=="studies"){
      studies_page_server("study", user_df = reactive(user_df()))
    }
  }, ignoreNULL = TRUE, ignoreInit = TRUE)

  observeEvent(input$tabs,{
    if(input$tabs=="manage_data_module"){
      manage_data_server("manage_data_module", user_df = reactive(user_df()))
    }
  }, ignoreNULL = TRUE, ignoreInit = TRUE)
  
  print("7"); print(tictoc::tic())
  
  observeEvent(input$tabs,{
    if(input$tabs=="admin"){
      admin_page_server("admin", user_df = reactive(user_df()))
    }
  }, ignoreNULL = TRUE, ignoreInit = TRUE)
  print("8"); print(tictoc::tic())
  
  about_page_server("about", user_df = reactive(user_df()))
  print("9"); print(tictoc::tic())
  
}

shinyApp(ui, server)