# We first need to extract the required data from data dumps hosted by the FPL site.
# There are two APIs that are used to extract fantasy football data:

# https://fantasy.premierleague.com/drf/elements/: Contains player IDs, names and other general details
# https://fantasy.premierleague.com/drf/element-summary/{id}: contains detailed stats on footballers

# 1) Import (and install) required modules
library(tidyverse)
library(jsonlite)

# 2) Import and view data

# fromJSON flattens the json file
elements <- fromJSON("https://fantasy.premierleague.com/drf/elements/")
View(elements)

# note that 'now_cost' and 'selected_by_percent' will change
colnames(elements)

# while there are some general stats here (like goal_scored), these aren't split by gameweek
# we only want general details from this json

# 3) Transforming the data

# Issue with long player names 
# some players have more than one first name, we want to only select the first one
# this only affects surnames but it's more difficult to arbitrarily select the correct name

index = elements %>%
  mutate(name = paste(word(first_name, 1), second_name, sep = " ")) %>%
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
