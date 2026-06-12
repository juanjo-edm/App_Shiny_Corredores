# Carga y normalizacion de datos de entrada.
diagnose_app_paths <- function(paths = expected_data_paths()) {
  message("=== Diagnostico rutas esperadas ===")
  for (nm in names(paths)) {
    message(nm, ": ", paths[[nm]], " -> ", file.exists(paths[[nm]]))
  }
  message("===================================")
}

load_spatial_layers <- function() {
  rios <- tryCatch(readRDS(ruta_rios), error = function(e) { message("RIOS RDS: ", e$message); NULL })
  ferrea <- tryCatch(readRDS(ruta_ferrea), error = function(e) { message("FERREA RDS: ", e$message); NULL })
  regiones_rds <- tryCatch({
    if (file.exists(ruta_regiones_rds)) readRDS(ruta_regiones_rds) else NULL
  }, error = function(e) { message("REGIONES RDS: ", e$message); NULL })

  if (!is.null(rios)) rios <- to4326(rios)
  if (!is.null(ferrea)) ferrea <- to4326(ferrea)
  if (!is.null(regiones_rds)) regiones_rds <- lapply(regiones_rds, to4326)

  list(RIOS = rios, FERREA_SHP = ferrea, REGIONES_RDS = regiones_rds)
}

normalize_project_data <- function(df) {
  names(df) <- trimws(names(df))
  col_proy <- safe_find(names(df), c("^Nombre del proyecto$", "^Proyecto$", "nombre.*proyecto"))
  col_sit <- safe_find(names(df), c("^Situaci", "^Situacion actual$", "^Situación actual$", "situacion", "situación"))
  col_acc <- safe_find(names(df), c("^Acci", "^Accion", "^Acción", "accion"))
  col_cor <- safe_find(names(df), c("^Corredor$", "^Corredor", "^Corri", "^Region$", "^Regi[oó]n$", "^Regi[oó]n"))
  col_modo <- safe_find(names(df), c("^Modo$", "^Tipo$", "^modalidad"))
  col_lat <- safe_find(names(df), c("^Latitud$", "lat"))
  col_lon <- safe_find(names(df), c("^Longitud$", "lon", "long"))
  if (is.na(col_proy) || is.na(col_lat) || is.na(col_lon)) {
    stop("Columnas minimas faltantes en proyectos: Proyecto, Latitud y Longitud.")
  }
  df2 <- df %>%
    rename(!!sym("Proyecto") := !!sym(col_proy)) %>%
    rename(!!sym("Latitud") := !!sym(col_lat), !!sym("Longitud") := !!sym(col_lon))
  if (!is.na(col_sit)) df2 <- rename(df2, !!sym("Situación") := !!sym(col_sit))
  if (!is.na(col_acc)) df2 <- rename(df2, !!sym("Acción") := !!sym(col_acc))
  if (!is.na(col_cor)) df2 <- rename(df2, !!sym("Corredor") := !!sym(col_cor))
  if (!is.na(col_modo)) df2 <- rename(df2, !!sym("Modo") := !!sym(col_modo))
  df2 %>% mutate(Latitud = to_num(Latitud), Longitud = to_num(Longitud))
}

normalize_region_project_data <- function(df) {
  names(df) <- trimws(names(df))
  col_region <- safe_find(names(df), c("^Regi", "^Region", "^Regi[oó]n"))
  col_proy <- safe_find(names(df), c("^Nombre del proyecto$", "^Proyecto$", "nombre.*proyecto"))
  col_sit <- safe_find(names(df), c("^Situaci", "^Situacion actual$", "^Situación actual$", "situacion", "situación"))
  col_acc <- safe_find(names(df), c("^Acci", "^Accion", "^Acción", "accion"))
  col_modo <- safe_find(names(df), c("^Modo$", "^Tipo$", "^modalidad"))
  col_lat <- safe_find(names(df), c("^Latitud$", "lat"))
  col_lon <- safe_find(names(df), c("^Longitud$", "lon", "long"))
  if (is.na(col_region) || is.na(col_proy) || is.na(col_lat) || is.na(col_lon)) {
    stop("Columnas minimas faltantes en regiones priorizadas: Region, Proyecto, Latitud y Longitud.")
  }
  df2 <- df %>%
    rename(!!sym("Region") := !!sym(col_region)) %>%
    rename(!!sym("Proyecto") := !!sym(col_proy)) %>%
    rename(!!sym("Latitud") := !!sym(col_lat), !!sym("Longitud") := !!sym(col_lon))
  if (!is.na(col_sit)) df2 <- rename(df2, !!sym("Situación") := !!sym(col_sit))
  if (!is.na(col_acc)) df2 <- rename(df2, !!sym("Acción") := !!sym(col_acc))
  if (!is.na(col_modo)) df2 <- rename(df2, !!sym("Modo") := !!sym(col_modo))
  df2 %>% mutate(Latitud = to_num(Latitud), Longitud = to_num(Longitud))
}

load_project_data <- function(path = ruta_excel) {
  tryCatch({
    stopifnot(file.exists(path))
    normalize_project_data(read_excel(path))
  }, error = function(e) { message("Excel proyectos: ", e$message); NULL })
}

load_region_project_data <- function(path = ruta_regiones) {
  tryCatch({
    stopifnot(file.exists(path))
    normalize_region_project_data(read_excel(path))
  }, error = function(e) { message("Excel regiones: ", e$message); NULL })
}

load_app_data <- function() {
  c(
    load_spatial_layers(),
    list(
      Dato_Proyectos = load_project_data(),
      Dato_Regiones = load_region_project_data()
    )
  )
}

