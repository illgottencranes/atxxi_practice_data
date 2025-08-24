### --------------
### Package installation (first time only)
### --------------

## These installations ONLY need to be run the first time, then you can ignore them:

install.packages("tidyverse")
install.packages("readxl")

### --------------
### Set-up (every time)
### --------------

## Run these two first every time:
library(tidyverse) # the warning about conflicts is normal!
library(readxl)


## You should have a project folder for all source files, including this code and both
# raw data files (yours, and the ship data). Run the next lines of code to import the
# file if you saved the files in .xlsx format (you don't have to be able to open it in
# Excel for it to work, and you can download it in that format from Google Sheets). 

# NB: Make sure that you've changed the name here to match your file! Also, you can't
# import the file while it is open in another program.

practice_data_raw <- read_excel("ATXXI_practice_data.xlsx")

## Also import the info sheet with the list of ships and their points costs, saved in
# the same location (this is separate so that points can be updated  more easily if
# they're changed):

ship_infosheet <- read_excel("ATXXI_ship_info.xlsx")


## If you saved your raw data a .csv instead of an .xlsx, un-comment this function and
# use it. Note: look at the data to make sure that all the columns are there. You might
# have to change delim = ";" to delim = ",".

# practice_data_raw <- read_delim(file = "ATXXI_practice_record.csv",
#                            delim = ";")
#
# ship_infosheet <- read_delim(file = "ATXXI_ship_info.csv",
#                            delim = ";")

# Look at data structure, mainly to make sure you have multiple columns:
glimpse(practice_data_raw)

glimpse(ship_infosheet)



# * If you already know how to use R, do whatever kind of directory you prefer.


### --------------
### Variable set-up (every time)
### --------------

### Defining various terms that will be used later

## YOU DECIDE: Minimum number of days a pilot needs to attend to be included for
# attendance. (will be treated as >=)

min_attendance = 6

## YOU DECIDE: When looking at ship/comp success, how many days after the start of
# practice should the data be considered? For example, you might cut out the first few
# days if everyone was very rusty or new, or ignore all ship stats from before the 
# feeder tournament. (will be treated as >=)

data_starts_from_day = 0


## Finding the first date of practice:
earliest_date <- practice_data_raw |>
  select(date) |>
  distinct() |>
  slice_min(date)

## Adding a column with the number of days since the start of practices:
practice_data_days <- practice_data_raw |>
  mutate(days_since_start = as.double(difftime(date, earliest_date$date, units = c("days"))), 
         .after = date) |>
  mutate(across(c(pilot:ship_class, outcome:opp_archetype), ~na_if(., "NA"))) |>
  mutate(across(c(pilot:ship_class, outcome:opp_archetype), ~na_if(., "-"))) |>
  filter(pilot != "-") |>
  mutate(outcome = as.double(outcome))

## Adding ship points to the practice data:
ship_infosheet_short <- ship_infosheet |>
  select(ship, ship_points)

practice_data_days <- left_join(practice_data_days, ship_infosheet_short, by = "ship") |>
  relocate(ship_points, .after = ship)


## Table for re-naming ship classes to long version (by request):
ship_class_rename <- ship_infosheet |>
  select(ship_class, ship_class_full) |>
  distinct()


## Adding the number of ships in our comps (so that comps with <10 ships can be filtered later):
comp_ship_number <- practice_data_days |> 
  select(date, comp, round, ship) |>
  filter(round == 1) |>
  group_by(date, comp) |>
  summarize(n_ships_in_our_comp = n())

practice_data_days <- left_join(practice_data_days, comp_ship_number, by = c("date", "comp"))


## This drops all lines where either side had fewer than 10 ships, and any practices
# that were earlier than the number of days defined by data_starts_from_day (default = 0).
# Used for ship/comp success.

practice_data_filtered <- practice_data_days |>
  filter(days_since_start >= data_starts_from_day) |>
  drop_na(opp_ship1:opp_ship10) |>
  filter(n_ships_in_our_comp == 10) |>
  select(-n_ships_in_our_comp)



### --------------
### Find team member attendance
### --------------

### Finding team member attendance from the entire practice history, unfiltered. Will also
# credit people who flew in or against <10-ship comps.

