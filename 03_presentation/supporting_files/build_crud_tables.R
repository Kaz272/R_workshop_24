library(reactable)
library(here)
library(dplyr)

reactable::reactable(data.frame(`Conference Name` = c("Western Conference", "Eastern Conference")), outlined = T)

reactable::reactable(data.frame(`Team Name` = c("Atlanta Dream", "Dallas Wings", "Los Ange")))

team_conference_xwalk <- data.table::fread(here(... = "01_data", "table", "clean","team_meta.csv"))


team_stats |> 
  distinct(team_name, team_logo_filename, color_hex) |> 
  head(5) |> 
  left_join(team_conference_xwalk, by = c("team_name" = "displayName")) |> 
  select(`Team Name` = team_name, 
         `Logo Filename` = team_logo_filename,
         `Team Color` = color_hex,
         Conference = conference) |> 

reactable(
  columns = list(
    `Team Color` = colDef(
      style = function(value) {
        color <- value
        list(background = color)
      }
    )
  ), pagination = F,outlined = T
)

player_stats <- data.table::fread(here(... = "01_data", "table", "raw","athlete_full.csv"))

# players <- 
player_stats |> 
  distinct(displayName.x,age, position_displayName,team_id) |> 
  head(5) |> 
  left_join(team_stats |> distinct(team_id, team_name)) |> 
  select(`Player Name` = displayName.x, `Player Age` = age, `Player Position` = position_displayName, `Team Name` = team_name) |> 
  reactable(columns = list(`Player Age` = colDef(align = 'left', width = 100)),pagination = F, outlined = T)

