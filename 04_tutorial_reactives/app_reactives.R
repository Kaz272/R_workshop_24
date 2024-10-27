library(shiny)
library(shinydashboard)
library(data.table)
library(here)
library(dplyr)
library(stringr)
library(reactable)
library(ggplot2)
# reference: https://mastering-shiny.org/reactivity-intro.html

league_stats <- fread(here("01_data","table","clean", "clean_team_stats.csv")) 
unique_teams <- league_stats %>% pull(team_name) %>% unique()
# UI ====================================

## View Data
# team_stats |> as_tibble()

## Header --------------------------------
header <- dashboardHeader(title = "Demonstration: Shiny Reactivity")


## Sidebar -------------------------------
sidebar <- dashboardSidebar(
)

## Body ----------------------------------
body <- dashboardBody(
  selectInput(inputId = "team", label = "Select Team", choices = unique_teams, multiple = T ),
  box(width = 12,
      uiOutput("team_info")
  ),
  h2("Box built for a single team using the 'build_stat_ui' function "),
  fluidRow(uiOutput("single_team_stats_box")),
  br(),
  h2("Multiple boxes built by mapping the 'build_stat_ui' function to each team"),
  uiOutput('multiple_team_stats_boxes')
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
  
  # Reactive Building Blocks -----------------------------
  
  ## Define output ------------------
  output$team_info <- renderUI({
    team_info_ui() 
  })
  # follow the reactive graph, in our output, we have team_info_ui(); in team_info_ui(), we use v$team  
  
  ## reactive --------------------------------
  team_info_ui <- reactive(h3(paste("You selected: ", paste0(v$team, collapse = ", "))))
  
  ## reactiveValues ---------------------------
  v <- reactiveValues(
    team = c()
  ) # with reactiveValues, you must have a hard coded starting value
  
  ## reactive --------------------------------
  team_data <- reactive({ 
    req(v$team)
    team_data_df <- league_stats |> 
      filter(team_name %in% v$team) 
    
    return(team_data_df) #similar to a function, you don't need to define the object then use 'return'.
  })
  
  ## observeEvent ----------------------------
  observeEvent(input$team, { #use observeEvent when your goal is to execute an action rather than create an object. eventReactive is better suited to create a reactive object. 
    message(paste(input$team, 'selected'))
    v$team <- input$team 
  })
  
  # Ordering Reactives -----------------------------------------
  # Notice the output is defined prior to the reactives it uses... that's ok!
  # The order this reactive code is determined by the reactive graph.
  # This is different from most R code where the execution order is determined by the order of lines.
  
  # Dynamic UI ---------------------------
  
  build_stat_ui <- function(team_data){
    # Calculate some values
    team_name <- team_data %>% pull(team_name) %>% .[1]
    team_color <- team_data %>% pull(color_hex) %>% .[1]
    team_stats <- 
      team_data %>% 
      select(stat_display_name, stat_value) %>% 
      mutate(is_score = str_detect(stat_display_name, 'Points')) %>% 
      arrange(desc(is_score)) %>% 
      select(-is_score) %>% 
      reactable(defaultColDef = colDef(name = ''),
                width = '100%',
                pagination = F)
    
    #Build the UI
    ui <- box(width =4, height = '500px', title = h2(team_name), #arguments standard within box
              team_stats
    )
    
    return(ui)
  } # end build_stat_ui
  
  
  output$single_team_stats_box <- renderUI({
    team_data() |> 
      filter(team_name == v$team[1]) |> # filtering for just the first team selection
      build_stat_ui()
  })
  
  # output$multiple_team_stats_boxes <- renderUI({
  #   league_stats %>% 
  #     group_split(team_id) %>% 
  #     purrr::map(build_stat_ui)
  # })
  output$multiple_team_stats_boxes <- renderUI({
    team_data() %>% 
      group_split(team_id) %>% 
      purrr::map(build_stat_ui)
  })
  
} # end server

shinyApp(ui, server)