## For counting rounds flown, the outcome needs to have been recorded. "Days" and "comps"
# will still record attendance for days where outcomes were not recorded. However, people
# who showed up but did not fly any ship will not be counted.

## Number of unique days they attended (and flew a ship):
pilot_days_summary <- practice_data_days |>
  select(date, pilot) |>
  distinct() |>
  group_by(pilot) |>
  summarize(n_days_attended = n())
## *** This needs to be run before some of the other data handling farther down ^

## Total number of comps they flew a ship in:
pilot_comps_summary <- practice_data_days |>
  select(date, pilot, comp) |>
  distinct() |>
  group_by(pilot) |>
  summarize(n_comps_flown = n())

## Total number of rounds they flew a ship in that had a recorded outcome (i.e. multiple
# per comp):
pilot_rounds_summary <- practice_data_days |>
  select(date, pilot, comp, round, outcome) |>
  drop_na(outcome) |>
  distinct() |>
  group_by(pilot) |>
  summarize(n_rounds_flown = n())


## The following numbers are intended for fun because players like seeing them, but they
# are NOT very useful for seeing how skilled a pilot is. They are VERY subject to bias.

# Number of rounds that a pilot won:
pilot_rounds_won <- practice_data_days |>
  select(date, pilot, comp, round, outcome) |>
  distinct() |>
  filter(outcome == 1) |>
  group_by(pilot) |>
  summarize(for_fun_n_rounds_won = n())

# Number of rounds that a pilot lost:
pilot_rounds_lost <- practice_data_days |>
  select(date, pilot, comp, round, outcome) |>
  distinct() |>
  filter(outcome == 0) |>
  group_by(pilot) |>
  summarize(for_fun_n_rounds_lost = n())

# Number of rounds where a pilot survived to the end (NB: practice rounds are often called
# early):
pilot_rounds_lived <- practice_data_days |>
  select(date, pilot, comp, round, fate, outcome) |>
  drop_na(outcome) |>
  distinct() |>
  filter(fate == 1) |>
  group_by(pilot) |>
  summarize(for_fun_n_rounds_lived = n())

# Number of rounds where a pilot did not survive to the end (NB: practice rounds are often
# called early):
pilot_rounds_died <- practice_data_days |>
  select(date, pilot, comp, round, fate, outcome) |>
  drop_na(outcome) |>
  distinct() |>
  filter(fate == 0) |>
  group_by(pilot) |>
  summarize(for_fun_n_rounds_died = n())

# Summary of point costs for ships flown by each player based on the first round of each
# comp - average, minimum, and maximum:
pilot_point_stats <- practice_data_days |>
  filter(round == "1") |>
  group_by(pilot) |>
  summarize(average_ship_cost = round(mean(ship_points), digits = 2), min_ship_cost = min(ship_points), max_ship_cost = max(ship_points))

# Gives the ships a pilot flew the most - tied ships are listed together separated by a
# comma (this gets a bit long with low attendance):
pilot_top_ship <- practice_data_days |>
  select(date, pilot, comp, ship) |>
  distinct() |>
  group_by(pilot, ship) |>
  summarize(n_comps_flown = n()) |>
  slice_max(n_comps_flown) |>
  select(-n_comps_flown) |>
  group_by(pilot) |>
  summarize(top_ship = paste(ship, collapse = ", "))


# Joining all of the composite data frames into one, matched against pilot name:

attendance_table <- left_join(pilot_days_summary, pilot_comps_summary, by = "pilot")
attendance_table <- left_join(attendance_table, pilot_rounds_summary, by = "pilot")
attendance_table <- left_join(attendance_table, pilot_rounds_won, by = "pilot")
attendance_table <- left_join(attendance_table, pilot_rounds_lost, by = "pilot")
attendance_table <- left_join(attendance_table, pilot_rounds_lived, by = "pilot")
attendance_table <- left_join(attendance_table, pilot_rounds_died, by = "pilot")
attendance_table <- left_join(attendance_table, pilot_point_stats, by = "pilot")
attendance_table <- left_join(attendance_table, pilot_top_ship, by = "pilot")


## Creating the final summary table

