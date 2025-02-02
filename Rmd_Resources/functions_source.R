##########################################################
# Define functions used in Splatoon 3 logging

# Excel loading function is modified from https://www.geeksforgeeks.org/how-to-read-a-xlsx-file-with-multiple-sheets-in-r/
multiplesheets <- function(fname, res_string) { 
  
  # Get vector of sheet names
  sheets <- excel_sheets(fname)
  
  # Filter sheets names to just include results
  if (!is.na(res_string)) {
    sheets <- sheets[grepl(res_string, sheets)]  
  }
  
  # Load sheets in as separate tibbles in a list
  tibble <- lapply(sheets, function(x) readxl::read_excel(fname, sheet = x)) 
  
  # Convert to data frames
  data_frame <- lapply(tibble, as.data.frame) 
  
  # Assign names to data frames 
  names(data_frame) <- sheets 
  
  return(data_frame) 
} 


# Parser function for the two weapons columns
# P1:W1,P2:W2...
parseWeapons <- function(table, col, res_names){
  res_t_parsed <- table %>%
    dplyr::select(all_of(c("Result", "Opponent_Team", "Date", "Map", "Mode", col))) %>%
    separate_rows(!!col, sep = ",") %>%
    separate(!!col, into = res_names, sep = ':', convert = T)  
  
  return(res_t_parsed)
}


# Parser function for the stats column
# P1:XX_YY_ZZ_AAA,P2:BBB,CCC,DDD,EEE...
parseStats <- function(table, exclude_columns, split_column, output_columns, first_split_columns, rankCol){
  team_stats <- table %>%
    dplyr::select(-all_of(exclude_columns)) %>%
    separate_rows(!!split_column, sep = ",") %>%
    separate(col = split_column, into = first_split_columns, sep = ":") %>%
    separate(col = first_split_columns[2], into = output_columns, convert = T, sep = '_') %>%
    dplyr::group_by(Map, Mode) %>%
    mutate(Rank = rank(!!as.symbol(rankCol) * -1, ties.method = "first"))
  
  # Replace all empty cells with NA
  team_stats[team_stats == ''] <- NA
  
  # i <- 1
  # for (c in output_columns){
  #   if (i != 1){
  #     team_stats[[c]] <- as.numeric(as.character(team_stats[[c]]))
  #   }
  #   i <- i + 1
  # }
  
  return(team_stats)
}


#######################################################
# V2 parsing, Weapons in same column as stats

