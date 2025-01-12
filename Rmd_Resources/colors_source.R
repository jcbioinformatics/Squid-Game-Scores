##########################################################
# Set colors for Splatoon 3 logging

# Color generation for maps based on
# randomcoloR package

# Make colors for all heatmap annotations
hm_colors <- list(
  Result = c(
    "Loss" ="firebrick3", 
    "Loss-Overtime"="orange4", 
    "Win"="dodgerblue4",
    "Win-Overtime"="navyblue"
  ) ,
  
  Mode = c(
    "Rainmaker"="#F1D418",
    "Turf-War"="#7BED00",
    "Tower-Control"="#6203E6",
    "Splat-Zones"="#02AD89",
    "Clam-Blitz"="#B48901"
  ) ,
  
  Map = c(
    "Eeltail-Alley"="#D89D4C",
    "Hagglefish-Market"="#E0D28C",
    "MakoMart"="#DFBAAA",
    "Museum-d-Alfonsino"="#99EE47",
    "Flounder-Heights"="#C6E16F",
    "Mincemeat-Metalworks"="#73E6C8",
    "Mahi-Mahi-Resort"="#D7C9E2",
    "Scorch-Gorge"="#A5DA97",
    "Sturgeon-Shipyard"="#E047DD",
    "Undertow-Spillway"="#76AEE2",
    "Inkblot-Art-Academy"="#7D45D8",
    "Hammerhead-Bridge"= "#DD524F",
    "Brinewater-Springs"="#D75595",
    "Manta-Maria"="#69D3DF",
    "Um-ami-Ruins"="#64DD78",
    "Wahoo-World"="#7885DF",
    "Shipshape-Cargo-Co"="#B1DCDE",
    "Barnacle-&-Dime"="#E3D443",
    "Crableg-Capital"="#CC7BDB",
    "Humpback-Pump-Track"="#799883",
    "Bluefin-Depot"="#807091",
    "Marlin-Airport"="#D9A3D8",
    "Robo-ROM-en"="#DB8E80",
    "Lemuria-Hub"="#DCE6CB"
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