# *** NOTE: Removes all pilots with attendance lower than what you set with
# "min_attendance" in the Variable set-up section. This is useful since people with low
# attendance will often have very biased win percents (and they can get annoying about it).

# Replaces all NA values with 0, adds win % and survival % - but ONLY for pilots with
# attendance higher than what you set with "min_attendance" in the Variable set-up section.

attendance_and_pilot_stats <- attendance_table |>
  mutate(across(starts_with("for_fun_") | starts_with("n_rounds_") , ~replace_na(., 0))) |>
  mutate(for_fun_win_percent = ifelse((n_days_attended >= min_attendance), (round(for_fun_n_rounds_won/(for_fun_n_rounds_won + for_fun_n_rounds_lost)*100)), NA)) |>
  mutate(for_fun_survival_percent = ifelse((n_days_attended >= min_attendance), (round(for_fun_n_rounds_lived/(for_fun_n_rounds_lived + for_fun_n_rounds_died)*100)), NA)) |>
  select(-c(for_fun_n_rounds_won:for_fun_n_rounds_died))


## Export as file:

write_csv(attendance_and_pilot_stats, "ATXXI_pilot_attendance_stats.csv")


### --------------
### Find who flew which ships the most
### --------------

## First, filtering the data to remove all pilots with attendance lower than what you set
# with "min_attendance" in the Variable set-up section. People with low attendance are not
# useful to see in the ship stats. Requires pilot attendance to be run first.

practice_data_min_attendance <- left_join(practice_data_days, pilot_days_summary, by = "pilot") |>
  filter(n_days_attended >= min_attendance) |>
  drop_na(outcome)


## This table gives you columns with each ship, and pilots on rows. This lets you find who
# has the most experience with a ship (based on comps, not repeated rounds for comps).

top_pilots_for_ship <- practice_data_min_attendance |>
  group_by(pilot, ship) |>
  summarize(n_comps_flown = n()) |>
  ungroup() |>
  arrange(ship) |>
  pivot_wider(names_from = ship, values_from = n_comps_flown, values_fill = 0)


## Export as file:

write_csv(top_pilots_for_ship, "ATXXI_top_pilots_for_ship.csv")



## This table is the reverse of the above, and gives you columns with each pilot, and
# ships on rows. This lets you find what ship a pilot has the most experience with (based 
# on comps, not repeated rounds for comps).

top_ships_for_pilot <- practice_data_min_attendance |>
  group_by(pilot, ship) |>
  summarize(n_comps_flown = n()) |>
  pivot_wider(names_from = pilot, values_from = n_comps_flown, values_fill = 0) |>
  ungroup() |>
  arrange(ship) 


## Export as file:

write_csv(top_ships_for_pilot, "ATXXI_top_ships_for_pilot.csv")



### --------------
### Summarize practices vs. opponents
### --------------
  
  
## Number of days flown against opponent teams, and win rates vs. those teams.


team_days_played_against <- practice_data_days |>
    select(date, opponent) |>
    distinct() |>
    group_by(opponent) |>
    summarize(n_days_played_against = n())
  
team_rounds_won_against <- practice_data_days |>
    select(date, opponent, comp, round, outcome) |>
    distinct() |>
    filter(outcome == 1) |>
    group_by(opponent) |>
    summarize(n_rounds_we_won = n())
  
team_rounds_lost_against <- practice_data_days |>
    select(date, opponent, comp, round, outcome) |>
    distinct() |>
    filter(outcome == 0) |>
    group_by(opponent) |>
    summarize(n_rounds_we_lost = n())


## Joining all of the composite data frames into one, matched against team name:
  
opponent_matchup_table <- left_join(team_days_played_against, team_rounds_won_against, by = "opponent")
opponent_matchup_table <- left_join(opponent_matchup_table, team_rounds_lost_against, by = "opponent")

  
## Creating the final summary table, replacing all NA values with 0 and adding win % based
# on number of rounds flown
  
opponent_matchup_summary <- opponent_matchup_table |>
  mutate(across(starts_with("n_rounds_") , ~replace_na(., 0))) |>
    mutate(our_win_percent = round(n_rounds_we_won/(n_rounds_we_won + n_rounds_we_lost)*100))


