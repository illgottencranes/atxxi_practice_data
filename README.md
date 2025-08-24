# atxxi_practice_data

This ReadMe goes along with Arian’s AT Practice Organizer and is intended for the data handling aspect of my spreadsheet. I hope that I can give enough guidance here that a motivated and computer-savvy person could run my code without having a lot of background knowledge. 

I can’t teach you how to use the software, but I can point you toward a decent guide to start with and at least be able to run the code provided. The programs I use, R and Rstudio, are free and open-source, so there are also a lot of guides available for basically any issue. 


_Contents:_

* Section 1 - General definitions, how to prepare the data, which bits are more important to fill out
* Section 2 - Link to the guide, how the code is organized, what to do with the files after
* Section 3 - Longer descriptions of what’s in each .csv produced by the code

**More features will be added later!** I just wanted to get this part out (hopefully) in time for the feeders. :)


## 1.0 - Definition of terms

For clarity, here are some definitions for words I use a lot:

- Comp & comp number: A set of ships flown vs. another set of ships in a match, until the teams move on to the next set. The comp number re-sets each day starting at 1.

- Round & round number: Each played match in a comp. E.g., a best-of-1 will always have 1 round, and a best-of-3 will usually have 2 or 3 rounds. The round number re-sets for each comp starting at 1.


## 1.1 - Preparing the data

You will need two files with data: the ATXXI ship stats sheet (including points costs), and your own practice data file.

There is a section on the bottom of my practice spreadsheet that collects the data as you fill it in above. Once you are done with practice (or even a live match) and have everything filled in above, scroll down to the data section, select all, and copy + paste as values.

Next, copy the table again and paste it into a new spreadsheet that is ONLY for data. This spreadsheet should have the column names once at the top, and then each new day gets pasted below, all in one big long table. The order of the days doesn’t matter.

If you did this in Google docs, download the file as either a .xlsx or .csv format. You don’t need to be able to open the file on your computer, so .xlsx is slightly easier in some ways. .csv is fine, but you might have to change something in my provided code depending on if your computer uses commas or semicolons for .csv files (I do tell you how to do it).

Download the ship info sheet in the same format, either from this github directory or from here:

https://docs.google.com/spreadsheets/d/1_jluXwlp77uf3dzezWtlnEwlQ3MGNuoqCE6Zgc8TDXg/edit?usp=sharing 

> [!NOTE]
> Don’t change the names of the columns unless you know what you’re doing.


## 1.2 - Things that are important to have filled out

SKIP READING IF: you always fill out everything anyway.

> [!NOTE]
> Extra care is needed if you have multiple practices on the same date.

- Date: You need this so that it’s possible to get a unique value for date + comp #, and for attendance. Entered at the top of the page. Writing the date as YYYY/MM/DD will basically always work in a spreadsheet. 

- Comp #: Every comp played on the same date should have a unique number. This is set in a drop-down menu next to each comp.

- Pilot names: For attendance and finding who has the most experience with which ships. Use the drop-down menus so that names are consistent.

- Ships: Kind of obvious; both yours and the opponents’.

- Outcome: You need to have scored each match that you played. Only winning and losing are scored.

- _(Optional)_ Ship fate: Marking ships as lost will record the fate of your ships (but not the opponents’) by the end of the match. This is nice to have, but my code only uses this for fun.

- _(Optional)_ Opponent: You can fill out the opponent name from the dropdown on the top of the practice organizer for stats against teams, but this is still only a “nice to have”.

- _(Optional)_ Comp archetype: For you and/or your opponent. My code using this will be available later IF you want to work with it. It’s more important to be consistent about your definition of the archetype than to be 100% accurate.

- _(Optional)_ Bans: I assume you’ll be doing this anyway. Code planned for later.


## 1.3 - Things you might have to fill out manually (sorry)

- Pilot changes between rounds of the same comp: so that they both get credit.

- Ship changes between rounds of the same comp: same issue as pilots, but needs to be done for both your ships and the opponents’. Most of my data handling will report all unique combinations for scored matches (except for your team members’ top ships).

- Extra rounds beyond 3 or 4 (depending on version) - When first released publicly my sheet only went to round 3, now it goes to round 4. If you have MORE rounds than this, you will either need to insert more rows, or use the bonus comp 5 section. If you insert more rows, copy + paste as values from the section above, change the outcome (and possibly ship fates) manually, and (IMPORTANT) change the number in the “round” column (e.g. to 4 or 5). If you use the bonus comp 5 section for this, you could leave it as comp 5.