parseTableV2 <- function(table_name, tables_w_assists_string, type="txt"){
  #table_name <- "input-results_season_2_Fall_2023/results-10.12.2023.txt"

  #print(table_name)
    
  if (type == "txt") {
    # Read table
    res_t <- read.table(table_name, header = T, sep = "\t", check.names = F)    
  } else {
    res_t <- table_name
  }
  
  # Set all Date and Opponent_Team values based on first row
  res_t$Date <- res_t$Date[1]
  res_t$Opponent_Team <- res_t$Opponent_Team[1]
  
  
  # Make combined game style table
  res_t_games <- res_t %>%
    dplyr::filter(Type == "Game")
  
  # Get individual stats
  if (type == "txt") {
    
    if (!grepl(tables_w_assists_string, table_name)) {
      # Case where table is NOT expected to have assists
      # Split out team stats
      team_stats <- parseStats(table = res_t_games,
                               exclude_columns = c("Opposing-Stats"),
                               split_column = "Team-Stats",
                               first_split_columns = c("Player", "Stats"),
                               output_columns = c("Main", "Points", "Splats", "Deaths", "Specials"),
                               rankCol = "Splats"
      )
      
      # Split out opposing team stats
      opposing_team_stats <- parseStats(table = res_t_games,
                                        exclude_columns = c("Team-Stats"),
                                        split_column = "Opposing-Stats",
                                        first_split_columns = c("Opposing_Player", "Stats"),
                                        output_columns = c("Opposing_Main", "Opposing_Points", "Opposing_Splats", 
                                                           "Opposing_Deaths", "Opposing_Specials"),
                                        rankCol = "Opposing_Splats"
      )        
    }
    
  } else {
    # Case where table IS expected to have assists
    # Split out team stats
    team_stats <- parseStats(table = res_t_games,
                                       exclude_columns = c("Opposing-Stats"),
                                       split_column = "Team-Stats",
                                       first_split_columns = c("Player", "Stats"),
                                       output_columns = c("Main", "Points", "Splats", "Assists", "Deaths", "Specials"),
                                       rankCol = "Splats"
    )
    
    # Split out opposing team stats
    opposing_team_stats <- parseStats(table = res_t_games,
                                                exclude_columns = c("Team-Stats"),
                                                split_column = "Opposing-Stats",
                                                first_split_columns = c("Opposing_Player", "Stats"),
                                                output_columns = c("Opposing_Main", "Opposing_Points", "Opposing_Splats", 
                                                                   "Opposing_Assists", "Opposing_Deaths", "Opposing_Specials"),
                                                rankCol = "Opposing_Splats"
    )  
  }

  # Get just overall result
  res_t_overall <- res_t %>%
    filter(Type == "Summary") %>%
    dplyr::select(Result, Opponent_Team, Date) %>%
    rename(Overall_Result = Result)
  
  
  # Combine split team stats
  ind_base_table <- team_stats %>%
    full_join(opposing_team_stats) 
  

  # Add game number back in
  res_t_numbers <- res_t %>%
    filter(Type == "Game") %>%
    mutate(
      key = paste(Result, Opponent_Team, Date, Map, Mode, sep = "-"),
      short_key = paste(Opponent_Team, Number, sep = "-")
    ) %>%
    dplyr::select(key, Number, short_key)
  
  
  # Make game metadata
  games_metadata <- ind_base_table %>%
    dplyr::group_by(Result, Opponent_Team, Date, Map, Mode) %>%
    dplyr::summarise(
      Players = paste(sort(unique(Player)),collapse=", "),
      Total_Points = sum(Points),
      Total_Splats = sum(Splats),
      Total_Deaths = sum(Deaths),
      Weapons = paste(sort(unique(Main)),collapse=", "),
      Opposing_Players = paste(sort(unique(Opposing_Player)),collapse=", "),
      Opposing_Weapons = paste(sort(unique(Opposing_Main)),collapse=", "),
      Total_Opposing_Points = sum(Opposing_Points)
    ) %>% 
    left_join(res_t_overall) %>%
    mutate(
      key = paste(Result, Opponent_Team, Date, Map, Mode, sep = "-") 
    ) %>% 
    left_join(res_t_numbers)
  
  
  # Make long-format table for ScrapyardSquids weapons
  long_weapons <- ind_base_table %>%
    dplyr::ungroup() %>%
    dplyr::select(Result, Opponent_Team, Date, Map, Mode, Main) %>%
    distinct() %>%
    mutate(
      key = paste(Result, Opponent_Team, Date, Map, Mode, sep = "-"),
      value = 1
    ) %>%
    dplyr::select(key, Main, value)
  
  
  # Make named list for results
  processed_tables <- list(
    players = ind_base_table,
    games = games_metadata,
    long_team_weapons = long_weapons)
  
  return(processed_tables)
}