## Export as file:

write_csv(opponent_matchup_summary, "ATXXI_opponent_matchups.csv")
  
 
### --------------
### Find opponent comps
### --------------

### Finding all opponent comps, excluding all comps with fewer than 10 ships


## Retrieve all unique opponent comps (by date and comp #) and then transform from wide 
# to long:

all_opponent_comps <- practice_data_filtered |>
  select(date, days_since_start, comp, round, outcome, opponent, opp_ship1:opp_ship10, opp_archetype, opp_took_flag, opp_bans1, opp_bans2, opp_bans3) |>
  mutate(date = ymd(date)) |>
  filter(days_since_start >= data_starts_from_day) |>
  distinct() |>
  pivot_longer(cols = opp_ship1:opp_ship10, names_to = "number", values_to = "ship")
  

all_opponent_comps <- left_join(all_opponent_comps, ship_infosheet, by = "ship") |>
  select(-ship_class) |>
  relocate(c(ship:ship_class_full), .after = days_since_start) 


## Get all opponent comps; if the opponent switched a ship in a comp, both ships will be
# shown, separated by a comma:

unique_opponent_comps <- all_opponent_comps |>
  select(-c(round:outcome)) |>
  distinct() |>
  group_by(date, opponent, comp, opp_bans1, opp_bans2, opp_bans3, number) |>
  summarize(opponent_ship = paste(ship, collapse = ", ")) |>
  select(-number) |>
  relocate(opponent_ship, .after = comp)
  

## Export as file:

write_csv(unique_opponent_comps, "ATXXI_opponent_comps.csv")


### --------------
### Ship success rates - data setup
### --------------


## Building a combined dataset with both our own comps and the opponents' on their own
# lines. To be used for multiple different things later.

# Our comps:
our_ship_data <- practice_data_filtered |>
  drop_na(outcome) |>
  select(date, days_since_start, ship, ship_class, comp, round, outcome, our_archetype, we_took_flag, our_bans1, our_bans2, our_bans3) |>
  rename(archetype = our_archetype,
         took_flag = we_took_flag,
         ban1 = our_bans1,
         ban2 = our_bans2,
         ban3 = our_bans3) |>
  mutate(comp_owner = "ours")

our_ship_data <- left_join(our_ship_data, ship_class_rename, by = "ship_class") |>
  relocate(ship_class_full, .after = ship) |>
  select(-ship_class)


# Our opponents' comps:
opp_ship_data <- all_opponent_comps |>
  select(-ship_points, -opponent, -number) |>
  rename(archetype = opp_archetype,
         took_flag = opp_took_flag, 
         ban1 = opp_bans1,
         ban2 = opp_bans2,
         ban3 = opp_bans3) |>
  mutate(comp_owner = "opponent") |>
  mutate(outcome = ifelse(outcome == 1, 0, 1))


## Combined! NB: Both tables MUST have the same columns.

all_ship_data <- rbind(our_ship_data, opp_ship_data)


### --------------
### Ship success rates for us, our opponents, and total
### --------------

### In this section, I find the number of days and rounds (i.e. multiple matches per comp)
# that ships have been used, and calculate a win rate based on the outcome of rounds. This
# is done for our team, the opponent team, and for the total (ours + opponents') success of
# that ship hull. Wins are considered from the perspective of who was flying the ship, so
# note that the total might be affected by mirror matches. These three subsets are
# combined into one table for export.


## Our ship stats

our_ship_success <- all_ship_data |>
  filter(comp_owner == "ours")

## Number of unique days a ship was used:
our_ship_days_summary <- our_ship_success |>
  select(date, ship) |>
  distinct() |>
  group_by(ship) |>
  summarize(our_n_days_used = n())

## Total number of rounds flown with a ship (repeat matches per comp):
our_ship_rounds_summary <- our_ship_success |>
  select(date, ship, comp, round) |>
  distinct() |>
  group_by(ship) |>
  summarize(our_n_rounds_used = n())

## Number of rounds won with a ship:
our_ship_rounds_won <- our_ship_success |>
  select(date, ship, comp, round, outcome) |>
  distinct() |>
  filter(outcome == 1) |>
  group_by(ship) |>
  summarize(n_rounds_won = n())

