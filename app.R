tictoc::toc()
source(here::here("02_source", "utility.R"))
source(here::here("02_source", "crud_modules.R"))
source(here::here("02_source", "calendar_modules.R"))
source(here::here("02_source", "dashboard_modules.R"))

# UI ====================================

## Header --------------------------------
header <- dashboardHeader(title = "Company Dashboard")


## Sidebar -------------------------------
sidebar <- dashboardSidebar(
  # fixed = FALSE,
  # collapsed=FALSE,
  # minified=FALSE,
  # expandOnHover = TRUE,
  # div(style='top:10px;  margin-left: auto; margin-right: auto;  width: 50%;',
  #     p(img(src='logo.png',
  #           height=125,width=125)
  #     )
  # ),
  sidebarMenu(
    menuItem(text = "Dashboard",icon = icon('chart-simple'),tabName = 'dashboard'),
    menuItem(text = "Calendar",icon = icon('calendar'),     tabName = 'calendar'),
    menuItem(text = "Manage Data",icon = icon('wrench'),    tabName = 'dashboard')
  )

)


# shinyjs::useShinyjs()

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
  # skin = 'red',dark = NULL,help = NULL,
  ## calling UI components
  header = header,
  sidebar = sidebar,
  body = body
)


# library(ggplot2)
# data(penguins, package = "palmerpenguins")
# 
# color_by <- varSelectInput(
#   "color_by", "Color by",
#   penguins[c("species", "island", "sex")],
#   selected = "species"
# )
# cards <- list(
#   card(
#     full_screen = TRUE,
#     card_header("Bill Length"),
#     plotOutput("bill_length")
#   ),
#   card(
#     full_screen = TRUE,
#     card_header("Bill depth"),
#     plotOutput("bill_depth")
#   ),
#   card(
#     full_screen = TRUE,
#     card_header("Body Mass"),
#     plotOutput("body_mass")
#   )
# )
# 
# ui <- page_navbar(
#   
#   # sidebar = color_by,
#   nav_spacer(),
#   nav_panel("Bill Length", cards[[1]]),
#   nav_panel("Bill Depth", cards[[2]]),
#   nav_panel("Body Mass", cards[[3]])#,
#   # nav_item(tags$a("Posit", href = "https://posit.co"))
# )


# Server ==================================
server <- function(input, output, session) {
  # gg_plot <- reactive({
  #   ggplot(penguins) +
  #     geom_density(aes(fill = !!input$color_by), alpha = 0.2) +
  #     theme_bw(base_size = 16) +
  #     theme(axis.title = element_blank())
  # })
  # 
  # output$bill_length <- renderPlot(gg_plot() + aes(bill_length_mm))
  # output$bill_depth <- renderPlot(gg_plot() + aes(bill_depth_mm))
  # output$body_mass <- renderPlot(gg_plot() + aes(body_mass_g))
  
  dashboard_server("dashboard")
  crud_server("crud")
  calendar_server("calendar")
  
  ## Menu -----------------------
  output$menu <- renderMenu({
    
  })
  
}

shinyApp(ui, server)

