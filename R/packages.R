# Carga centralizada de paquetes requeridos por la app.
load_app_packages <- function() {
  suppressPackageStartupMessages({
    library(shiny)
    library(leaflet)
    library(dplyr)
    library(readxl)
    library(htmltools)
    library(sf)
  })
}

