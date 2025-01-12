##########################################################
# Set colors for Splatoon 3 logging

# Make colors for all heatmap annotations
hm_colors <- list(
  Result = c(
    "Loss" ="firebrick3", 
    "Loss-Overtime"="orange4", 
    "Win"="dodgerblue4",
    "Win-Overtime"="navyblue"
  ) ,
  
  Mode = c(
    "Rainmaker"="cornflowerblue",
    "Turf-War"="darkorchid1",
    "Tower-Control"="gray78",
    "Splat-Zones"="mediumseagreen",
    "Clam-Blitz"="plum"
  ) ,
  
  Map = c(
    "Eeltail-Alley"="#8DD3C7",
    "Hagglefish-Market"="#FFFFB3",
    "MakoMart"="#BEBADA",
    "Museum-d-Alfonsino"="#FB8072",
    "Flounder-Heights"="#80B1D3",
    "Mincemeat-Metalworks"="#FDB462",
    "Mahi-Mahi-Resort"="#B3DE69",
    "Scorch-Gorge"="#FCCDE5",
    "Sturgeon-Shipyard"="#D9D9D9",
    "Undertow-Spillway"="#BC80BD",
    "Inkblot-Art-Academy"="#CCEBC5",
    "Hammerhead-Bridge"= "#FFED6F",
    "Brinewater-Springs"="lightskyblue1",
    "Manta-Maria"="orange1",
    "Um-ami-Ruins"="mistyrose1",
    "Wahoo-World"="grey60",
    "Shipshape-Cargo-Co"="forestgreen",
    "Barnacle-&-Dime"="goldenrod4",
    "Crableg-Capital"="mediumpurple",
    "Humpback-Pump-Track"="firebrick3",
    "Bluefin-Depot"="dodgerblue3",
    "Marlin-Airport"="gray90",
    "Robo-ROM-en"="deeppink3"
  ),
  
  Special = c(
    "Killer-Wail-5.1"="pink",
    "Ink-Vac"="peachpuff",
    "Kraken-Royale"="palegoldenrod",
    "Reefslider"="palegreen",
    "Booyah-Bomb"="lightblue1",
    "Inkjet"="grey90",
    "Big-Bubbler"="plum3",
    "Ink-Storm"="firebrick1",
    "Zipcaster"="darkorange1",
    "Trizooka"="goldenrod1",
    "Super-Chump"="forestgreen",
    "Wave-Breaker"="dodgerblue1",
    "Tacticooler"="grey60",
    "Tenta-Missiles"="darkorchid1",
    "Ultra-Stamp"="firebrick4",
    "Crab-Tank"="darkorange4",
    "Triple-Inkstrike"="goldenrod3",
    "Inkvac"="darkgreen",
    "Triple-Splashdown"="dodgerblue4",
    "Splattercolor-Screen"="grey30"
  )
)


# Used for treemap
main_weapon_colors <- c(
  "Shooter"="#8DD3C7",
  "Splatling"="#FFEC8B",
  "Charger"="#FB8072",
  "Roller"="#BEBADA",
  "Blaster"="#80B1D3",
  "Slosher"="#FDB462",
  "Dualie"="#B3DE69",
  "Brush"="#FCCDE5",
  "Stringer"="#CD9B1D",
  "Brella"="#BC80BD",
  "Splatana"="#CCEBC5"
)


results_colors = hm_colors[["Result"]]

