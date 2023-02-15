## Introduction 

This is a dashboard project created in R for users to interact with the data from the School Education Statistics data set provided by Data.gov.in.

## library

- shiny
- tidyverse
- sf
- ggthemes
- raster
- DT
- conflicted
- ggrepel

## Data sets

Using the `raster` library to import the  GIS data to create  `sf` maps.
And then changed the names of the columns in the data frame to match with the edu_data.csv.

## Interactive MAPS

For the Interactive maps I have Given 3 Filters to the users in which they can select:-

- year ( to select the year)
- topic ( to select the topic on which you want to see a map of)
-  % slider (to select the range of percentage to filter out the states)

## Tables 

You also have a radio button to select between map and table to see the data and the filters provided above also works.
