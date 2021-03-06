#' Graphics elements and layers
#'
#' Add graphics elements and layers to the map widget.
#' @param map a leaflet map object
#' @param attribution the attribution text of the tile layer (HTML)
#' @param layerId the identification number/string of the layer created
#' @param group the group identification number/string 
#' @param options a list of extra options for tile layers, popups, paths
#'   (circles, rectangles, polygons, ...), or other map elements
#' @param type map type (satellite, roadmap, hybrid)
#' @return the new \code{map} object
#' @references The Leaflet API documentation:
#'   \url{http://leafletjs.com/reference.html}
#'   \url{https://gitlab.com/IvanSanchez/Leaflet.GridLayer.GoogleMutant}
#' @export
#' addGoogleTiles

addGoogleTiles <- function(map,
                           attribution = NULL,
                           layerId = NULL,
                           group = NULL,
                           options = tileOptions(),
                           type = "satellite") 
{
  options$attribution = attribution
  invokeMethod(map, getMapData(map), 
               'addGoogleTiles', 
               layerId, group,options, type)
}

#' Zoom functions :
#'
#' Set the optimal zoom for your raster using the boundaries of the raster.
#' @param xdist the horizontal distance of the map displayed in the widget, it's in degree
#' @param ydist the vertical distance of the map displayed in the widget, it's in degree
#' @return a vector composed by the optimal zoom level and its dependencies
#' @references The raster package:
#'   \url{https://cran.r-project.org/web/packages/raster/raster.pdf}
#' @export
#' setZoomBound

setZoomBound <- function(xdist, ydist){
  if(xdist>ydist){
    ydist <- xdist 
  }
  
  if(ydist > 45){
    zoom=c(1,4,7,10,13)
  }
  else{
    if(ydist > 22.5){
      zoom=c(2,5,8,11,13)
    }
    else{
      if(ydist > 11.25){
        zoom=c(3,6,9,12,14)
      }
      else{
        if(ydist > 5.625){
          zoom=c(4,7,10,13,15)
        }
        else {
          if (ydist > 2.813){
            zoom=c(5,7,10,13,15)
          }
          else{
            if (ydist > 1.406){
              zoom=c(6,8,10,12,15)
            }
            else{
              if (ydist > 0.703){
                zoom=c(7,9,11,13,15)
              }
              else{
                if (ydist > 0.352){
                  zoom=c(8,10,12,14,16,5)
                }
                else{
                  if (ydist > 0.176){
                    zoom=c(9,11,13,15,5)
                  }
                  else{
                    if (ydist > 0.088){
                      zoom=c(10,12,14,16,5)
                    }
                    else{
                      zoom=c(10,12,14,16,5)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return(zoom)
}


#' Polygon functions :
#'
#' Find the boundarie of a polygon, and the middle of it, given the list of their composite points.
#' @param liste a list of the points of the polygon
#' @return a vector composed by the limits of the square which wrap the polygon
#' @export
#' polygonBoundaries

polygonBoundaries <- function (liste){
  lng <- liste$LNG
  lat <- liste$LAT
  
  xmin <- min(lng)
  xmax <- max(lng)
  ymin <- min(lat)
  ymax <- max(lat)
  xcenter <- (xmin+xmax)/2
  ycenter <- (ymin+ymax)/2
  
  bound <- c(xmin, ymin, xmax, ymax, xcenter, ycenter)
  
  return(bound)
}

#' User functions :
#'
#' Make the package more user friendly (you need to use this function into the ui part of your shinny Application)
#' @param apikey the api-key you want to use for your application (you need to use a valid key)
#' @return a tags$head that will be usefull to load the references js/css
#' @export
#' useLeafletGoogle

useLeafletGoogle <- function (apikey){
  if(!isNamespaceLoaded("leaflet")){
    warning("Install and load the leaflet package", call. = FALSE)
    install.packages("leaflet")
    library(leaflet)
  }
  if(!isNamespaceLoaded("shiny")){
    warning("Install and load the shiny package", call. = FALSE)
    install.packages("shiny")
    library(shiny)
  }
  
  api <- as.character(apikey) 
  link <- "https://maps.googleapis.com/maps/api/js?key="
  
  googlelink <- paste(link,api, sep="")
  
  return(tags$head(tags$script(src="https://cdn.rawgit.com/KillianDudduss/leafletGoogle/master/data/1.0.3/dist/leaflet.js"),
                   tags$script(src="https://cdn.rawgit.com/KillianDudduss/leafletGoogle/master/data/function.js"),
                   tags$script(src=googlelink),
                   tags$script(src='https://cdn.rawgit.com/KillianDudduss/leafletGoogle/master/data/Leaflet.GoogleMutant.js')))
}

#' User functions :
#'
#' Use the package without shiny (this function works with the other function addGTiles)
#' @param map the leaflet map
#' @param apikey the api-key you want to use for your application (you need to use a valid key)
#' @return the option to use the google base tile on leaflet without shiny 
#' @export
#' initPlugin

initPlugin <- function(map,apikey){
  api <- as.character(apikey) 
  link <- "https://maps.googleapis.com/maps/api/js?key="
  googlelink <- paste(link,api, sep="")
  link <- paste("<script src='",googlelink,"'></script>",sep="")
  
  L.Google <- htmlDependency("leaflet.Google", "1.0.3",
                             head = link,
                             src = c(href = "https://cdn.rawgit.com/KillianDudduss/sharedObject/master/LeafletGoogle2-Data/"),
                             script = c("leaflet-google.js"),
                             stylesheet = "leaflet-top.css"
  )
  registerPlugin <- function(map, plugin) {
    map$dependencies <- c(map$dependencies, list(plugin))
    return(map)
  }
  return( registerPlugin(map, plugin = L.Google))
}

#' Graphics elements and layers :
#'
#' Add the google layer to the map widget (without shiny).
#' @param map the leaflet map
#' @return the leaflet google layer map 
#' @export
#' addGTiles

addGTiles <- function(map){
  rtn <- onRender(map, jsCode = 'function(el, x) {
                  var googleLayer = new L.Google("ROADMAP");
                  this.addLayer(googleLayer);}')
  return(rtn)
}