## 2.0 - Setting up with R and Rstudio

Everything that I’ll have you install is something that is used in science, and runs entirely on your own computer.

This guide is pretty good and is for teaching people who are coming from a non-statistics background:

https://biostats-r.github.io/biostats/workingInR/

** Important sections, pick and choose the sub-sections: 2, 3, 4, the start of 5, 8, 11

Your goal in reading the guide is to be able to set up the two programs you need, know where to put the files and how to import them into Rstudio, and know how to run the code provided and how to view objects in the code if needed. So, don't feel like you need to memorize and understand _everything_ even in those sections I listed.

If you DO want to learn more about what’s being done in the code and how to make more advanced edits, this is in sections 12-15. :)


## 2.1 - The code

The code is set up into sub-sections that can be collapsed and hidden, with names for the sub-sections. There are more descriptions and some instructions in the comments of the code. I usually run one section at a time. If there is an error, the program will generally stop at that point. 

The sections should be run in order, since some of them use objects that were created in an earlier section. There are a couple variables I’ve marked with “YOU DECIDE” that you can set yourself, or you can leave them as their default.

Some sections are for setup, and other sections end by writing a .csv file. You can find the files created by the code in the same folder as the source files.

> [!NOTE]
> #1: Writing the .csv file will write over any previous file with the same name!
>
> #2: If you have added more columns or changed some column names, you will likely get errors in the code.


## 2.2 - What to do with the files it produces

I recommend copy + pasting these into one or more new Google Sheets documents, depending on what you want to share with your team. The best way to view the files is by selecting the newly-pasted table and creating a filter. You can only make one filter per page in a Google Sheets document, so each .csv should be pasted in a different page.

Creating a filter will let you sort by different columns. Each time you sort the filtered table, it adds on to the previous time. For example: if you sort by win % and then ship type in the ship vs. ship matchup table, the ships will be arranged first in alphabetical order and then by win %. You can also set the filter to show only one ship or a few specific ships, which can make the table easier to view if it’s very long.

Here is a Google sheet that you can use as a starting point; except for the two ship use pages, you can keep the column names I’ve provided:

https://docs.google.com/spreadsheets/d/1wQqDLr8CN69by_72SFghILRLyyfRHDhM4kX9ajhumgE/edit?usp=sharing 


## 3.0 - Overview of the produced files

A lot of this is described in the code, but this is mainly an overview of what the various tables are.

_Working variables:_

- days_since_start - Some tables will have this column, especially the intermediate steps. This is the number of days since the earliest recorded practice and is basically just replacing the date. R can be picky about dates so I’d rather not make you deal with them.

- data_starts_from_day - You can set this value in the “Variable set-up” section. By default I have this set to 0. This number will be compared to the “days_since_start” value. You can change this number so that any section using the object named “practice_data_filtered” will start at a later date (after feeders, for example).

- min_attendance - You can set this value in the “Variable set-up” section. By default I have this set to 6. This will limit which pilots are included for some things, but total attendance will still be displayed for everyone. Smaller or more casual teams will probably want to set a lower minimum, while larger or more elite teams may want to set a higher minimum.


## 3.1 - Team member attendance

_Output:_ attendance_and_pilot_stats, "ATXXI_pilot_attendance_stats.csv"

This table is meant to be shared with your team, and includes several things that are just for fun!


_Columns:_

- pilot - Pilot name; check this to make sure that each person only appears once. If there are multiples, change them in the source file.

- n_days_attended - Number of unique calendar days they attended *and flew a ship*

- n_comps_flown - Total number of comps they flew a ship in (see definitions in section 1.0 above)

- n_rounds_flown - Total number of rounds they flew a ship in that had a recorded outcome (i.e. multiple per comp)

- average_ship_cost - Average point cost of the ships the pilot flew based on round 1 of each comp

- min_ship_cost, max_ship_cost - Minimum and maximum point costs of ships the pilot flew

- top_ship - The ships a pilot flew the most; tied ships are listed together separated by a comma

- for_fun_win_percent - FOR FUN ONLY, the win % based on rounds with recorded outcomes. Only shown for pilots with higher attendance than the minimum.

- for_fun_survival_percent - FOR FUN ONLY, the survival % based on ships that were registered as having lived or died by the end of the match in rounds with recorded outcomes. Only shown for pilots with higher attendance than the minimum.

> [!CAUTION]
> The pilot win % and survival % are NOT an indication of how well the pilot flew!
>
> The highest win % will often be held by someone with low attendance because they missed days with more losses than average. Meanwhile, survival % depends a lot on which ships a pilot likes to fly.

