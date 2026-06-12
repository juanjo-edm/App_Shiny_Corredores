# Interfaz de usuario de la app.
app_ui <- function() {
  fluidPage(
  tags$head(
    tags$style(HTML(sprintf("
    .app-header-banner {
      width: 100vw; margin-left: calc(-50vw + 50%%);
      background: #4B2E83 url('%s') center / contain no-repeat;
      min-height: 200px; box-shadow: 0 2px 10px rgba(0,0,0,0.12);
    }
    .app-title { text-align:center; margin-top:14px; font-size:1.8rem; font-weight:700; color:#3A2B6B; }
    .app-subtitle { text-align:center; font-size:1rem; color:#444; margin-bottom:16px; }
    .leaflet-container .awesome-marker i {
      text-shadow: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000, 0 0 2px #000;
      font-size: 18px; line-height: 1em;
    }
    .leaflet-container .awesome-marker-icon-white { border: 2px solid rgba(0,0,0,0.85); border-radius: 16px; }
    .leaflet-container .awesome-marker { filter: drop-shadow(0 1px 2px rgba(0,0,0,0.35)); }
    .custom-legend {
      background:#fff; border:1px solid #999; padding:10px 12px; border-radius:8px;
      box-shadow:0 2px 6px rgba(0,0,0,0.15); font-size:13px; color:#333;
    }
    .custom-legend h4 { margin:0 0 6px 0; font-size:14px; font-weight:700; color:#444; }
    .legend-row { display:flex; align-items:center; margin:4px 0; }
    .legend-swatch { width:24px; height:4px; margin-right:8px; border-radius:2px; }
    .legend-swatch.ferrea { background:#E4572E; border-bottom:2px dashed #E4572E; height:0; }
    .legend-swatch.rios { background:#0B84F3; height:4px; }
    " , logo_file))),
    tags$script(HTML("
      (function() {
        var throttleMs = 15000;
        var lastSent = 0;

        function sendActivity() {
          if (window.Shiny && Shiny.setInputValue) {
            Shiny.setInputValue('user_activity', Date.now(), { priority: 'event' });
          }
        }

        function sendThrottled() {
          var now = Date.now();
          if (now - lastSent < throttleMs) return;
          lastSent = now;
          sendActivity();
        }

        ['click', 'keydown', 'mousemove', 'scroll', 'touchstart'].forEach(function(evt) {
          document.addEventListener(evt, sendThrottled, { passive: true });
        });

        document.addEventListener('visibilitychange', function() {
          if (document.visibilityState === 'visible') sendActivity();
        });

        window.addEventListener('focus', sendActivity);
        sendActivity();
      })();
    "))
  ),
  div(class = "app-header-banner"),
  div(class = "app-title", "Principales Obras En Los Corredores Logísticos"),
  div(class = "app-subtitle", "Selecciona corredores o regiones priorizadas para visualizar rutas, proyectos y sombreado territorial (exacto)."),
  sidebarLayout(
    sidebarPanel(
      helpText("Selecciona uno o más corredores y/o regiones para filtrar el mapa."),
      selectizeInput("sel_corredores", "Corredores", choices = names(corredores),
                     multiple = TRUE, selected = NULL,
                     options = list(placeholder = "Selecciona uno o más corredores…", plugins = list("remove_button"))),
      selectizeInput("sel_regiones", "Regiones Priorizadas",
                     choices = if (!is.null(Dato_Regiones)) unique(Dato_Regiones$Region) else
                       if (!is.null(REGIONES_RDS)) names(REGIONES_RDS) else c("Catatumbo","Cauca","Chocó"),
                     multiple = TRUE, selected = NULL,
                     options = list(placeholder = "Selecciona una o más regiones…", plugins = list("remove_button"))
      ),
      fluidRow(
        column(6, actionButton("btn_all",   "Seleccionar todo", class = "btn-primary", width = "100%")),
        column(6, actionButton("btn_clear", "Limpiar selección", class = "btn-default", width = "100%"))
      ),
      br(),
      checkboxInput("ajustar_vista",    "Ajustar el zoom al/los corredor(es)/región(es) seleccionados", TRUE),
      hr(),
      checkboxInput("mostrar_rios",     "Mostrar ríos", TRUE),
      checkboxInput("mostrar_ferrea",   "Mostrar red férrea", TRUE),
      checkboxInput("mostrar_proyectos","Mostrar proyectos (corredores y regiones)", TRUE),
      helpText("Tip: usa el cuadro para buscar dentro del desplegable.")
    ),
    mainPanel(leafletOutput("mapa", height = 680))
  )
)
}
