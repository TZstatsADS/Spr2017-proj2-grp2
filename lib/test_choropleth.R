library(rgeos)
library(sp)
library(rgdal)
library(leaflet)
library(htmlwidgets)
library(shiny)


setwd("~/Desktop/Spr2017-proj2-grp2")

#data.sel = read.csv("data/2016_abridged_cleaned_grouped_FpD.csv", header = T)
#save(data, file = 'output/2016_green_taxi.RData')
# load('output/2016_green_taxi.RData')
# myShape1 = readOGR("data/nynta_shapefile/nynta.shp", layer="nynta")
# save(myShape1, file = 'output/myShape1.RData'
load('output/myShape1.RData')


# calculate the count of pick-ups in each block
subdat<-spTransform(myShape1, CRS("+init=epsg:4326"))


load('output/count_seperated.RData')

#subdat@data$count = count_result[, input$hour+1, !input$isBussinessDay+1]

# all hours
subdat@data$count = apply(count_result[, , 1], 1, sum)

subdat_data=subdat@data[,c("NTACode", "NTAName", "count")]
subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)

# print leaflet
pal = colorBin(c('#fee0d2','#fb6a4a', '#cb181d', '#a50f15', '#67000d'), bins = c(0,10,100,1000,10000,100000))
popup1 = paste0('<strong>Neighborhood: </strong><br>', subdat_data$NTAName, 
                '<br><strong>Count of pick-ups: </strong><br>', subdat_data$count)
mymap = leaflet(subdat) %>%
  setView(lat=40.7128, lng=-74.0059, zoom=10) %>%
  addProviderTiles('CartoDB.Positron') %>%
  addPolygons(fillColor = ~pal(count), color = 'grey', weight = 1, popup = popup1, fillOpacity = .6) %>%


  addLegend(position = 'bottomright', ## choose bottomleft, bottomright, topleft or topright
          colors = c('#fee0d2','#fb6a4a', '#cb181d', '#a50f15', '#67000d'),
          labels = c(0,10,100,1000,10000),  ## legend labels (only min and max)
          opacity = 0.6,      ##transparency again
          title = "Pick Up<br>Numbers")

print(mymap)