#######################################################
# Make Overview table
overviewTable <- function(games_df) {
  # Make match summary table
  matches <- games_df %>%
    dplyr::ungroup() %>%
    separate(col = "Overall_Result", sep = "_", into = c("TeamScore", "OpposingScore"), convert = T) %>%
    mutate(Mode_Map = paste(Mode, Map, sep = "-")) %>%
    dplyr::group_by(Opponent_Team, Date) %>%
    dplyr::select(TeamScore, OpposingScore, Mode_Map) %>%
    dplyr::summarise(
      TeamScore = median(TeamScore),
      OpposingScore = median(OpposingScore),
      Modes_Maps = paste(sort(unique(Mode_Map)),collapse=", ")
    ) %>%
    mutate(
      Month = months_vector[gsub("_.*", "", Date)],
      Year = gsub(".*_", "", Date)
    ) %>%
    relocate("Month", .after = "Date") %>%
    relocate("Year", .after = "Month")
  
  # Order by Date
  matches <- matches %>%
    arrange(Date)
  
  # Make Total row
  matches_total <- matches %>% 
    dplyr::ungroup() %>% 
    dplyr::summarize(
      Opponent_Team = "Total",
      Year = paste(unique(Year), sep = ","),
      TeamScore = sum(TeamScore),
      OpposingScore = sum(OpposingScore)
    )
  
  # Add total row
  matches_combined <- matches %>% 
    bind_rows(matches_total)
  
  return(matches_combined)
}


#######################################################
# Make Mode Summary bar plot
modeBarPlot <- function(games_df) {
  
  # Get total number of games per mode
  modes_sum <- games_df %>%
    dplyr::ungroup() %>%
    dplyr::select(Mode) %>%
    mutate(value=1) %>%
    dplyr::group_by(Mode) %>%
    dplyr::summarise(
      sum = sum(value)
    )  
  
  # Get counts for each result per mode 
  # Join totals to get percents
  modes_summary_input <- games %>%
    dplyr::ungroup() %>%
    dplyr::select(Result, Mode) %>%
    mutate(value=1) %>%
    dplyr::ungroup() %>%
    left_join(modes_sum) %>%
    dplyr::group_by(Result, Mode) %>%
    dplyr::summarise(
      Proportion = 100 * value / sum,
      prop = sum(Proportion)
    ) %>%
    dplyr::select(-Proportion) %>%
    distinct()
  
  # Make bar plot
  modes_bars <- modes_summary_input %>%
    rename(Percent = prop) %>%
    ggplot(aes(x=Mode, y=Percent, fill=Result)) +
    geom_bar(stat = "identity", position = "stack", color="black") +
    theme_bw() +
    ylab("Percent (%)") +
    xlab("") +
    scale_fill_manual(
      values = results_colors
    ) 
  
  return(modes_bars)
}


#######################################################
# Heatmap table generation
heatmapTablesCreation <- function(
  games_df,
  weapons_metadata,
  weapons_usage
) {
  # Make list to hold outputs
  hm_tables <- list()
  
  # Switch to short key
  weapons_short_key <- games_df %>%
    dplyr::ungroup() %>%
    dplyr::select(key, short_key)
  
  hm_tables[["data"]] <- weapons_usage %>%
    left_join(weapons_short_key) %>%
    dplyr::select(-key) %>%
    pivot_wider(
      names_from = c("short_key"), values_from = "value", values_fill = 0
    ) %>%
    filter(!is.na(Main))  %>%
    column_to_rownames("Main")
  
  # Basic heatmap
  # pheatmap(weapons_wide_hm)
  
  # Weapons (rows annotations)
  hm_tables[["weapons_meta"]] <- weapons_metadata %>%
    dplyr::select(Main, Special) %>%
    column_to_rownames(var = "Main")
  
  # Games (column annotations)
  hm_tables[["games_meta"]] <- games %>%
    dplyr::ungroup() %>%
    dplyr::select(short_key, Result, Map, Mode) %>%
    column_to_rownames(var = "short_key")  
  
  return(hm_tables)
}


