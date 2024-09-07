# Overview

This repos is meant to facilitate tracking team results for Splatoon 3 matches.

So, if you were interested in a different squid game, this isn't for you.

But, if you want to track results for a Splatoon 3 league, maybe this is for you.

Briefly, the input is essentially scoreboard results with a metadata row giving the results for the set.

And, the output basically recreates the scoreboards, in addition to giving information about weapon usage and things like K/D and Assists.


# Tables and Figures

The html is organized into tabs, so below is the list of tabs that have tables and figures

* Overview
  * Overview Table - Opponent team name, match date, scores, and maps with modes
  * Mode Summary - Bar plot showing percents for wins/losses per mode
* Heatmap
  * Heatmap of weapon usage for each match
  * Also gives maps, modes, and match result 
* Players
  * Weapons Overview Table - Number of matches and win ratio and averages and totals for Points, Splats, Kills, Assists and totals for Deaths
    * Splats refers to value after Points given in the scoreboard
    * Kills is the difference between that and the number in <>
  * Weapons Details Table - Per match results for each weapon
  * Weapons Usage - Tree map grouped by Weapon Class and Special
* Scoreboards
  * Scoreboards Table  - Recreation of Splatoon 3 scoreboards w/ Date and Opponent Team name added
* PSL Player Stats
  * PSL Player Stats Per Set Table - Per set summary for each player, includes totals for games played, Kills, Assists, Deaths, and Specials used
    * Also includes points for Turf War
    * Includes opponent team name and date too
  * PSL Player Stats Table - Running total of Matches, Games, Kills, Assists, Deaths, Specials, and Turf Inked based on all input data
* PSL Weapon Usage Table - Names of weapons used for each mode

# Setup

