# Helpers de renderizado Leaflet.
normalize_modo <- function(x){
  x <- tolower(trimws(ifelse(is.na(x), "", x)))
  x <- chartr("áéíóúäëïöüÁÉÍÓÚÄËÏÖÜ","aeiouaeiouAEIOUAEIOU", x); x
}
icon_name_by_modo <- function(m){
  m <- normalize_modo(m)
  ifelse(m %in% c("carretero","vial","carretera"), "road",
         ifelse(m %in% c("aereo","aeronautico","aeropuerto"), "plane",
                ifelse(m %in% c("fluvial","rio","hidroviario","acuatico"), "anchor",
                       ifelse(m %in% c("portuario","maritimo","puerto"), "ship",
                              ifelse(m %in% c("ferreo","ferrocarril","ferro"), "train", "info-circle")))))
}
icons_for_projects <- function(modo, icon_color_hex){
  if (length(icon_color_hex) == 1L) icon_color_hex <- rep(icon_color_hex, length.out = length(modo))
  leaflet::awesomeIcons(icon = icon_name_by_modo(modo),
                        iconColor = icon_color_hex, markerColor= "white", library = "fa")
}


  add_tramos_corredor <- function(map_obj, nombre_corr, df_corr, color_hex){
    tr <- segmentos[[nombre_corr]]; if (is.null(tr)) return(map_obj)
    tr <- tr[!is.na(tr$hasta), , drop = FALSE]; if (nrow(tr) == 0) return(map_obj)
    lon_por_ciudad <- setNames(df_corr$lon, df_corr$ciudad)
    lat_por_ciudad <- setNames(df_corr$lat, df_corr$ciudad)
    keep <- tr$desde %in% names(lon_por_ciudad) & tr$hasta %in% names(lon_por_ciudad)
    tr <- tr[keep, , drop = FALSE]; if (nrow(tr) == 0) return(map_obj)
    
    tramo_es_punteado <- function(corr, d, h){
      if (corr == "Bogotá – Barranquilla") {
        if ((d == "Bosconia" && h == "Santa Marta") || (d == "Santa Marta" && h == "Bosconia")) return(TRUE)
      }
      if (corr == "Bogotá – Yopal") {
        if ((d == "El Porvenir" && h == "Cravo Norte") || (d == "Cravo Norte" && h == "El Porvenir")) return(TRUE)
      }
      FALSE
    }
    for (i in seq_len(nrow(tr))){
      d <- tr$desde[i]; h <- tr$hasta[i]
      es_punteado <- tramo_es_punteado(nombre_corr, d, h)
      map_obj <- map_obj %>% addPolylines(
        lng = c(lon_por_ciudad[d], lon_por_ciudad[h]),
        lat = c(lat_por_ciudad[d], lat_por_ciudad[h]),
        color = color_hex, weight = 4, opacity = 0.95,
        dashArray = if (es_punteado) "6,4" else NULL,
        group = "corredores", label = paste0(nombre_corr, ": ", d, " ↔ ", h)
      )
    }
    map_obj
  }
  
  ### 6.4.2) Trazos de Regiones y Nodos ----
  add_trazos_region <- function(map_obj, nombre_region) {
    df_coords <- coords_regiones[[nombre_region]]
    tramos    <- segmentos_regiones[[nombre_region]]
    if (is.null(df_coords) || is.null(tramos) || nrow(tramos) == 0) return(map_obj)
    
    lon_por_ciudad <- setNames(df_coords$lon, df_coords$ciudad)
    lat_por_ciudad <- setNames(df_coords$lat, df_coords$ciudad)
    
    keep <- tramos$desde %in% names(lon_por_ciudad) & tramos$hasta %in% names(lon_por_ciudad)
    tramos <- tramos[keep, , drop = FALSE]
    if (nrow(tramos) == 0) return(map_obj)
    
    sty <- list(color = region_fill_colors[[nombre_region]], weight = 4, opacity = 0.95, dashArray = NULL)
    
    # Líneas
    for (i in seq_len(nrow(tramos))) {
      d <- tramos$desde[i]; h <- tramos$hasta[i]
      map_obj <- map_obj %>% addPolylines(
        lng = c(lon_por_ciudad[d], lon_por_ciudad[h]),
        lat = c(lat_por_ciudad[d], lat_por_ciudad[h]),
        color = sty$color, weight = sty$weight, opacity = sty$opacity,
        dashArray = sty$dashArray,
        group = "regiones_trazos",
        label = paste0(nombre_region, ": ", d, " ↔ ", h)
      )
    }
    
    # Nodos (círculos): oculta Teorama/Guamalito/Ayacucho en Catatumbo
    df_points <- df_coords
    if (nombre_region == "Catatumbo") {
      df_points <- subset(df_points, !ciudad %in% c("Teorama","Guamalito","Ayacucho"))
    }
    map_obj <- map_obj %>% addCircleMarkers(
      lng = df_points$lon, lat = df_points$lat, radius = 4,
      color = sty$color, fillColor = sty$color, fillOpacity = 0.85,
      stroke = TRUE, weight = 1,
      group = "regiones_trazos", label = df_points$ciudad
    )
    
    map_obj
  }

add_region_poly <- function(map_obj, sf_obj, nombre_region) {
  if (is.null(sf_obj)) return(map_obj)
  col <- region_fill_colors[[nombre_region]]
  map_obj %>% addPolygons(
    data = sf_obj, color = col, weight = 1.5, opacity = 0.9,
    fillColor = col, fillOpacity = 0.25, group = "poligonos",
    label = paste("Region:", nombre_region),
    highlightOptions = highlightOptions(weight = 2, color = "#333", fillOpacity = 0.35)
  )
}

project_popup <- function(df, context_label, context_value) {
  paste0(
    "<div class='popup-proyecto'>",
    "<div style='font-weight:600; margin-bottom:6px;'>", htmlEscape(df$Proyecto), "</div>",
    "<div style='font-size:12px; color:#555; margin-bottom:8px;'><i>", context_label, ":</i> ", htmlEscape(context_value), "</div>",
    "<label style='font-size:12px; color:#333;'>Situación</label><br/>",
    "<textarea readonly style='width:280px; min-height:90px; max-height:260px; resize:vertical; padding:6px; border:1px solid #ccc; border-radius:6px;'>",
    htmlEscape(na_to_dash(df$Situación)), "</textarea><br/><br/>",
    "<label style='font-size:12px; color:#333;'>Acción</label><br/>",
    "<textarea readonly style='width:280px; min-height:80px; max-height:240px; resize:vertical; padding:6px; border:1px solid #ccc; border-radius:6px;'>",
    htmlEscape(na_to_dash(df$Acción)), "</textarea>",
    "</div>"
  )
}

guide_control_html <- function() {
  HTML("<div class='custom-legend'>
    <h4>Guía</h4>
    <div class='legend-row'><div class='legend-swatch rios'></div><span>Ríos principales</span></div>
    <div class='legend-row'><div class='legend-swatch ferrea'></div><span>Red férrea</span></div>
  </div>")
}