#######################################################
# Make legend for heatmap
heatmapLegendCreation <- function(
  hm_game_meta,
  hm_weapons_meta,
  legend_font_title_size,
  legend_font_text_size,
  hm_legend_colors,
  legends_rel_widths = c(4, 1, 4, 1)
) {
  special_legend <- createLegend(
    table = hm_weapons_meta,
    color_column = "Special",
    colors_list = hm_legend_colors,
    number_columns = 2,
    legend_title_size = legend_font_title_size,
    legend_text_size = legend_font_text_size
  ) 
  
  result_legend <- createLegend(
    table = hm_game_meta,
    color_column = "Result",
    colors_list = hm_legend_colors,
    number_columns = 1,
    legend_title_size = legend_font_title_size,
    legend_text_size = legend_font_text_size
  ) 
  
  map_legend <- createLegend(
    table = hm_game_meta,
    color_column = "Map",
    colors_list = hm_legend_colors,
    number_columns = 2,
    legend_title_size = legend_font_title_size,
    legend_text_size = legend_font_text_size
  ) 
  
  
  mode_legend <- createLegend(
    table = hm_game_meta,
    color_column = "Mode",
    colors_list = hm_legend_colors,
    number_columns = 1,
    legend_title_size = legend_font_title_size,
    legend_text_size = legend_font_text_size
  ) 
  
  # Combine legends
  hm_legend <- plot_grid(special_legend, result_legend, 
            map_legend, mode_legend, nrow = 2,
            rel_widths = legends_rel_widths,
            align = "h") 
  
  return(hm_legend)
}