So how DO you tell which pilots were empirically better in practice than others? There is no easy way to get that information, unfortunately. Or at least, this is a very different area of statistics than what I know. This would also require a larger number of practices than most teams are likely to have done.


## 3.2 - Pilot ship experience

This section has two outputs, and both of them exclude any pilot with attendance lower than the minimum you can set in the “Variable set-up” section. They both count each comp once, but include ship changes if these were recorded.

_Output:_ top_pilots_for_ship, "ATXXI_top_pilots_for_ship.csv"

This table gives you columns with each ship at the top, and pilots on rows. This lets you find who has the most experience with a specific ship hull. 

_Output:_ top_ships_for_pilot, "ATXXI_top_ships_for_pilot.csv"

This table is the reverse of the above; the ships are on rows, and the columns are pilots. This gives you a better overview of each pilot’s total experience. You can use this to assign pilots to general roles, rather than specific ships like the previous table.

These tables are also popular with team members! They love seeing the actual numbers on which ships everyone’s been flying. :) 


## 3.3 - Summarize practices vs. opponents

This section gives you a summary of how often you’ve flown against different opponent teams and your performance against that team. This may be useful since you learn the most by practicing against teams that are better than you.

_Output:_ opponent_matchup_summary, "ATXXI_opponent_matchups.csv"


_Columns:_

- opponent - The name of the opponent team as you recorded it. Check to make sure that each team name only appears once. If there are multiples, change them in the source file.

- n_days_played_against - Number of unique calendar days you practiced against that team

- n_rounds_we_won, n_rounds_we_lost - Number of rounds you won or lost vs. that team based on rounds with recorded outcomes

- our_win_percent - Your team’s win percent against the opponent team.


## 3.4 - List of opponent comps

This section shows you a history of all opponent comps taken against you in a line-by-line form instead of all in one row, excluding any comps that had fewer than 10 ships, as well as their bans.

_Output:_ unique_opponent_comps, "ATXXI_opponent_comps.csv"


_Columns:_

- date, opponent, comp - the calendar date and opponent, and the comp number

- opponent_ship - The opponent’s ship. NB: If the opponent changed a ship between rounds and this was recorded, BOTH ships will be listed in the same line, separated by a comma. Because of how the opponent_ship variable is generated, this table should not be used for analysis. 

- opp_bans1, opp_bans2, opp_bans3 - The opponent’s bans for the comp. Bans will be addressed more as their own thing later.


## 3.5 - Ship success rates

These sections do a bit of elaborate setup, and then give you a table that shows how often each ship was used (using # days), how many rounds the ship was used, and the % win rate for the ship (keeping in mind the # of rounds). Each ship is only counted in a comp once, even if there are multiples. These numbers are given in three categories: combined for you and your opponents, only for you, and only for your opponents.

> [!NOTE]
> Keep in mind that success with a particular ship can be influenced by the other ships it’s flown with!

_Output:_ ship_use_summary, "ATXXI_ship_use_summary.csv"


_Columns:_

- Starts with “total_” - combined ship use numbers for both you and your opponents, your wins and their wins for that ship combined.

- Starts with “our_” - ship use numbers for you, your wins with that ship.

- Starts with “opp_” - ship use numbers for your opponent, their wins against you with that ship.


## 3.6 - Ship vs. ship matchups

This section shows how successful specific ships have been when you’ve flown them against ships flown by your opponents in repeated matchups (e.g. your Abaddon vs. their Deacon). Ships are only counted once per comp, even with multiples. 

Using a filter for sorting is particularly important for this one. I recommend checking the win % for both your ships (e.g. all your Abaddon matchups) AND for your opponent (e.g. all of your opponents’ Abaddon matchups). If you see that the same ships show up as good or bad matchups for both sides, it might be a real pattern!

> [!NOTE]
> Keep in mind that success with a particular ship can be influenced by the other ships it’s flown with!

_Output:_ ship_v_ship_summary, "ATXXI_ship_v_ship.csv"


_Columns:_

- ship, opp_ship - The ship flown by you, and the ship flown against it by your opponent.

- n_rounds_used - The number of rounds the matchup occurred (with a recorded outcome). The more often the two ships have faced each other, the closer to being reliable the win % will be. I have set a minimum of 5 rounds for the matchup to be shown at all, but this is still pretty low!

- our_win_percent - the percent of rounds you won in that matchup.