## Number of rounds lost with a ship:
our_ship_rounds_lost <- our_ship_success |>
  select(date, ship, comp, round, outcome) |>
  distinct() |>
  filter(outcome == 0) |>
  group_by(ship) |>
  summarize(n_rounds_lost = n())


our_ship_win_rate <- left_join(our_ship_rounds_summary, our_ship_rounds_won, by = "ship")
our_ship_win_rate <- left_join(our_ship_win_rate, our_ship_rounds_lost, by = "ship") 

our_ship_win_rate <- our_ship_win_rate |>
  mutate(n_rounds_won = replace_na(n_rounds_won, 0),
         n_rounds_lost = replace_na(n_rounds_lost, 0)) |>
  mutate(our_win_percent = round(n_rounds_won/our_n_rounds_used * 100)) |>
  select(-c(n_rounds_won:n_rounds_lost))



## Opponent ship stats

opp_ship_success <- all_ship_data |>
  filter(comp_owner == "opponent")

## Number of unique days a ship was used:
opp_ship_days_summary <- opp_ship_success |>
  select(date, ship) |>
  distinct() |>
  group_by(ship) |>
  summarize(opp_n_days_used = n())

## Total number of rounds flown with a ship (repeat matches per comp):
opp_ship_rounds_summary <- opp_ship_success |>
  select(date, ship, comp, round) |>
  distinct() |>
  group_by(ship) |>
  summarize(opp_n_rounds_used = n())

## Number of rounds won with a ship:
opp_ship_rounds_won <- opp_ship_success |>
  select(date, ship, comp, round, outcome) |>
  distinct() |>
  filter(outcome == 1) |>
  group_by(ship) |>
  summarize(n_rounds_won = n())

## Number of rounds lost with a ship:
opp_ship_rounds_lost <- opp_ship_success |>
  select(date, ship, comp, round, outcome) |>
  distinct() |>
  filter(outcome == 0) |>
  group_by(ship) |>
  summarize(n_rounds_lost = n())


opp_ship_win_rate <- left_join(opp_ship_rounds_summary, opp_ship_rounds_won, by = "ship")
opp_ship_win_rate <- left_join(opp_ship_win_rate, opp_ship_rounds_lost, by = "ship") 

opp_ship_win_rate <- opp_ship_win_rate |>
  mutate(n_rounds_won = replace_na(n_rounds_won, 0),
         n_rounds_lost = replace_na(n_rounds_lost, 0)) |>
  mutate(opp_win_percent = round(n_rounds_won/opp_n_rounds_used * 100)) |>
  select(-c(n_rounds_won:n_rounds_lost))



## Combined ship stats (for both ours + the opponent's)

## Number of unique days a ship was used:
total_ship_days_summary <- all_ship_data |>
  select(date, ship) |>
  distinct() |>
  group_by(ship) |>
  summarize(total_n_days_used = n())

## Total number of rounds flown with a ship (repeat matches per comp):
total_ship_rounds_summary <- all_ship_data |>
  select(date, ship, comp, round) |>
  distinct() |>
  group_by(ship) |>
  summarize(total_n_rounds_used = n())

## Number of rounds won with a ship:
total_ship_rounds_won <- all_ship_data |>
  select(date, ship, comp, round, outcome) |>
  distinct() |>
  filter(outcome == 1) |>
  group_by(ship) |>
  summarize(n_rounds_won = n())

## Number of rounds lost with a ship:
total_ship_rounds_lost <- all_ship_data |>
  select(date, ship, comp, round, outcome) |>
  distinct() |>
  filter(outcome == 0) |>
  group_by(ship) |>
  summarize(n_rounds_lost = n())


total_ship_win_rate <- left_join(total_ship_rounds_summary, total_ship_rounds_won, by = "ship")
total_ship_win_rate <- left_join(total_ship_win_rate, total_ship_rounds_lost, by = "ship") 

total_ship_win_rate <- total_ship_win_rate |>
  mutate(n_rounds_won = replace_na(n_rounds_won, 0),
         n_rounds_lost = replace_na(n_rounds_lost, 0)) |>
  mutate(total_win_percent = round(n_rounds_won/total_n_rounds_used * 100)) |>
  select(-c(n_rounds_won:n_rounds_lost))



