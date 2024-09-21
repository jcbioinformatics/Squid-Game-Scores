# https://splatoonwiki.org/wiki/List_of_weapons_in_Splatoon_3

# Create environment
# conda create -y -n pandas -c conda-forge pandas lxml
# conda activate pandas

# Based on https://stackoverflow.com/a/45113028

# Set name of output file
output = "weapons-metadata.txt"

# Give url
url = r'https://splatoonwiki.org/wiki/List_of_weapons_in_Splatoon_3'


# Load necessary libraries

import pandas as pd


# Get data

tables = pd.read_html(url) # Returns list of all tables on page
weapons_table = tables[0] # Select table of interest

weapons_subset = weapons_table[[
    'Main',
    '#ID',
    'Sub',
    'Special',
    'Special Points',
    'Level',
    'Class',
    'Introduced'
]]

weapons_subset.rename(columns={
    '#ID' : 'ID',
    'Special Points' : 'Special-Points',
    'Introduced' : 'Added-in'
},
inplace=True
)

# Change column values

# Drop trailing 'p' in Point column and convert column to int
weapons_subset['Special-Points'] = weapons_subset['Special-Points'].map(lambda x: x.rstrip('p')).astype('int')

# Remove trailing periods in Main column
# Currently only affects 'Custom Splattershot Jr.'
weapons_subset['Main'] = weapons_subset['Main'].map(lambda x: x.rstrip('.'))

# Remove single quotes from Main
weapons_subset['Main'] = weapons_subset['Main'].str.replace("'", "")

# Replace spaces with dashes for Main, Sub, and Special
weapons_subset['Main'] = weapons_subset['Main'].str.replace(" ", "-")
weapons_subset['Sub'] = weapons_subset['Sub'].str.replace(" ", "-")
weapons_subset['Special'] = weapons_subset['Special'].str.replace(" ", "-")

# Replace leading periods with '0.'
weapons_subset['Main'] = weapons_subset['Main'].str.replace('^\.', "0.", regex=True)


print(weapons_subset)

weapons_subset.to_csv(
    output,
    sep="\t",
    index=False
)