#######################################################
# Set results per player
playerResults <- function(
    players_df = players,
    player,
    weapons_meta = weapons_table,
    usage = "tree",
    weapon_colors = main_weapon_colors,
    roster_table = input_roster_aliases_table
    ){
  #pl = c("Ruby", "Ayako")
  
  # Subset roster to just that player
  roster_subset <- input_roster_aliases_table %>% 
    filter(
      Player == player
    )
  
  # Get vector of aliases
  pl <- roster_subset$Alias
  
  # Make list for results
  list_res <- list()
  

  # Get just columns of interest
  # Derive kills
  # Make new column of deaths to have cases where that match does NOT have assists known
  # Also have Deaths set to NA
  ind <- players_df %>%
    filter(Player %in% pl) %>%
    dplyr::select(Result, Opponent_Team, Date, Map, Main, Points, Splats, Assists, Deaths, Specials) %>%
    mutate(
      Kills = Splats - Assists
    ) %>%
    relocate(
      Kills, .after = "Splats"
    ) %>%
    mutate(
      Deaths_w_Assists_Data = if_else(
        is.na(Assists),
        NA,
        Deaths
      )
    )
  
  
  # Make summary table per weapon
  sum_table <- ind %>%
    mutate(
      key = paste(Opponent_Team, Date, Map, sep = "-"),
      WinCode = if_else(grepl("Win", Result), 1, 0)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(Main) %>%
    dplyr::summarise(
      Matches = length(key),
      Win_Ratio = round( (sum(WinCode) / Matches), 3),
      `Avg_Points/G` = round(sum(Points)/length(na.omit(Points)), 3),
      Total_Points = sum(Points),      
      `Avg_Splats/D` = round(sum(Splats, na.rm = T) / sum(Deaths, na.rm = T), 3),
      Total_Splats = sum(Splats),
      `Avg_K/D` = round(sum(Kills, na.rm = T) / sum(Deaths_w_Assists_Data, na.rm = T), 3),
      Total_Kills = sum(Kills, na.rm = T),
      `Avg_Assists/D` = round(sum(Assists, na.rm = T) / sum(Deaths_w_Assists_Data, na.rm = T), 3),
      Total_Assists = sum(Assists, na.rm = T),        
      Total_Deaths = sum(Deaths, na.rm = T),
    )
  
  # Get totals
  sum_table_totals <- ind %>%
    mutate(
      key = paste(Opponent_Team, Date, Map, sep = "-"),
      WinCode = if_else(grepl("Win", Result), 1, 0)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::summarise(
      Matches = length(key),
      Win_Ratio = round( (sum(WinCode) / Matches), 3),
      `Avg_Points/G` = round(sum(Points)/length(na.omit(Points)), 3),
      Total_Points = sum(Points),      
      `Avg_Splats/D` = round(sum(Splats, na.rm = T) / sum(Deaths, na.rm = T), 3),
      Total_Splats = sum(Splats, na.rm = T),
      `Avg_K/D` = round(sum(Kills, na.rm = T) / sum(Deaths_w_Assists_Data, na.rm = T), 3),
      Total_Kills = sum(Kills, na.rm = T),
      `Avg_Assists/D` = round(sum(Assists, na.rm = T) / sum(Deaths_w_Assists_Data, na.rm = T), 3),
      Total_Assists = sum(Assists, na.rm = T),         
      Total_Deaths = sum(Deaths, na.rm = T),
    ) %>%
    mutate(
      Main = "Total"
    ) %>%
    relocate(
      Main, .before = "Matches"
    )
  
  sum_table <- sum_table %>%
    bind_rows(sum_table_totals)
  
  # Make container to have shared header
  # a custom table container
  sketch = htmltools::withTags(table(
    class = 'display',
    thead(
      tr(
        th(rowspan = 2, 'Main'),
        th(rowspan = 2, 'Matches'),
        th(rowspan = 2, 'Win_Ratio'),
        th(colspan = 2, 'Points', style = "text-align: center"),
        th(colspan = 2, 'K + A', style = "text-align: center"),
        th(colspan = 2, 'Kills (K)', style = "text-align: center"),
        th(colspan = 2, 'Assists (A)', style = "text-align: center"),
        th(rowspan = 2, "Total Deaths")
      ),
      tr(
        lapply(rep(c('Average', 'Total'), 4), th)
        # th("Main"),
        # th("Matches"),
        # th("Win_Ratio"),
        # th("Average"),
        # th("Total", style = "border-right: solid 2px;"),
        # th("Average"),
        # th("Total", style = "border-right: solid 2px;"),
        # th("Average"),
        # th("Total", style = "border-right: solid 2px;"),
        # th("Average"),
        # th("Total", style = "border-right: solid 2px;"),
        # th("Total Deaths")
      )
    )
  ))
  
  hash_indices <- c(3, 5, 7, 9, 11)

  
  # Make summary table
  sum_dt <- datatable(
    sum_table,
    container = sketch,
    rownames = F,
    caption = htmltools::tags$caption(
      style = "color:black; text-align: left;",
      "Points averages are Total / Games, while all other averages are Total / Deaths."
    ),
    extensions = 'Buttons',
    options = list(
      columnDefs = list(
        list(targets = "_all", className = "dt-center")       
      ),
      paging = TRUE,
      searching = TRUE,
      fixedColumns = TRUE,
      ordering = TRUE,
      dom = 'tBp',
      server = FALSE,
      buttons = c('copy', 'csv', 'excel')      
    )
  ) %>%
    formatStyle(hash_indices, `border-right` = "solid 2px") %>% 
    formatStyle(
      'Main',
      target = 'row',
      backgroundColor = styleEqual(c("Total"), c(total_row_color))
    )
  
  
  # Append to list
  list_res[["summary"]] <- sum_dt
  
  # Make table per mode
  mode_table_input <- ind[order(ind$Mode), ] %>%
    dplyr::select(-Deaths_w_Assists_Data) %>%
    rename(`K + A` = Splats) %>% 
    dplyr::ungroup() %>% 
    dplyr::group_by(Mode)
  
  # Keep desired mode order
  mode_table_input$Mode <- factor(mode_table_input$Mode, levels = modes_ordered)
  
  mode_table_input <- mode_table_input %>% 
    arrange(Mode)
  
  mode_dt <- datatable(
    mode_table_input,
    extensions = c('RowGroup', 'Buttons'),
    options = list(
      rowGroup = list(dataSrc = 0),
        paging = TRUE,
        searching = TRUE,
        fixedColumns = TRUE,
        ordering = TRUE,
        dom = 'tBp',
        server = FALSE,
        buttons = c('copy', 'csv', 'excel')
      ),
    selection = 'none',
    filter = 'top',
    rownames = F
  )
  
  # Append to list
  list_res[["mode_table"]] <- mode_dt
  
  
  # Make input table for tree map
  usage_input <- ind %>%
    left_join(weapons_meta) %>%
    dplyr::ungroup() %>%
    dplyr::select(Main, Special, Class) %>%
    dplyr::group_by(Main, Special, Class) %>%
    summarize(
      Games = n()
    ) %>%
    dplyr::ungroup() %>%
    mutate(
      Parent = paste(Class, Special, sep = "_")
    ) %>%
    dplyr::select(
      Main, Games, Parent, Class
    ) %>%
    arrange(Class)
  
  
  if (usage == "tree") {
    
    # Finish adding parents
    main_df <- usage_input %>%
      dplyr::group_by(Class) %>%
      summarize(
        Games = sum(Games)
      ) %>%
      dplyr::ungroup() %>%
      rename(Main = Class) %>%
      mutate(Parent = "",
             Values = 0,
             Class = Main
      )
    
    
    # Add special df
    special_class <- usage_input %>%
      dplyr::group_by(Parent, Class) %>%
      summarize(
        Games = sum(Games)
      ) %>%
      dplyr::ungroup() %>%
      rename(Main = Parent) %>%
      mutate(Parent = gsub("_.*", "", Main),
             Values = 0
      )
    
    
    # Combine dataframes
    combined_tree_df <- usage_input %>%
      dplyr::select(Main, Class, Games, Parent) %>%
      mutate(Values = Games) %>%
      bind_rows(main_df) %>%
      bind_rows(special_class)
    
    # Make df for setting colors
    combined_tree_df_colors <- combined_tree_df %>%
      filter(
        Parent %in% names(weapon_colors)
      ) %>%
      dplyr::group_by(Parent) %>%
      summarize(Games = sum(Games)) %>%
      arrange(desc(Games)) %>% 
      mutate(Weapon_Color = weapon_colors[as.character(Parent)]) %>%
      dplyr::select(Parent, Weapon_Color) %>%
      rename(Class = Parent)
    
    # Add colors
    # Doesn't like having non-unique values in first column
    combined_tree_df <- combined_tree_df %>%
      left_join(combined_tree_df_colors) %>%
      mutate(
        #ID = paste("ID_", row_number(), sep = "")
        Main = if_else(
          Main == Class & Parent != "",
          paste(Main, "-Main", sep = ""),
          Main
        )
      ) 
    
    # Make treemap
    fig_treemap <- plot_ly(
      type='treemap',
      labels=combined_tree_df$Main,
      parents=combined_tree_df$Parent,
      values= combined_tree_df$Values,
      text = combined_tree_df$Games,
      textinfo="label+value+percent root",
      hoverinfo = "text",
      hovertemplate = "%{label}: %{text} game(s)<extra></extra>",
      domain=list(column=0),
      marker=list(colors=unname(combined_tree_df$Weapon_Color))
    ) 
    
    
    
    # Append to list
    list_res[["treemap"]] <- fig_treemap
    
  } else {
    
    fig_pie <- plot_ly(
      usage_input, 
      labels = ~Main, 
      values = ~Games, 
      type = 'pie',
      hoverinfo = "label",
      hovertemplate = "%{label}: %{value} game(s)<extra></extra>"
    )
    
    # Append to list
    list_res[["treemap"]] <- fig_pie    
    
  }
  
  return(list_res)
}


#######################################################
# Given a table, a column, and a list containing named vectors make legend
createLegend <- function(table, color_column, colors_list, 
                         number_columns=1, legend_title_size=14,
                         legend_text_size=10){
  color_column2 <- sym(color_column)
  
  g_plot <- table %>%
    dplyr::select(any_of(color_column)) %>%
    mutate(values = 1) %>%
    ggplot(aes(x=!!color_column2, y=values, fill=!!color_column2)) +
    geom_bar(stat = "identity") +
    scale_fill_manual(values = colors_list[[color_column]]) +
    theme(legend.title = element_text(size=legend_title_size)) +
    theme(legend.text = element_text(size=legend_text_size)) +
    guides(fill=guide_legend(ncol=number_columns))
  
  g_legend <- get_legend(g_plot) 
  return(g_legend)
}


#######################################################
# Recreate Splatoon3 scoreboards
scoreboardRecreation <- function(players_info_df) {
  scoreboard_df <- players_info_df %>%
    mutate(Assists = if_else(
      is.na(Assists),
      "NA",
      as.character(Assists)
    )
    ) %>%
    dplyr::select(-Type, -Code, -Notes)  %>%
    mutate(
      Splats = if_else(
        Assists != 0,
        paste(Splats, " <", Assists, ">", sep = ""),
        as.character(Splats)
      ),
      Opposing_Splats = if_else(
        Opposing_Assists != 0,
        paste(Opposing_Splats, " <", Opposing_Assists, ">", sep = ""),
        as.character(Opposing_Splats)
      )
    ) %>%
    dplyr::select(-Assists) %>%
    dplyr::select(
      Result, Knockout, Opponent_Team, Date, Map, Mode,
      Main,
      Player, Main, Points, Splats, Deaths, Specials,
      starts_with("Opposing")) %>%
    dplyr::select(1:13, Opposing_Player, Opposing_Main, Opposing_Points, Opposing_Splats, Opposing_Deaths, Opposing_Specials) %>%
    arrange(Date)  
  
  return(scoreboard_df)
}


#######################################################
# Make PSL-style stats 
statsPSLTables <- function(
    players_info_df,
    players_roster
) {
  # Make list to hold both tables
  psl_tables <- list()
  
  # Make named vector from roster to make player names consistent across matches
  aliases_v <- setNames(players_roster$Player, players_roster$Alias)
  
  # Make key for aliases
  aliases_key <- data.frame(
    Player = names(aliases_v),
    Standard_Player = unname(aliases_v)
  )
  
  # Convert to dataframe
  aliases_key$Standard_Player <- factor(
    aliases_key$Standard_Player,
    levels = players_order
  )
  
  
  # Select just the needed columns
  # And, match PSL Player Stats formatting
  # This will also remove rows w/ NAs
  players_base_table <- players_info_df %>% 
    left_join(
      aliases_key
    ) %>% 
    dplyr::select(
      all_of(
        c(
          "Standard_Player",
          "Opponent_Team",
          "Date",
          "Splats",
          "Assists",
          "Deaths",
          "Specials",
          "Points",
          "Mode"
        )
      )
    ) %>% 
    filter(
      !is.na(Splats)
    )
  
  # Make tables just for TW points
  players_tw_per_set <- players_base_table %>% 
    dplyr::group_by(
      Standard_Player, Opponent_Team, Date
    ) %>% 
    summarize(
      Turf_Inked_TW_only = Points[Mode == "Turf-War"]
    )
  
  players_tw <- players_tw_per_set %>% 
    dplyr::ungroup() %>% 
    dplyr::group_by(Standard_Player) %>% 
    summarize(
      Turf_Inked_TW_only = sum(Turf_Inked_TW_only)
    )
  
  
  # Get values per set
  psl_tables[["values_per_set"]] <- players_base_table %>% 
    dplyr::group_by(
      Standard_Player, Opponent_Team, Date
    ) %>% 
    summarize(
      Games_Played = length(Opponent_Team),
      Splats = sum(Splats),
      Assists = sum(Assists),
      Kills = Splats - Assists,
      Deaths = sum(Deaths),
      Specials_Used = sum(Specials)
    ) %>% 
    dplyr::select(
      -Splats
    ) %>% 
    relocate(
      Kills, .before = "Assists"
    ) %>% 
    arrange(
      Date,
      Standard_Player
    ) %>% 
    left_join(
      players_tw_per_set
    ) %>% 
    rename(
      Player = Standard_Player
    ) 
  
  
  # Format to running total
  psl_tables[["running_totals"]] <- players_base_table %>% 
    dplyr::group_by(Standard_Player) %>% 
    summarize(
      Matches_Played = length(unique(Opponent_Team)),
      Games_Played = length(Opponent_Team),
      Splats = sum(Splats),
      Assists = sum(Assists),
      Kills = Splats - Assists,
      Deaths = sum(Deaths),
      Specials_Used = sum(Specials)
    ) %>% 
    dplyr::select(
      -Splats
    ) %>% 
    relocate(
      Kills, .before = "Assists"
    )  %>% 
    left_join(
      players_tw
    ) %>% 
    rename(
      Player = Standard_Player
    )  
  
  # Also return alias
  psl_tables[["aliases_key"]] <- aliases_key
  
  return(psl_tables)
}


#######################################################
# Make PSL-style weapons usage table
weaponsPSLTable <- function(
  players_info_df,
  aliases_key,
  matches_df,
  modes_order
  ) {
  # Set order for modes
  players_info_df$Mode_Ordered <- factor(
    players_info_df$Mode,
    levels = modes_order
  )
  
  
  # Get maps
  matches_maps <- matches_df %>% 
    dplyr::select(
      Opponent_Team,
      Date,
      Modes_Maps
    )
  
  
  # Get key to filter complete cross by
  matches_key <- matches_df %>% 
    mutate(
      Key = paste(
        Opponent_Team,
        Date, sep = "_"
      )
    )
  
  # Get weapons table
  psl_weapons_sub <- players_info_df %>% 
    dplyr::ungroup() %>% 
    left_join(
      aliases_key
    ) %>% 
    mutate(
      Standard_Player = factor(Standard_Player, levels = players_order)
    ) %>% 
    dplyr::select(
      all_of(
        c(
          "Standard_Player",
          "Opponent_Team",
          "Date",
          "Mode_Ordered",
          "Main"
        )
      )
    ) 
  
  # Format based on available data
  psl_weapons_pres <- psl_weapons_sub %>% 
    pivot_wider(
      names_from = "Mode_Ordered",
      values_from = "Main"
    ) %>% 
    rename(
      Player = Standard_Player
    ) %>% 
    mutate(
      Key = paste(
        Opponent_Team,
        Date, sep = "_"
      ),
      Player_Key = paste(
        Player,
        Opponent_Team,
        Date, sep = "_"
      )
    ) %>% 
    filter(
      Key %in% matches_key$Key
    )
  
  
  # Fill in missing values
  psl_weapons_filled <-
    expand(psl_weapons_sub, Date, Standard_Player, Opponent_Team) %>% 
    mutate(
      Key = paste(
        Opponent_Team,
        Date, sep = "_"
      ),
      Player_Key = paste(
        Standard_Player,
        Opponent_Team,
        Date, sep = "_"
      )
    ) %>% 
    filter(
      Key %in% matches_key$Key,
      !Player_Key %in% psl_weapons_pres$Player_Key
    ) %>% 
    rename(
      Player = Standard_Player
    )
  
  # Add those values in
  psl_weapons_fin <- psl_weapons_pres %>% 
    bind_rows(
      psl_weapons_filled
    ) %>% 
    dplyr::select(
      -all_of(
        c(
          "Key",
          "Player_Key"
        )
      )
    ) %>% 
    arrange(
      Date,
      Player
    ) %>% 
    left_join(
      matches_maps
    ) %>% 
    filter(
      !is.na(Player)
    )
  
  return(psl_weapons_fin)
}