## Joining all of the composite data frames into one, matched against ship name:

ship_use_table <- left_join(total_ship_days_summary, total_ship_win_rate, by = "ship")
ship_use_table <- left_join(ship_use_table, our_ship_days_summary, by = "ship")
ship_use_table <- left_join(ship_use_table, our_ship_win_rate, by = "ship")
ship_use_table <- left_join(ship_use_table, opp_ship_days_summary, by = "ship")
ship_use_table <- left_join(ship_use_table, opp_ship_win_rate, by = "ship")


## Creating the final summary table

# Replaces all NA values for ship use (but not win rate) with 0.

# *** NOTE: Ships that have not been used much will have more biased win percentages.


ship_use_summary <- ship_use_table |>
  mutate(across(ends_with("n_days_used") | ends_with("n_rounds_used"), ~replace_na(., 0)))


# Export as file:

write_csv(ship_use_summary, "ATXXI_ship_use_summary.csv")
 
 
 
### --------------
### Ship vs. ship match-ups
### --------------
 
## What ships lose against - excluding any opponent comp that only has 9 ships.
# For best results, look at the same ship from the perspective of both sides 
# for any patterns that re-appear. 
 
# NB: Ships that are often taken together with other ships will affect the win-rate of
# that ships, so also consider whether it's that specific ship that's good/bad, or 
# actually a different ship that's usually taken with it.
 
## Data transformation:
ship_v_ship_data <- practice_data_filtered |>
  drop_na(outcome) |>
   mutate(round_id = paste(opponent, days_since_start, comp, round, sep = "-")) |>
   select(round_id, ship, outcome, opp_ship1:opp_ship10) |>
   pivot_longer(cols = opp_ship1:opp_ship10, names_to = "number", values_to = "opp_ship") |>
   select(-number)


## Total number of rounds flown with each ship vs. another ship (repeat matches per comp):
 ship_v_ship_rounds_summary <- ship_v_ship_data |>
   select(round_id, ship, opp_ship) |>
   distinct() |>
   group_by(ship, opp_ship) |>
   summarize(n_rounds_used = n())

## Number of rounds won with a ship vs. another ship:
 ship_v_ship_rounds_won <- ship_v_ship_data |>
   select(round_id, ship, opp_ship, outcome) |>
   distinct() |>
   filter(outcome == 1) |>
   group_by(ship, opp_ship) |>
   summarize(n_rounds_won = n())

## Number of rounds lost with a ship vs. another ship:
 ship_v_ship_rounds_lost <- ship_v_ship_data |>
   select(round_id, ship, opp_ship, outcome) |>
   distinct() |>
   filter(outcome == 0) |>
   group_by(ship, opp_ship) |>
   summarize(n_rounds_lost = n())



## Joining all of the composite data frames into one, matched against both your team's
 # ship name AND the opponent's ship:
 
 ship_v_ship_table <- left_join(ship_v_ship_rounds_summary, ship_v_ship_rounds_won, by = c("ship", "opp_ship"))
 ship_v_ship_table <- left_join(ship_v_ship_table, ship_v_ship_rounds_lost, by = c("ship", "opp_ship"))
 
 
 
## Creating the final summary table
 
# *** NOTE: This step has filtered out any ship that hasn't been used against another
 # specific ship more than 4 rounds; really it could even be higher than that. The more
 # times two ships have faced off, the better - consider, 4 rounds is really only two 
 # best-of-3 matches that didn't go to round 3!
 
 
 ship_v_ship_summary <- ship_v_ship_table |>
   mutate(across(starts_with("n_rounds_") , ~replace_na(., 0))) |>
   filter(n_rounds_used > 4) |> # <- change this if you want to change the minimum # of rounds
   mutate(our_win_percent = round(n_rounds_won/(n_rounds_won + n_rounds_lost)*100)) |>
   select(-c(n_rounds_won:n_rounds_lost))
 
 
# Export as file:
 
 write_csv(ship_v_ship_summary, "ATXXI_ship_v_ship.csv")
 
 
### More coming Soon(TM), but I wanted to at least get these parts out first!
 