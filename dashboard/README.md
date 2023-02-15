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

Lets see a code to which produces maps.

```
 ggplot(x, aes(label = state_ut)) +
            geom_sf( aes(fill = .data[[input$select_topic]])) +
            ggrepel::geom_text_repel(
              data = x,
              aes(label = paste(state_ut,.data[[input$select_topic]],sep="\n"), geometry = geometry, fontface = "bold"),
              stat = "sf_coordinates",
              min.segment.length = Inf,
              size = 3,
              seed = NA) +
            scale_fill_distiller(palette = "YlOrRd", 
                                 direction= 1, 
                                 na.value="white",
                                 limits = c(input$slider[1],input$slider[2])) +
            theme_map() + 
            theme( plot.title = element_text(size=26), 
                   legend.position = "left", 
                   legend.justification ='left') +
            labs(title = paste0(y," avilability in India"), 
                 subtitle = paste0("For the Year ",input$select_year,"-",1999-as.integer(input$select_year)),
                 caption = "*Telangana was not formed untill 2014
               *Data is not avilable for the states in White",
                 fill = paste0(y," %
                         "))
```

When I wrote this code I had 1 major problem:-

**Labeling map**
As I have used `sf` to create maps so to label them using `geom_text_repel` and to label I needed `x` and `y` in `aes` but I didn't had the central longitude and latitude. 

To solve this I searched and found this solution on the internet:
```
ggrepel::geom_text_repel(
              data = df,
              aes(label = df$column_name, geometry = geometry),
              stat = "sf_coordinates",
              min.segment.length = Inf)
```
and this worked perfectly.

## Tables 

You also have a radio button to select between map and table to see the data and the filters provided above also works.
