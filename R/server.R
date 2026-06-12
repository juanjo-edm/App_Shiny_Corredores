# Logica reactiva del servidor Shiny.
app_server <- function(input, output, session) {
  last_activity <- reactiveVal(Sys.time())
  active_sessions <<- active_sessions + 1L

  observeEvent(input$user_activity, {
    last_activity(Sys.time())
  }, ignoreInit = FALSE)

  observe({
    invalidateLater(30000, session) # Revisar inactividad cada 30 segundos
    idle_secs <- as.numeric(difftime(Sys.time(), last_activity(), units = "secs"))
    if (!is.na(idle_secs) && idle_secs >= inactivity_limit_secs) {
      session$close()
    }
  })

  session$onSessionEnded(function() {
    active_sessions <<- max(0L, active_sessions - 1L)
    if (isTRUE(auto_stop_on_session_end) && active_sessions == 0L) stopApp()
  })
  
  ## 6.2) Render Inicial del Mapa ----
  output$mapa <- renderLeaflet({
    leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addTiles() %>%
      addScaleBar(position = "bottomleft")
  })
  
  ## 6.3) Reactivos ----
  ### 6.3.1) Unión de Regiones Seleccionadas (para clips) ----
  union_regiones <- reactive({
    sel_reg <- input$sel_regiones
    if (is.null(sel_reg) || length(sel_reg) == 0 || is.null(REGIONES_RDS)) return(NULL)
    regs <- REGIONES_RDS[sel_reg]
    regs <- regs[!sapply(regs, is.null)]
    if (length(regs) == 0) return(NULL)
    tryCatch({
      ur <- sf::st_union(do.call(rbind, lapply(regs, function(s) sf::st_make_valid(s))))
      ur <- sf::st_sf(geometry = sf::st_sfc(ur, crs = 4326))
      fix_polygon_holes(ur)
    }, error = function(e) NULL)
  })
  rios_clip_region <- reactive({
    ur <- union_regiones()
    if (is.null(ur) || is.null(RIOS)) return(NULL)
    tryCatch({ sf::st_intersection(RIOS, ur) }, error = function(e){ NULL })
  })
  ferrea_clip_region <- reactive({
    ur <- union_regiones()
    if (is.null(ur) || is.null(FERREA_SHP)) return(NULL)
    tryCatch({ sf::st_intersection(FERREA_SHP, ur) }, error = function(e){ NULL })
  })
  
  
  ## 6.5) Eventos de Selección ----
  ### 6.5.1) Seleccionar Todo ----
  observeEvent(input$btn_all, {
    updateSelectizeInput(session, "sel_corredores", selected = names(corredores))
    if (!is.null(Dato_Regiones))      updateSelectizeInput(session, "sel_regiones", selected = unique(Dato_Regiones$Region))
    else if (!is.null(REGIONES_RDS))  updateSelectizeInput(session, "sel_regiones", selected = names(REGIONES_RDS))
    else                              updateSelectizeInput(session, "sel_regiones", selected = c("Catatumbo","Cauca","Chocó"))
  })
  ### 6.5.2) Limpiar Selección ----
  observeEvent(input$btn_clear, {
    updateSelectizeInput(session, "sel_corredores", selected = character(0))
    updateSelectizeInput(session, "sel_regiones",  selected = character(0))
  })
  
  ## 6.6) Redibujado Principal del Mapa ----
  observeEvent(list(input$sel_corredores, input$sel_regiones, input$mostrar_proyectos), {
    sel_corr <- input$sel_corredores
    sel_reg  <- input$sel_regiones
    
    map <- leafletProxy("mapa") %>%
      clearGroup("corredores") %>%
      clearGroup("puntos") %>%
      clearGroup("proyectos") %>%
      clearGroup("regiones") %>%
      clearGroup("poligonos") %>%
      clearGroup("regiones_trazos") %>%
      clearGroup("rios_region") %>%
      clearGroup("ferrea_region") %>%
      clearControls()
    
    have_projects <- !is.null(Dato_Proyectos)
    have_regiones <- !is.null(Dato_Regiones)
    
    ### 6.6.1) Corredores ----
    if (length(sel_corr) > 0){
      for (nombre in sel_corr){
        df <- corredores[[nombre]]
        map <- map %>% addCircleMarkers(
          lng = df$lon, lat = df$lat, radius = 5,
          color = pal_corredores(nombre), fillColor = pal_corredores(nombre),
          stroke = TRUE, fillOpacity = 0.9, label = df$ciudad, group = "puntos"
        )
        map <- add_tramos_corredor(map, nombre, df, pal_corredores(nombre))
        # Proyectos (condicionados por toggle)
        if (have_projects && isTRUE(input$mostrar_proyectos)){
          proy_df <- as.data.frame(Dato_Proyectos, stringsAsFactors = FALSE)
          if ("Corredor" %in% names(proy_df)) proy_df$Corredor <- trimws(proy_df$Corredor)
          proy_df <- subset(proy_df, Corredor == nombre & is.finite(Latitud) & is.finite(Longitud))
          if (nrow(proy_df) > 0){
            popups <- project_popup(proy_df, "Corredor", proy_df$Corredor)
            iconos <- icons_for_projects(
              modo = if ("Modo" %in% names(proy_df)) proy_df$Modo else NA,
              icon_color_hex = pal_corredores(nombre)
            )
            map <- map %>% addAwesomeMarkers(
              lng = proy_df$Longitud, lat = proy_df$Latitud,
              icon = iconos, label = proy_df$Proyecto, popup = popups, group = "proyectos"
            )
          }
        }
      }
      map <- map %>% addLegend(position = "bottomright", title = "Corredores Logísticos",
                               colors = pal_corredores(sel_corr), labels = sel_corr, opacity = 1)
    }
    
    ### 6.6.2) Proyectos de Regiones (condicionados por toggle) ----
    if (have_regiones && length(sel_reg) > 0 && isTRUE(input$mostrar_proyectos)){
      reg_df <- subset(Dato_Regiones, Region %in% sel_reg & is.finite(Latitud) & is.finite(Longitud))
      if (nrow(reg_df) > 0){
        popups_reg <- project_popup(reg_df, "Región priorizada", reg_df$Region)
        colores_por_region <- unname(region_fill_colors[reg_df$Region])
        iconos_reg <- icons_for_projects(
          modo = if ("Modo" %in% names(reg_df)) reg_df$Modo else NA,
          icon_color_hex = colores_por_region
        )
        map <- map %>% addAwesomeMarkers(
          lng = reg_df$Longitud, lat = reg_df$Latitud,
          icon = iconos_reg, label = reg_df$Proyecto,
          popup = popups_reg, group = "proyectos" # mismo grupo para el toggle conjunto
        )
      }
    }
    
    ### 6.6.3) Polígonos Exactos de Regiones (sin leyenda de sombreado) ----
    regiones_sf <- list()
    if (!is.null(REGIONES_RDS) && length(sel_reg) > 0){
      for (nm in sel_reg){
        if (nm %in% names(REGIONES_RDS)) regiones_sf[[nm]] <- REGIONES_RDS[[nm]]
      }
    }
    if (length(regiones_sf) > 0){
      for (nm in names(regiones_sf)){
        map <- add_region_poly(map, regiones_sf[[nm]], nm)
      }
      # (Intencionalmente NO se agrega la leyenda de regiones sombreado)
    }
    
    ### 6.6.4) Trazos de Regiones ----
    if (length(sel_reg) > 0){
      for (reg in sel_reg){
        if (reg %in% names(coords_regiones) && reg %in% names(segmentos_regiones)) {
          map <- add_trazos_region(map, reg)
        }
      }
      # Puedes mantener o quitar esta leyenda de trazos; la dejo para orientación de selección
      leafletProxy("mapa") %>% addLegend(
        position = "bottomright",
        title = "Regiones Priorizadas",
        colors = unname(region_fill_colors[sel_reg]),
        labels = sel_reg, opacity = 1
      )
    }
    
    ### 6.6.5) Leyenda Personalizada (Ríos y Férrea) ----
    # Se muestra SIEMPRE para que el usuario identifique estilos,
    # pero podrías condicionar por toggles si prefieres.
    leafletProxy("mapa") %>% addControl(html = guide_control_html(), position = "bottomleft")
    
    ### 6.6.6) Ajuste de Vista (zoom) ----
    if (isTRUE(input$ajustar_vista)){
      pts_list <- list()
      if (length(sel_corr) > 0){
        all_pts <- do.call(rbind, lapply(corredores[sel_corr], function(x) x[, c("lon","lat")]))
        pts_list[[length(pts_list)+1]] <- setNames(all_pts, c("lon","lat"))
      }
      if (!is.null(Dato_Proyectos) && length(sel_corr) > 0 && isTRUE(input$mostrar_proyectos)){
        proy_sel <- subset(as.data.frame(Dato_Proyectos, stringsAsFactors = FALSE),
                           Corredor %in% sel_corr & is.finite(Latitud) & is.finite(Longitud),
                           select = c("Longitud","Latitud"))
        if (nrow(proy_sel) > 0) pts_list[[length(pts_list)+1]] <- setNames(proy_sel, c("lon","lat"))
      }
      add_bbox <- function(sf_obj){
        if (is.null(sf_obj)) return(NULL)
        bb <- st_bbox(sf_obj)
        data.frame(lon = c(bb["xmin"], bb["xmax"]), lat = c(bb["ymin"], bb["ymax"]))
      }
      for (nm in names(regiones_sf)){
        b <- add_bbox(regiones_sf[[nm]]); if (!is.null(b)) pts_list[[length(pts_list)+1]] <- b
      }
      if (length(sel_reg) > 0 && is.null(REGIONES_RDS)){ # sin polígonos, usa nodos de trazos
        for (reg in sel_reg){
          if (reg %in% names(coords_regiones)){
            pts_list[[length(pts_list)+1]] <- setNames(coords_regiones[[reg]][,c("lon","lat")], c("lon","lat"))
          }
        }
      }
      if (length(pts_list) > 0){
        all_pts <- do.call(rbind, pts_list)
        leafletProxy("mapa") %>% fitBounds(
          min(all_pts$lon, na.rm = TRUE), min(all_pts$lat, na.rm = TRUE),
          max(all_pts$lon, na.rm = TRUE), max(all_pts$lat, na.rm = TRUE)
        )
      } else {
        all_pts <- do.call(rbind, lapply(corredores, function(x) x[, c("lon","lat")]))
        leafletProxy("mapa") %>% fitBounds(
          min(all_pts$lon, na.rm = TRUE), min(all_pts$lat, na.rm = TRUE),
          max(all_pts$lon, na.rm = TRUE), max(all_pts$lat, na.rm = TRUE)
        )
      }
    }
    
    ### 6.6.7) Mensajes de Diagnóstico en UI ----
    if (is.null(Dato_Proyectos))
      leafletProxy("mapa") %>% addControl(
        html = "<div style='background:#eef;border:1px solid #338;padding:8px;border-radius:6px;color:#114'>
        No se pudo cargar el Excel de proyectos. Revisa <code>data/proyectos_corredores.xlsx</code>.
        </div>", position = "topleft")
    if (is.null(Dato_Regiones))
      leafletProxy("mapa") %>% addControl(
        html = "<div style='background:#efe;border:1px solid #383;padding:8px;border-radius:6px;color:#114'>
        No se pudo cargar el Excel de regiones. Revisa <code>data/Regiones_Priorizadas.xlsx</code>.
        </div>", position = "topright")
    if (is.null(REGIONES_RDS))
      leafletProxy("mapa") %>% addControl(
        html = "<div style='background:#fee;border:1px solid #833;padding:8px;border-radius:6px;color:#611'>
        No se pudo cargar el archivo preprocesado de regiones (.rds). Revisa la ruta configurada.
        </div>", position = "bottomleft")
  }, ignoreInit = FALSE)
  
  ## 6.7) Toggles de Capas ----
  ### 6.7.1) Ríos (global + regiones) ----
  observe({
    map <- leafletProxy("mapa") %>% clearGroup("rios") %>% clearGroup("rios_region")
    if (isTRUE(input$mostrar_rios) && !is.null(RIOS)){
      label_arg <- if ("label_txt" %in% names(RIOS)) ~label_txt else NULL
      map %>% addPolylines(data = RIOS, color = "#2A9DF4", weight = 1.5, opacity = 0.8, group = "rios", label = label_arg)
      rios_clip <- rios_clip_region()
      if (!is.null(rios_clip) && nrow(rios_clip) > 0){
        map %>% addPolylines(data = rios_clip, color = "#0B84F3", weight = 2.5, opacity = 0.9,
                             group = "rios_region", label = "Ríos dentro de regiones")
      }
    }
  })
  
  ### 6.7.2) Red Férrea (global + regiones) ----
  observe({
    map <- leafletProxy("mapa") %>% clearGroup("ferrea") %>% clearGroup("ferrea_region")
    if (isTRUE(input$mostrar_ferrea) && !is.null(FERREA_SHP)){
      label_arg <- if ("label_txt" %in% names(FERREA_SHP)) ~label_txt else NULL
      map %>% addPolylines(data = FERREA_SHP, color = "#FF7F0E", weight = 2.5, opacity = 0.9, dashArray = "6,4",
                           group = "ferrea", label = label_arg)
      ferrea_clip <- ferrea_clip_region()
      if (!is.null(ferrea_clip) && nrow(ferrea_clip) > 0){
        map %>% addPolylines(data = ferrea_clip, color = "#E4572E", weight = 3.0, opacity = 0.95,
                             dashArray = "6,4", group = "ferrea_region", label = "Férrea dentro de regiones")
      }
    }
  })
}
