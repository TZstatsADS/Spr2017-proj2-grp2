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
load('output/FPD_seperated.RData')

shinyServer(function(input, output) { 
  
  
output$map <- renderLeaflet({
  
#  if (!input$showhr){
#    subdat@data$count = apply(count_result[, ,ifelse(input$days == "Business Day", 1, 2)], 1, sum)
#  }
#  else{
#    subdat@data$count = count_result[, input$hr_adjust+1, ifelse(input$days == "Business Day", 1, 2)]
#  }

  if (input$days == "All day"){
    count_intermediate = count_result %>% apply(c(1,2), sum)
    FPD_intermediate = FPD_result %>% apply(c(1,2), mean, na.rm = T)
  }else{
    count_intermediate = count_result[ , , (input$days == "Not Business Day") + 1]
    FPD_intermediate = FPD_result[ , , (input$days == "Not Business Day") + 1]
  }
  if (!input$showhr){
    subdat@data$count = count_intermediate %>% apply(1, sum)
    subdat@data$FPD = FPD_intermediate %>% apply(1, mean, na.rm = T)
  }else{
    subdat@data$count = count_intermediate[, input$hr_adjust+1]
    subdat@data$FPD = FPD_intermediate[, input$hr_adjust+1]
  }

#subdat@data$count = count_result[, input$hr_adjust+1,  1]
  
subdat_data=subdat@data[,c("NTACode", "NTAName", "count", "FPD")]
subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)

# print leaflet
pal = colorBin(c('#fee0d2','#fb6a4a', '#cb181d', '#a50f15', '#67000d'), bins = c(0,10,100,1000,10000,100000))
pal_FPD = colorBin(c('#e6f5ff','#abdcff', '#70c4ff', '#0087e6', '#005998','#00365d','#001f35'), bins = c(2,3,4,5,6,7,8,9))
popup1 = paste0('<strong>Neighborhood: </strong><br>', subdat_data$NTAName, 
                '<br><strong>Count of pick-ups: </strong><br>', subdat_data$count)
popup2 = paste0('<strong>Neighborhood: </strong><br>', subdat_data$NTAName, 
                '<br><strong>Fair Per Distance: </strong><br>', subdat_data$FPD)

    
    # print(
  map = leaflet(subdat) %>%
    setView(lat=40.7128, lng=-74.0059, zoom=10) %>%
    addProviderTiles('CartoDB.Positron') %>%
    addPolygons(fillColor = ~pal(count), color = 'grey', weight = 1, popup = popup1, fillOpacity = .6, 
                group = "<span style='color: #7f0000; font-size: 11pt'><strong>count</strong></span>") %>%
    addPolygons(fillColor = ~pal_FPD(FPD), color = 'grey', weight = 1, popup = popup2, fillOpacity = .6, 
                group = "<span style='color: #7f0000; font-size: 11pt'><strong>FPD</strong></span>") %>%
    addLayersControl(
        baseGroups = c("<span style='color: #7f0000; font-size: 11pt'><strong>count</strong></span>", ## group 1
                       "<span style='color: #7f0000; font-size: 11pt'><strong>FPD</strong></span>" ## group 2
        ), options = layersControlOptions(collapsed = FALSE))
  
  observeEvent(input$map_groups,{
    map <- leafletProxy("map") %>% clearControls()
    
    
    map = leaflet(subdat) %>%
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>%
      addProviderTiles('CartoDB.Positron') %>%
      addPolygons(fillColor = ~pal(count), color = 'grey', weight = 1, popup = popup1, fillOpacity = .6, 
                  group = "<span style='color: #7f0000; font-size: 11pt'><strong>count</strong></span>") %>%
      addPolygons(fillColor = ~pal_FPD(FPD), color = 'grey', weight = 1, popup = popup2, fillOpacity = .6, 
                  group = "<span style='color: #7f0000; font-size: 11pt'><strong>FPD</strong></span>") %>%
      addLayersControl(
        baseGroups = c("<span style='color: #7f0000; font-size: 11pt'><strong>count</strong></span>", ## group 1
                       "<span style='color: #7f0000; font-size: 11pt'><strong>FPD</strong></span>" ## group 2
        ), options = layersControlOptions(collapsed = FALSE))
    
    
    
    
    if (input$map_groups == "<span style='color: #7f0000; font-size: 11pt'><strong>count</strong></span>") {
      map <- map %>% addLegend(position = 'bottomright',
                              colors = c('#fee0d2','#fb6a4a', '#cb181d', '#a50f15', '#67000d'),
                              labels = c("0~9","10~99","100~999","1000~9999","10000~99999"),  ## legend labels (only min and max)
                              opacity = 0.6,      ##transparency again
                              title = "Pick Up Numbers")
    }else{
      map <- map %>% addLegend("bottomright", 
                              colors = c('#e6f5ff','#abdcff', '#70c4ff', '#0087e6', '#005998','#004270','#001f35'),
                              labels = c("2","3","4","5","6","7","8+"),
                              opacity = 0.6, 
                              title = "Fair Per Distance")
    }
    })
  print (map)

    # %>%
    # addLayersControl(baseGroups=c("<span style='color: #7f0000; font-size: 11pt'><strong>count</strong></span>",
    #                               "<span style='color: #7f0000; font-size: 11pt'><strong>FPD</strong></span>"),
    #                    options=layersControlOptions(collapsed = F)))

   })
  
  })


