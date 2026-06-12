# Configuracion global de ejecucion y rutas.
options(shiny.host = "0.0.0.0")
options(shiny.port = as.numeric(Sys.getenv("PORT", 8080)))

auto_stop_on_session_end <- identical(tolower(Sys.getenv("STOP_APP_ON_SESSION_END", "true")), "true")
inactivity_limit_secs <- as.numeric(Sys.getenv("INACTIVITY_TIMEOUT_SECS", 5 * 60))
active_sessions <- 0L

app_root <- normalizePath(Sys.getenv("APP_ROOT", getwd()), mustWork = FALSE)
app_path <- function(...) file.path(app_root, ...)

logo_file <- "bandera.png"
ruta_excel <- app_path("data", "proyectos_corredores.xlsx")
ruta_regiones <- app_path("data", "Regiones_Priorizadas.xlsx")
ruta_rios <- app_path("data", "derivado", "rios_ne_colombia.rds")
ruta_ferrea <- app_path("data", "derivado", "ferrea_4326_simplificada.rds")
ruta_regiones_rds <- app_path("data", "derivado", "regiones.rds")

expected_data_paths <- function() {
  list(
    proyectos = ruta_excel,
    regiones_excel = ruta_regiones,
    rios = ruta_rios,
    ferrea = ruta_ferrea,
    regiones_rds = ruta_regiones_rds
  )
}
