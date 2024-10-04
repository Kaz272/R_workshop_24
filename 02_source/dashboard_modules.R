library(DT)

dashboard_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "dashboard",
          box(width = 4, status = 'primary', solidHeader = TRUE,title = "Winning Percentage", p("a little table of the top 3 teams")),
          box(width = 4, status = 'danger', solidHeader = TRUE,title = "Wins", p("a little table of the top 3 teams")),
          box(width = 4, status = 'primary',solidHeader = TRUE, title = "Losses", p("a little table of the top 3 teams")),
          box(title = h2("Stats",  tags$style ('h2 {margin-top: 0;}')),
            width = 9,height = '650px',  #tags$style ('.box-header {padding-top: 0; margin-top: 0; border: 0px white}'),
            column(width = 2,
                   radioButtons(inputId = ns("team_or_player"),label = "Player Stats or Team Stats", choices = c("Player","Team")),
                   uiOutput(outputId = ns("stat_selector"))
            ),
            column(width = 10,
                   plotOutput(outputId = ns("stat_plot"),height = '545px')
            )
          ),
          box(title = "Last Week's Scoreboard", width = 3,
          uiOutput(outputId = ns("recent_games")),
          ),
          uiOutput(ns("news"))
  ) 
}

dashboard_server <- function(id) {
  moduleServer(
    id,
    
    function(input, output, session) {
      ns <- session$ns
      
      # Recent Games ---------------------------------
      # function to build a reactable for last n games that took place in the last 6 days
      create_recent_game_box <- function(two_row_game_tbl){ # two_row_game_tbl is a two row tibble for a single game. One row for each competitor. 
        date <- ymd_hm(two_row_game_tbl$date[1]) %>% format("%A, %B %d, %Y") 
        
        div(tags$style(".rt-compact .rt-td-inner, .rt-compact .rt-th-inner {padding: 0px 0px;}  .Reactable.ReactTable.rt-compact {margin-bottom: 10px}"), #This makes the reactable more compact
            two_row_game_tbl %>% 
              select(team_name, team_score) %>% 
              reactable::reactable(
                columns = list(
                  team_name = colDef(name = date,
                                     cell = function(value, index) {
                                       file_name <- two_row_game_tbl$team_id[index]
                                       div(shiny::img(src = paste0("team/",file_name,".png"),
                                                      alt = value,
                                                      width = '10%'), value)}
                  ),
                  team_score = colDef(name = '',width=40,style = "font-weight: 800")
                ),height = '84px',compact = T
              )#, # end reactable
            # br() # add separation between this iteration and the next iteration
        ) # end div
      } # end create_recent_game_box function
      
      # Build several UI boxes by mapping create_recent_game_box to a list of two-row tibbles
      output$recent_games <- renderUI({
        recent_games %>% 
          select(id, team_id, shortName, team_name = displayName, date, team_score) %>% 
          distinct_all() %>% 
          # mutate(nrow = nrow(.)/2) %>% 
          group_split(id) %>%
          purrr::map(create_recent_game_box)
      })
      
      # Main Bar Chart ------------------------------------------
      
      ## stat_option reactive ----------------------
      # Set reactive object based on user's selection to see player or team stats
      stat_options <- reactive({
        if(input$team_or_player=="Player"){
          s <- team_stats %>% pull(stat_display_name) %>% unique()
        }else{
          s <- team_stats %>% pull(stat_display_name) %>% unique()
        }
        message(s)
        return(s)
      })
      
      ## Stat Dropdown ----------------
      # Built stat dropdown that allows user to select stat
      output$stat_selector <- renderUI({
        selectInput(inputId = ns("stat_selection"), label = "Select a Stat", choices = stat_options(), selected = "Points")
      })
      
      ## for_plot reactives ----------------------------
      for_plot <- reactive({
        message('begin for_plot')
        req(input$stat_selection)
        
        data <- team_stats %>% 
          filter(stat_display_name == input$stat_selection )
        message('mid for_plot')
        y_offset <- data %>% 
          pull(stat_value) %>% 
          mean/16
        message('end for_plot')
        return(list(data= data, y_offset = y_offset))
      })
      
      ## Plot --------------------------------------
      output$stat_plot <- renderPlot({
        # print(for_plot()$data )
        for_plot()$data %>%
          ggplot(aes(x = fct_reorder(team_name,team_rank), y = stat_value)) +
          geom_col(aes(fill = team_name)) +
          geom_image(aes(y = for_plot()$y_offset*1.1, image=team_logo_filename), size = 0.22) +
          geom_text(aes(y = stat_value + for_plot()$y_offset, label = round(stat_value, 0)),size = 18, size.unit = 'pt') +
        scale_fill_manual(values =unique(for_plot()$data$color_hex) ) +
        theme(legend.position = 'none',
              axis.text = element_text(size = rel(1.4)),
              axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
              title = element_text(size = rel(1.6))
              ) +
        labs(title = for_plot()$data$stat_display_name[1],
             y = for_plot()$data$stat_display_name[1],
             x = 'Team')
    })
      
      # News ---------------------------------------------
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
      
      # Build news UI by mapping create_news_box to all news records
      output$news <- renderUI({
        news %>% 
          distinct(title, description, news_image_filepath, news_link) %>% 
          purrr::pmap(create_news_box) 
      })
      
    }#end module function
  )#end module
}#end server