1. Install R and RStudio
* See [here](https://moderndive.com/1-getting-started.html#installing) for install instructions 
* That's a pretty good textbook for learning R, but besides the install instructions, you don't need it


2. Download this respository
* If you have `git` installed, you can use `git clone https://github.com/jcbioinformatics/Squid-Game-Scores.git`
* Otherwise, click the green `Code` button, choose `Download Zip`, and decompress the resulting download

![image](https://github.com/user-attachments/assets/9fdeefd0-5ceb-45ab-b92e-ad30e164bfd8)


3. Open the Squid-Game-Scores.Rmd file with RStudio
* You may have to right-click on the file and specify RStudio


4. Install the needed packages by clicking on `Install` in the yellow ribbon


5. Run the Rmd by clicking `Knit`

![image](https://github.com/user-attachments/assets/adcda2bf-cd4c-4656-ad3a-2718269f816c)


It should run and produce a popup window for the resulting html file. 

You are now ready to start using your own data. 


# Running the Rmd With Your Data

1. Transcribe Splatoon 3 results into the expected format.
* See Input Data Format section for what those need to look like


2. Put all the results files into the same subfolder


3. Add your roster file to `Rmd_Resources`
* It should be a two column text tab delimited file, with the first column (`Player`) being the player name and the second column (`Alias`) being their name in the match
* This basically accounts for cases where the same player changed their name, as shown with "Player-2" [here](Rmd_Resources/example_roster.txt)


4. In [Rmd_Resources/squid-game-scores.css](Rmd_Resources/squid-game-scores.css), change the hexcodes for the `:root` variables

![image](https://github.com/user-attachments/assets/c0ef64de-4fa7-4e6a-9c6b-5cbe8676a3b8)
* Depending on the text editor used, it may look very different. The above screenshot was taken with it open in [VS Code](https://code.visualstudio.com/download)
* The important thing is to change the hexcodes in that section as desired


5. Open up the `Squid-Game-Scores.Rmd` file 
* We're going to change some of the values at the very top of the file
* **Everything we're changing in the Rmd is in double-quotes, so after changing those values, make sure they are still quoted**


6. Change "JC Gold" to the name of your team


7. Change the path to the `logo` to yours
* The default is a blue rose I drew in one shot
* Feel free to keep using that, but if you use yours, the largest dimension should be 48 px
* You can rescale your logo using [Gimp](https://www.gimp.org/tutorials/GIMP_Quickies/#changing-the-size-dimensions-of-an-image-scale)


8. Change the paths to `input_scores_folder` and `input_roster_aliases`
* The value of `input_scores_folder` should be the path to the folder containing your results files
* The path to `input_roster_aliases` should be the roster file you added to `Rmd_Resources`


9. Change the names associated with `players_order` to the ones in your roster file
* They should be comma separated
* The order of the names will be maintained


10. If needed, change the values of `results-string` to something all of your results files have in their name
* If they're saved as text tab-delimited the extension should be either "txt" or "tsv"
* So, if they're the only files in the subfolder used as input, you can use whichever extension matches your data


11. Click `Knit` to process your data


12. The resulting html file can be opened with any web browser


# Input Data Format

![image](https://github.com/user-attachments/assets/0092cfbb-1b90-4113-a695-68a48ab04150)


The weapon names need to match the name what's in [here](Rmd_Resources/weapons-metadata.txt) exactly.

It's essentially based in the [Wiki table](https://splatoonwiki.org/wiki/List_of_weapons_in_Splatoon_3), with the following modifications
* Single quotes were removed
* Periods at the end of the names were removed
* 0 was added to weapons that start with periods
* Spaces were changed to dashes


**None of the values entered in this table should be quoted**

Please see [this folder](Input_Scoreboard_Data) for example input data

The first row under the header is essentially metadata. 

![image](https://github.com/user-attachments/assets/2c6bd24d-e661-4869-965b-4b89d352d830)

This is referred to as "Summary". 

In this row, just change "Result", "Opponent_Team", and "Date"
* "Result" is your team's score and the opposing team's score separated by an underscore
* "Opponent_Team" is the identifier for the opposing team
* "Date" is month, day, and year separated by underscores
  * Month should always be given as two digits
  * Day also should always be given as two digits
  * Year should be four digits
    * January 9, 2024 would be written as "01_09_2024" without the quotes

* The other rows are per game results
  * "Result" should be one of: "Win", "Loss", "Win-Overtime", or "Loss-Overtime"
  * In the "Knockout" column, write "Y" without quotes if the game was a knockout
  * Enter "Opponent_Team" and "Date" as before
  * Enter "Map" and "Mode" for the match
  * "Team-Stats" should contain the results for the team that you're tracking
 ![image](https://github.com/user-attachments/assets/2d46e264-63e1-4d3f-81f0-4b594b753549)
    * Per player information is comma separated
    * For each player...
      * The first field is the player's name followed by a colon
      * The next field is the name of their weapon
      * The remaining fields are separated by underscores
      * These are the numerical values in the same order as they were on the Splatoon 3 scoreboard: POINTS_SPLATS_ASSISTS_DEATHS_SPECIALS
        * Make sure to put 0 for cases when there's no number next to splats on the scoreboard
  * "Opposing-Stats" follows the same format
  * The "Number" column should be a unique numerical identifier per game, so in the example data, I used 1-5
  * Lastly, all per game results rows should have a value of "Game" in the "Type" column


# Common Errors

Check that the settings at the top of the file match what they should

Next, check your input data. 

The most common issue for me is missing a field, usually Assists when someone got 0.

You also may have used a dash instead of an underscore


# Notes

If the input data format looks kinda familiar, it might be because it's very similar to .vcf format, except instead of having all individuals in one column, they're split into two, one for the team that you're tracking (`Team-Stats`) and one for their opponents (`Opposing-Stats`).

Speaking of, in theory, the Rmd should be able to handle cases of 4 vs 3 or 3 vs 4 without issue. However, none of the test data currently tests that scenario. 

Feel free to submit Issues for feature requests. I'll do my best to incorporate things if/when they come up. 

Also, please let me know if anything isn't working properly. 
