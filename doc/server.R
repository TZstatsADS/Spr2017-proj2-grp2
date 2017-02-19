library(rgeos)
library(sp)
library(rgdal)
library(leaflet)
library(htmlwidgets)
library(shiny)


setwd("~/Desktop/Spr2017-proj2-grp2")

load('output/myShape1.RData')

subdat<-spTransform(myShape1, CRS("+init=epsg:4326"))

load('output/count_seperated.RData')

shinyServer(function(input, output) { 
  
  
output$map <- renderLeaflet({
  
  # count_intermediate = ifelse(input$days == "All Day", count_result %>% apply(c(1,2), sum),
  #                             count_result[ , , input$days == "Not Business Day" + 1])
  # subdat@data$count = ifelse(!input$showhr, count_intermediate %>% apply(1, sum),
  #                            count_intermediate[, input$hr_adjust+1] )

#subdat@data$count = count_result[, input$hour+1, !input$isBussinessDay+1]
#subdat@data$count = count_result[, input$hr_adjust+1, ifelse(input$days == "Business Day", 1, 2)]


if (!input$showhr){
  subdat@data$count = apply(count_result[, ,ifelse(input$days == "Business Day", 1, 2)], 1, sum)
}
else{
  subdat@data$count = count_result[, input$hr_adjust+1, ifelse(input$days == "Business Day", 1, 2)]
}


#subdat@data$count = count_result[, input$hr_adjust+1,  1]
  
subdat_data=subdat@data[,c("NTACode", "NTAName", "count")]
subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)

# print leaflet
pal = colorBin(c('#fee0d2','#fb6a4a', '#cb181d', '#a50f15', '#67000d'), bins = c(0,10,100,1000,10000,100000))
popup1 = paste0('<strong>Neighborhood: </strong><br>', subdat_data$NTAName, 
                '<br><strong>Count of pick-ups: </strong><br>', subdat_data$count)


    
    print(leaflet(subdat) %>%
    setView(lat=40.7128, lng=-74.0059, zoom=10) %>%
    addProviderTiles('CartoDB.Positron') %>%
    addPolygons(fillColor = ~pal(count), color = 'grey', weight = 1, popup = popup1, fillOpacity = .6)) %>%
    addLegend(position = 'bottomright', ## choose bottomleft, bottomright, topleft or topright
              colors = c('#fee0d2','#fb6a4a', '#cb181d', '#a50f15', '#67000d'),
              labels = c("0~9","10~99","100~999","1000~9999","10000~99999"),  ## legend labels (only min and max)
              opacity = 0.6,      ##transparency again
              title = "Pick Up<br>Numbers")
  
  })
  
  })
