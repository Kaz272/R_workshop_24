
crud_ui <- function(id) {
  
  ns <- NS(id)
  # ns <- NS("crud")
  
  tabItem(tabName = "crud",
          # rHandsontableOutput(ns("rhandsontable")),
          navbarPage(
            "Manage Data",   
            tabPanel("Conferences",
                     fluidPage(
                       rHandsontableOutput(ns("conf_crud"))
                     ) # end fluidPage
                     ), # end tabPanel
            tabPanel("Teams",
                     fluidPage(
                       column(width = 8,
                              reactableOutput(ns("team_crud"))
                       ),
                       column(width = 4, 
                              uiOutput(ns("team_input_box"))
                       )
                     )# end fluidPage
                     ), # end tabPanel
            tabPanel("Players",
                     fluidPage(
                       dataTableOutput(ns("player_crud"))
                     )# end fluidPage
                     ) # end tabPanel
            )# end navbarPage
          ) # end tabItem
}

crud_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      ns <- session$ns
      
      # See original data -----------------------------------
      
      # We will work with 3 datasets that utility.R already read in. Here they are: 
      
      # team_conference_xwalk %>% glimpse
      # Rows: 12
      # Columns: 3
      # $ id          <int> 3, 5, 6, 8, 9, 11, 14, 16, 17, 18, 19, 20
      # $ displayName <chr> "Dallas Wings", "Indiana Fever", "Los Angeles Sparks", "Minnesota Lynx", "New York Liberty", ...
      # $ conference  <chr> "Western Conference", "Eastern Conference", "Western Conference", "Western Conference",...
      
      # team_stats %>% glimpse
      # Rows: 84
      # Columns: 13
      # $ team_id            <int> 3, 3, 3, 3, 3, 3, 3, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 8, 8, 8,…
      # $ team_name          <chr> "Dallas Wings", "Dallas Wings", "Dallas Wings", "Dallas Wings", "Dallas…
      # $ color              <chr> "002b5c", "002b5c", "002b5c", "002b5c", "002b5c", "002b5c", "002b5c", "…
      # $ team_logo_filename <chr> "www/team/3.png", "www/team/3.png", "www/team/3.png", "www/team/3.png",…
      # $ stat_name          <chr> "blocks", "steals", "totalRebounds", "fieldGoalPct", "freeThrowPct", "p…
      # $ stat_display_name  <chr> "Blocks", "Steals", "Rebounds", "Field Goal Percentage", "Free Throw Pe…
      # $ stat_desc          <chr> "Short for blocked shot, number of times when a defensive player legall…
      # $ stat_value         <dbl> 158.000, 285.000, 1390.000, 44.389, 78.552, 3368.000, 84.200, 173.000, …
      # $ stat_rank          <int> 7, 8, 14, 5, 6, 4, NA, 5, 12, 12, 1, 7, 3, NA, 12, 5, 18, 10, 10, 10, N…
      # $ categories         <chr> "Defensive", "Defensive", "General", "Offensive", "Offensive", "Offensi…
      # $ stat_rank_display  <chr> "7th", "8th", "14th", "5th", "6th", "4th", "", "5th", "12th", "12th", "…
      # $ color_hex          <chr> "#002b5c", "#002b5c", "#002b5c", "#002b5c", "#002b5c", "#002b5c", "#002…
      # $ team_rank          <int> 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 10, 10, 10, 10, 10, 10, 10, 6…
      
      
      # player_stats %>% glimpse
      # Rows: 8,688
      # Columns: 24
      # $ athlete_id               <int> 2491214, 2491214, 2491214, 2491214, 2491214, 2491214, 2491214, 2…
      # $ displayName.x            <chr> "Erica Wheeler", "Erica Wheeler", "Erica Wheeler", "Erica Wheele…
      # $ age                      <int> 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, …
      # $ college                  <chr> "http://sports.core.api.espn.com/v2/colleges/164?lang=en&region=…
      # $ position_id              <int> 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3…
      # $ position_displayName     <chr> "Guard", "Guard", "Guard", "Guard", "Guard", "Guard", "Guard", "…
      # $ team                     <chr> "http://sports.core.api.espn.com/v2/sports/basketball/leagues/wn…
      # $ experience               <int> 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8…
      # $ active                   <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE…
      # $ status                   <chr> "Active", "Active", "Active", "Active", "Active", "Active", "Act…
      # $ headshot                 <chr> "https://a.espncdn.com/i/headshots/wnba/players/full/2491214.png…
      # $ name                     <chr> "blocks", "defensiveRebounds", "steals", "avgDefensiveRebounds",…
      # $ displayName.y            <chr> "Blocks", "Defensive Rebounds", "Steals", "Defensive Rebounds Pe…
      # $ shortDisplayName         <chr> "BLK", "DREB", "STL", "DRPG", "BPG", "SPG", "DREB/48", "BLK/48",…
      # $ description              <chr> "Short for blocked shot, number of times when a defensive player…
      # $ abbreviation             <chr> "BLK", "DR", "STL", "DR", "BLK", "STL", "DR", "BLK", "STL", "DQ"…
      # $ value                    <dbl> 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0…
      # $ displayValue             <chr> "0", "0", "0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0", "0…
      # $ rank                     <int> 44, 68, 56, NA, NA, NA, 3264, 2112, 2688, 1, 3, 52, 1, 7, 127, N…
      # $ rankDisplayValue         <chr> "Tied-44th", "Tied-68th", "Tied-56th", "", "", "", "Tied-3,264th…
      # $ athlete_stats_category   <chr> "Defensive", "Defensive", "Defensive", "Defensive", "Defensive",…
      # $ displayName              <chr> "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", …
      # $ team_id                  <int> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5…
      # $ player_headshot_filename <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
      
      ## Prep data ---------------------------------
      prepped_team <- team_stats %>% transform_to_vis_team()
      prepped_player <- player_stats %>% transform_to_vis_player()
      prepped_conf <- team_conference_xwalk %>% transform_to_vis_conf()
      
      v <- reactiveValues(team = prepped_team, 
                          player = prepped_player,
                          conf = prepped_conf)
      
      # # For troubleshooting, run this 
      # v <- list(team = prepped_team,
      #           player = prepped_player,
      #           conf = prepped_conf)
      
      # RHandsonTable ---------------------------------
        output$conf_crud <- renderRHandsontable(
          v$conf %>% 
            rhandsontable(width = '250px')
        )
      
      # Reactable ---------------------------------  
      output$team_crud <- renderReactable(
        v$team %>% 
         reactable(
          columns = list(
            `Team Color` = colDef(
              style = function(value) {
                color <- value
                list(background = color)
              }
            )
          ),
          pagination = F,
          outlined = T,
          selection = 'single'
        )
      )
      
      # Display team information --------------------------
    build_team_input_box <- function(selected_team_record=list(), edit = T){
      
      header <- ifelse(test = edit,
                       yes = paste0("Edit ", selected_team_record$`Team Name`, selected_team_record$team_id),
                       no = "Create New Team")
      message(header)
      
      box(width = 12,
        h3(header),
        textInput(inputId = ns("team_name"), label = "Team Name", value = selected_team_record$`Team Name`),
        textInput(inputId = ns("team_color"), label = "Team Color", value = selected_team_record$`Team Color`),
        textInput(inputId = ns("logo_filename"), label = "Team Logo Filepath", value = selected_team_record$`Logo Filename`),
        actionButton(inputId = ns("submit_team"), label = "Submit")
      )
    }
      
      team_input_box <-reactive({
        
        selected_row  <- getReactableState("team_crud", "selected") # this gives me the row number of the visualized reactable
        
        if(is.null(selected_row)){
          build_team_input_box(edit = F)
        }else{
        message(paste("User selected", getReactableState("team_crud", "selected")))
        
        v$team %>% 
          slice(selected_row) %>% 
          build_team_input_box(edit = T)
        }
      })
      
  
    output$team_input_box <- renderUI({
      team_input_box()
    })
    
    observeEvent(input$submit_team, {
     })
      
    # DT::DataTable ------------------------------
        output$player_crud <- DT::renderDataTable(
          v$player %>% 
            datatable(selection = 'single')
        )
      
    } #end module function
  ) # end moduleServer
} # end server



