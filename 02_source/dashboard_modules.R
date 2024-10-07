
dashboard_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "dashboard",
          h4("WNBA Stats and News as of October 5, 2024 6:00 PM"),
          # wide box, top of screen
          box(title = "Team Snapshot", width = 12,# wide box, top of screen
              column(width = 2, 
                     uiOutput(ns("team_selector"))
                     ),
              column(width = 1,
                     uiOutput(ns("team_logo"))
                     ),
              column(width = 9, 
                     uiOutput(ns("team_snapshot"))
                     )
          ),
          # Large box in middle with bar chart
          box(title = "League Stats", width = 9,height = '550px',
              column(width = 2,
                     uiOutput(outputId = ns("stat_selector"))
              ),
              column(width = 10,
                     plotOutput(outputId = ns("stat_plot"),height = '450px')
              )
          ),
          box(title = "Last Week's Scoreboard", width = 3, # box on right with recent games & scores
              uiOutput(outputId = ns("recent_games")),
          ),
          uiOutput(ns("news")) # all the news headlines below the bar chart
  ) 
}

dashboard_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      ns <- session$ns
      
      # Team Snapshot ===========================
      
      ## Team Selector -----------------------------
      
      # get unique team names
      team_options <-
     team_stats %>% 
        distinct(team_name, team_rank) %>% 
        arrange(team_rank) %>% 
        pull(team_name)
      
      # create team selector
      output$team_selector <- renderUI({
        selectInput(inputId = ns("team_selection"),
                    label = "Select a Team", 
                    choices = team_options, 
                    selected = team_options[1],
                    width = '100%')
      })
      
      ## React to team selection --------------------------
      team_snapshot_values <- reactive({
        req(input$team_selection) #this ensures input$team_selection is not null. If a selection doesn't exist, the reactive will stop here.
        
        team_win_loss <- wins_losses_by_team %>% 
          filter(team_name == input$team_selection) 
        
        wins <- team_win_loss %>% filter(winner) %>% pull(n)
        losses <- team_win_loss %>% filter(!winner) %>% pull(n)
        win_loss_perc <- paste0( round(100 * wins / (wins+losses), 1), "%")
        team_id <- team_win_loss %>% pull(team_id) %>% .[1]
        
        return(list(wins = wins, #returning a list of reactive values
                    losses = losses,
                    win_loss_perc = win_loss_perc,
                    team_id = team_id))
      })
      
      ## Build team snapshot UI ----------------------------
      
      # Build logo UI
      output$team_logo <- renderUI({
        img(src = paste0("team/",team_snapshot_values()$team_id,".png"), width = "100%",
             alt = "alternative text")
      })
      
      # Build team value boxes 
      output$team_snapshot <- renderUI({
        tagList( 
          valueBox(value = team_snapshot_values()$wins, color = 'blue', subtitle = "Wins", width = 4),
          valueBox(value = team_snapshot_values()$losses, color = 'maroon', subtitle = "Losses", width = 4),
          valueBox(value = team_snapshot_values()$win_loss_perc, color = 'blue', subtitle = "Win-Loss %", width = 4)
        )
      })
      
      # Recent Games ===========================================
      
      # function to build a reactable for n games that took place in the last 6 days
      create_recent_game_box <- function(two_row_game_tbl){ # two_row_game_tbl is a two row tibble for a single game. One row for each competitor. 
        date <- ymd_hm(two_row_game_tbl$date[1]) %>% format("%A, %B %d, %Y") 
        
        div(tags$style(".rt-compact .rt-td-inner, .rt-compact .rt-th-inner {padding: 0px 0px;}  .Reactable.ReactTable.rt-compact {margin-bottom: 10px}"), #This makes the reactable more compact
            two_row_game_tbl %>% 
              select(team_name, team_score) %>% 
              reactable::reactable(
                columns = list( # Within this list, I will call out specific columns and use the colDef function to specify attributes
                  team_name = colDef(name = date,
                                     cell = function(value, index) {
                                       file_name <- two_row_game_tbl$team_id[index]
                                       div(shiny::img(src = paste0("team/",file_name,".png"),
                                                      alt = value,
                                                      width = '7%'), value)}
                  ),
                  team_score = colDef(name = '',
                                      width=40,
                                      style = "font-weight: 800")
                ),
                height = '84px',
                compact = T
              ) # end reactable
        ) # end div
      } # end create_recent_game_box function
      
      # Build several UI boxes by mapping create_recent_game_box to a list of two-row tibbles
      output$recent_games <- renderUI({
        recent_games %>% 
          select(id, team_id, shortName, team_name = displayName, date, team_score) %>% 
          distinct_all() %>% 
          # mutate(nrow = nrow(.)/2) %>% 
          group_split(id) %>% # at this point, I have a list of two-row dataframes
          purrr::map(create_recent_game_box) #map the create_recent_game_box function to each element in the list. 
        # the outcome of this is a list of UI (reactable tables)
      }) 
      
      
      
      # Main Bar Chart =====================================
      
      ## Stat Selector ----------------------
      
      # Set reactive object based on user's selection to see player or team stats
      stat_options <- team_stats %>% pull(stat_display_name) %>% unique()
      
      # Build stat selector
      output$stat_selector <- renderUI({
        selectInput(inputId = ns("stat_selection"), label = "Select a Stat", choices = stat_options, selected = "Points")
      })
      
      ## React to stat selector ----------------------------
      for_plot <- reactive({
        message('begin for_plot')
        req(input$stat_selection)
        
        data <- team_stats %>%
          filter(stat_display_name == input$stat_selection ) %>%
          mutate(selected = ifelse(team_name==input$team_selection, "selected", "not selected")) %>%  # this will give me a TRUE for the selected team. I'll use this in the color aesthetic in my ggplot
          arrange(desc(team_rank)) %>% 
          mutate(team_name = factor(team_name, team_name))
          
        y_offset <- data %>% 
          pull(stat_value) %>% 
          mean/16
        
        message('end for_plot')
        return(list(data= data, y_offset = y_offset))
      })
      
      ## Build Plot --------------------------------------
      output$stat_plot <- renderPlot({
        # print(for_plot()$data )
        for_plot()$data %>%
          ggplot(aes(x = fct_reorder(team_name,team_rank), y = stat_value)) +
          geom_col(aes(fill = team_name, alpha = selected)) +
          geom_image(aes(y = for_plot()$y_offset*1.1, image=team_logo_filename), size = 0.15) +
          geom_text(aes(y = stat_value + for_plot()$y_offset, label = round(stat_value, 0)),size = 18, size.unit = 'pt') +
          scale_fill_manual(values =unique(for_plot()$data$color_hex) ) +
          scale_alpha_manual(values = c(.3,1)) + 
          theme(legend.position = 'none',
                axis.text = element_text(size = rel(1.4)),
                axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
                title = element_text(size = rel(1.6))
          ) +
          labs(title = for_plot()$data$stat_display_name[1],
               y = for_plot()$data$stat_display_name[1],
               x = 'Team')
      })
      
      # News ================================================
      
      # define function to build news UI
      create_news_box <- function(title, description, news_image_filepath, news_link){
        news_box <- box(title = title, width=4,
                        tags$a(
                          href=news_link, 
                          tags$img(src = news_image_filepath,
                                   alt = title,
                                   width = '100%'),
                          p(description)
                        ),
        )
        return(news_box)
      }
      
      # Build several news boxes by mapping create_news_box to each row in a news dataframe
      output$news <- renderUI({
        news %>% 
          distinct(title, description, news_image_filepath, news_link) %>% 
          purrr::pmap(create_news_box) # iterate over multiple arguments simultaneously. Function arguments correspond to column names in the dataframe.
      })
      
    }#end module function
  )#end module
}#end server