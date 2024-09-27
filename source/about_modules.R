about_page_ui <- function(id) {
  
  ns <- NS(id)
  
  tabItem(tabName = "about",
          shinyjs::useShinyjs(),
          h2("About", align="center"),
          h4("Purpose: This tool facilitates senior leader understanding of analysis across the Army and how it aligns to the 
             Army Campaign Plan. Senior leaders are making decisions, and it is up to the ACA to ensure these decision makers
             are aware of all analyses that enable those decisions. This tool helps analytic leaders communicate those analyses to 
             senior decision makers as well as identify potential gaps in analysis relative to ACP objectives.", align ="center"),
          hr(),
          fluidRow(
            column(6,
                   
                   h4("Content Owner: TRAC", align="center"),
                   h4("Dr. Brian Wade - brian.m.wade.civ@army.mil", align="center"),
                   h4("LTC James Jablonski - james.a.jablonski.mil@army.mil", align="center")),
            column(6,
                   h4("App Developer: FCC", align="center"),
                   h4("MAJ Maxine Drake - maxine.a.drake.mil@army.mil", align="center"),
                   h4("MAJ Shane Hasbrouck - shane.m.hasbrouck.mil@army.mil", align="center")))
  )
}

about_page_server <- function(id, user_df) {
  moduleServer(
    id,
    
    function(input, output, session) {
      
      output$cui_alert <- renderUI({
        sendSweetAlert(
          session = getDefaultReactiveDomain(),
          title = "This is a CUI environment.",
          text = NULL,
          type = NULL,
          btn_labels = "I Acknowledge",
          btn_colors = "#3085d6",
          html = FALSE,
          closeOnClickOutside = TRUE,
          showCloseButton = FALSE)
      })
      
    }
    
  )
  
}