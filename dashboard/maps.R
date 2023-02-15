library(shiny)
library(tidyverse)
library(sf)
library(ggthemes)
library(raster)
library(DT)
library(conflicted)
library(ggrepel)

conflict_prefer("filter", "dplyr")
conflict_prefer("select", "dplyr")
# getting india dataset
India <- getData('GADM', country = 'IND', level = 1) %>% 
  st_as_sf()
# matching values 
colnames(India)[4] = "state_ut"
India$state_ut[India$state_ut == 'Andaman and Nicobar'] <- 'Andaman & Nicobar Islands'
India$state_ut[India$state_ut == 'Dadra and Nagar Haveli'] <- 'Dadra & Nagar Haveli'
India$state_ut[India$state_ut == 'Daman and Diu'] <- 'Daman & Diu'
India$state_ut[India$state_ut == 'Jammu and Kashmir'] <- 'Jammu And Kashmir'
India$state_ut[India$state_ut == 'NCT of Delhi'] <- 'Delhi'

# joining the two datsets 

map_data <- read.csv("data/edu_data.csv")
map_data <- as.data.frame(map_data)
map_data_2 <- left_join(India, map_data, by = "state_ut")


# Define UI ----
ui <- fluidPage(
  titlePanel("Elementary Education in India"),
  
  fluidRow(
    column(9,
           h3(textOutput("table_title")),
           DT::dataTableOutput("mytable"),
           h4(textOutput("warning"),style="color:red"),
           plotOutput("map")
    ),
    column(3,
           h2("Filters"),
           helpText("Create map and table with Data provided from Data.gov.in."),
           p("For an detailed report with code, visit the ",
             a("Kaggle Project Page", 
               href = "https://www.kaggle.com/code/rickjain/report-on-elementary-education-in-india")),
           helpText("Data for drop-out rate is between year 2012-2014, and other 
               data for other categories are between 2013-2015."),
           selectInput("select_year", label = "Select Year", 
                       choices = list("2012-13" = 2012,
                                      "2013-14" = 2013, 
                                      "2014-15" = 2014,
                                      "2015-16" = 2015), selected = 2013),
           selectInput("select_topic", label = "Select Category", 
                       choices = list("Drinking Water Facility avilability" = 'water_faci', 
                                      "Girl's Toilet Facility avilability" = 'gtoi_faci',
                                      "Boy's Toilet Facility avilability" = 'btoi_faci',
                                      "Electricity Connection avilability" = 'elec_faci',
                                      "Computer availability" = 'comp_faci',
                                      "Overall Facilities avilability" = 'all_faci',
                                      "Gross Enrollment Rate" = 'gross_enroll',
                                      "Drop-out Rate" = 'drop_rate' 
                       ), selected = "Drinking Water Facility avilability"),
           sliderInput("slider", label =  "Range of %",
                       min = 0, max = 115, value = c(0, 100)),
           p("Please select the Format in which you want to see the Data."),
           radioButtons("radio", label = h3("Output Type"),
                        choices = list("Map", "Table"), 
                        selected = "Map"),
           h3("Author Info"),
           p(strong("Rick Bukhariya,"), em("Final Year student at IES IPS Academy.")),
           a("Linkedin Profile", href = "https://www.linkedin.com/in/bukhariyagi/"),
           br(),
           a("Twitter Profile", href = "https://www.linkedin.com/in/bukhariyagi/"),
           p("Please Feel free to contact me twitter or linkedin on any Query you may have.")
           )
  )
 
  )
  


# Define server logic ----
server <- function(input, output, session) {
  
  # Changing slider range based on selected year and topic
  observe({
    val <- input$select_topic
    max_val <- x <- map_data %>% select(., year, input$select_topic) %>% 
      filter(., year == input$select_year) %>% 
      select(., input$select_topic) %>% 
      max(.,na.rm = T)
    min_val <- map_data %>% select(., year, input$select_topic) %>% 
      filter(., year == input$select_year) %>% 
      select(., input$select_topic) %>% 
      min(.,na.rm = T)
    updateSliderInput(session, "slider", value = c(min_val, max_val),
                      min = min_val, max = max_val)
  })

  
  # table title
  output$table_title <- renderText({
    y <- switch(input$select_topic,
                'water_faci' = "Drinking Water Facility avilability" , 
                'gtoi_faci' =  "Girl's Toilet Facility avilability"  ,
                'btoi_faci' = "Boy's Toilet Facility avilability"  ,
                'elec_faci' = "Electricity Connection avilability"  ,
                'comp_faci' = "Computer availability"  ,
                'all_faci' =  "Overall Facilities avilability"  ,
                'gross_enroll' =  "Gross Enrollment Rate"  ,
                'drop_rate' = "Drop-out Rate"  )
    if(input$radio == "Table"){print(paste("List of states with ",y," avaibility."))}
  })
  
  # table
  output$mytable <- DT::renderDataTable({DT::datatable({
    if(input$radio == "Map"){
      
    }else{table_data <- map_data %>% select(.,state_ut, year, input$select_topic) %>% 
      filter(., year == input$select_year)
    colnames(table_data)[3] = "Percentage"
    colnames(table_data)[1] = "Name"
    colnames(table_data)[2] = "Year"
    table_data <- table_data %>% arrange(., desc(Percentage))
    table_data}
       })
  })
  
  # warning message
  output$warning <- renderText({
    if(input$select_year == 2012 & input$select_topic != 'drop_rate'){
      print("Warning: Data not present!")
      print("Select another Year or Category.")
    }else{
      if(input$select_year == 2015 & input$select_topic == 'drop_rate'){
        print("Warning: Data not present!")
        print("Select another Year or Category.")
      }
    }
  })
  
  # Map
  output$map <- renderPlot({
    x <- map_data_2 %>% filter(., year == input$select_year)
    y <- switch(input$select_topic,
                'water_faci' = "Drinking Water Facility avilability" , 
                'gtoi_faci' =  "Girl's Toilet Facility avilability"  ,
                'btoi_faci' = "Boy's Toilet Facility avilability"  ,
                'elec_faci' = "Electricity Connection avilability"  ,
                'comp_faci' = "Computer availability avilability"  ,
                'all_faci' =  "Overall Facilities avilability"  ,
                'gross_enroll' =  "Gross Enrollment Rate"  ,
                'drop_rate' = "Drop-out Rate"  )
    
    if(input$select_year == 2012 & input$select_topic != 'drop_rate'){
    }else{
      if(input$select_year == 2015 & input$select_topic == 'drop_rate'){
      }else{
        if(input$select_topic == 'drop_rate' & input$radio == "Map"){
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
        }else{
          if(input$radio == "Map"){
          ggplot(x, aes(label = state_ut)) +
            geom_sf( aes(fill = .data[[input$select_topic]])) +
            ggrepel::geom_text_repel(
              data = x,
              aes(label = paste(state_ut,.data[[input$select_topic]],sep="\n"), geometry = geometry, fontface = "bold"),
              stat = "sf_coordinates",
              min.segment.length = Inf,
              size = 3,
              seed = NA) +
            scale_fill_distiller(palette = "GnBu", 
                                 direction= 1, 
                                 na.value="white",
                                 limits = c(input$slider[1],input$slider[2])) +
            theme_map() + 
            theme( plot.title = element_text(size=26), 
                   legend.position = "left", 
                   legend.justification ='left') +
            labs(title = paste0(y," avilability in India"), 
                 subtitle = paste0("For the Year ",input$select_year,"-",1999-as.integer(input$select_year)),
                 caption = "*Telangana was not formed untill 2014",
                 fill = paste0(y," %
                         "))}
        }
      }
    }
   
  },height = 800, width = 900)  
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