transform_to_vis_team <- function(team_stats_orig){
  # team_stats_vis <- 
  team_stats |> 
    distinct(team_id, team_name, team_logo_filename, color_hex) |> # Just using these columns for demonstration purposes
    head(100) |> # this is just for demonstration purposes
    left_join(team_conference_xwalk, by = c("team_name" = "displayName")) |> 
    select(team_id, 
           `Team Name` = team_name, 
           `Logo Filename` = team_logo_filename,
           `Team Color` = color_hex,
           Conference = conference)
  #returns transformed dataframe ready for visual table
}

transform_to_orig_team <- function(team_stats_vis){
  team_stat_orig <- 
    team_stat_vis %>% 
    select(team_id, 
           team_name=`Team Name`, 
           team_logo_filename=`Logo Filename`,
           color_hex=`Team Color`,
           conference=Conference)
  
  team_conf_xwalk <- 
    team_stats_vis %>% 
    distinct(team_id, Conference)
  
  return(list(team_stat_orig=team_stat_orig,
              team_conf_xwalk=team_conf_xwalk))
  # returns original dataframe ready to write back to origin data
}


transform_to_vis_player <- function(player_stats_orig){
  # player_stats_vis<-
  player_stats |> 
    distinct(displayName.x,age, position_displayName,team_id) |> # Just using these columns for demonstration purposes
    head(100) |> # shortening dataset for demonstration purposes
    left_join(team_stats |> distinct(team_id, team_name)) |> 
    select(`Player Name` = displayName.x,
           `Player Age` = age,
           `Player Position` = position_displayName,
           `Team Name` = team_name)
} 

transform_to_player_orig <- function(player_stats_vis){
  player_stats_vis %>% 
    select(displayName.x = `Player Name`, 
           age = `Player Age`,
           position_displayName = `Player Position`, 
           team_name = `Team Name`)
}

transform_to_vis_conf <- function(team_conf_xwalk_orig){
  team_conference_xwalk %>% 
    distinct(conference) %>% 
    rename(Conference = conference)
}

transform_to_orig_conf <- function(team_conf_xwalk_vis){
  team_conf_xwalk_vis %>% 
    rename(conference = Conference)
}

