library(rgeos)
library(sp)
library(rgdal)
library(leaflet)
library(htmlwidgets)
library(shiny)

setwd('/Users/AaronWang/Desktop/5243-proj2-grp2')
# data = read.csv("2016_Green_Taxi_Trip_Data.csv", header = T)
# save(data, file = 'output/2016_green_taxi.RData')
load('output/2016_green_taxi.RData')
# myShape1 = readOGR("data/nynta_shapefile/nynta.shp", layer="nynta")
# save(myShape1, file = 'output/myShape1.RData')
load('output/myShape1.RData')

data.sel = data[1:200000,]

# calculate the count of pick-ups in each block
subdat<-spTransform(myShape1, CRS("+init=epsg:4326"))
dat = data.frame(Longitude = data.sel$Pickup_longitude, Latitude = data.sel$Pickup_latitude)
coordinates(dat) <- ~ Longitude + Latitude
proj4string(dat) <- CRS("+proj=longlat")
dat <- spTransform(dat, proj4string(myShape1))
r = over(dat, myShape1)
subdat@data$count = table(r$NTACode)[rank(subdat@data$NTACode)]
subdat_data=subdat@data[,c("NTACode", "NTAName", "count")]
subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)

# print leaflet
pal = colorBin(c('#fee0d2','#fb6a4a', '#cb181d', '#a50f15', '#67000d'), bins = c(0,10,100,1000,10000,100000))
popup1 = paste0('<strong>Neighborhood: </strong><br>', subdat_data$NTAName, 
                '<br><strong>Count of pick-ups: </strong><br>', subdat_data$count)
mymap = leaflet(subdat) %>%
  setView(lat=40.7128, lng=-74.0059, zoom=10) %>%
  addProviderTiles('CartoDB.Positron') %>%
  addPolygons(fillColor = ~pal(count), color = 'grey', weight = 1, popup = popup1, fillOpacity = .6)
print(mymap)







