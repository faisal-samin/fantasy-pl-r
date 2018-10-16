# We first need to extract the required data from data dumps hosted by the FPL site:

# https://fantasy.premierleague.com/drf/elements/: Contains player IDs, names and other general details
# https://fantasy.premierleague.com/drf/element-summary/{id}: contains detailed stats on footballers


# Modules and import data -------------------------------------------------

library(tidyverse)
library(jsonlite) # flattening jsons
library(tictoc) # timing code

# fromJSON flattens the json file
elements <- fromJSON("https://fantasy.premierleague.com/drf/elements/")

# note that 'now_cost' and 'selected_by_percent' will change frequently

# while there are some general stats here (like goal_scored), these aren't split by gameweek
# we only want general details from this json

# Data transformation -----------------------------------------------------

# Issues
# Long player names 
# some players have more than one first name, we want to only select the first one
# this only affects surnames but it's more difficult to arbitrarily select the correct name

players = elements %>%
  mutate(name = 
           paste(word(first_name, 1), 
                 second_name, 
                 sep = " ")
         ) %>%
  select(id, name, now_cost, selected_by_percent, element_type, team, photo) %>%
  mutate(position = recode(element_type,
                           `1` = 'gk',
                           `2` = 'def',
                           `3` = 'mid',
                           `4` = 'fwd')) %>%
  mutate(team = recode(team,
                       `1` = 'Arsenal',
                       `2` = 'Bournemouth',
                       `3` = 'Brighton',
                       `4` = 'Burnley',
                       `5` = 'Cardiff',
                       `6` = 'Chelsea',
                       `7` = 'Crystal Palace',
                       `8` = 'Everton',
                       `9` = 'Fulham',
                       `10` = 'Huddersfield',
                       `11` = 'Leicester',
                       `12` = 'Liverpool',
                       `13` = 'Man City',
                       `14` = 'Man Utd',
                       `15` = 'Newcastle',
                       `16` = 'Southampton',
                       `17` = 'Spurs',
                       `18` = 'Watford',
                       `19` = 'West Ham',
                       `20` = 'Wolves')) %>%
  arrange(id, team, element_type) %>%
  select(id, name, now_cost, selected_by_percent, team, position, photo)

# We now join onto gameweek level from the detailed URL dumps

# Initialise an empty data frame
gameweek_details = data.frame()

tic("Scraping: ") # Takes approximately 86 seconds
for (i in players$id) {
  url = fromJSON(
    paste("https://fantasy.premierleague.com/drf/element-summary/",
              toString(i), sep = ""))
  history = url$history # gameweek history
  gameweek_details = rbind(gameweek_details, history) 
  print(i)
  # Sys.sleep(1)
}
gameweek_details = subset(gameweek_details, select = -id) # drop id column
toc()

# Finally, we join the two dataframes
fpl <- merge(players, gameweek_details, by.x = "id", by.y = "element")

filter(fpl, name == "Eden Hazard") %>%
  select(photo)

# Further tranformations --------------------------------------------------
# We add a few final touches, and refine the columns for our final dataset

# Fixing image URLs
fpl$image_url = paste("https://platform-static-files.s3.amazonaws.com/premierleague/photos/players/110x140/p",
                      strsplit(fpl$photo, split = ".", fixed = TRUE)[[1]][1],
                      ".png",
                      sep = "")

write_csv(fpl, "fpl.csv")

# Reordering columns and dropping those not of interest
fpl <- select(fpl,
              id, name, team, position,
              selected, now_cost, value,
              round, 
              team_h_score, team_a_score, was_home,                       
              total_points,
              selected, transfers_in, transfers_out,          
              minutes,                      
              goals_scored,                  
              assists,
              clean_sheets,
              goals_conceded,                 
              own_goals,                     
              penalties_saved,                
              penalties_missed,               
              yellow_cards,                   
              red_cards,                      
              saves,                         
              bonus,                         
              bps,                            
              open_play_crosses,             
              big_chances_created,           
              clearances_blocks_interceptions,
              recoveries,                    
              key_passes,                   
              tackles,                     
              winning_goals,                  
              attempted_passes,               
              completed_passes,             
              penalties_conceded,           
              big_chances_missed,            
              errors_leading_to_goal,         
              errors_leading_to_goal_attempt,
              tackled,                        
              offside,                       
              target_missed,                  
              fouls,                        
              dribbles,                     
              fixture,                       
              opponent_team,                  
              image_url)



