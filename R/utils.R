# Helpers generales compartidos por carga de datos y renderizado.
safe_find <- function(names_vec, patterns, ignore.case = TRUE){
  for (p in patterns){
    idx <- grep(p, names_vec, ignore.case = ignore.case, perl = TRUE)
    if (length(idx) > 0) return(names_vec[idx[1]])
  }
  NA_character_
}
to_num <- function(x){
  if (is.numeric(x)) return(as.numeric(x))
  x <- gsub(",", ".", as.character(x), fixed = TRUE)
  x <- gsub("[\u2212\u2013\u2014]", "-", x) # − – —
  suppressWarnings(as.numeric(x))
}
na_to_dash <- function(x){
  x_chr <- as.character(x)
  ifelse(is.na(x_chr) | trimws(x_chr) == "", "—", x_chr)
}
to4326 <- function(g){
  if (is.null(g)) return(NULL)
  if (is.na(sf::st_crs(g))) return(sf::st_set_crs(g, 4326))
  if (!is.null(sf::st_crs(g)$epsg) && sf::st_crs(g)$epsg != 4326) return(sf::st_transform(g, 4326))
  g
}
fix_polygon_holes <- function(sf_obj, buffer_deg = 0.0005) {
  sf_obj <- to4326(sf_obj)
  sf_obj <- sf::st_make_valid(sf_obj)
  try({
    if (requireNamespace("smoothr", quietly = TRUE)) {
      sf_obj <- smoothr::fill_holes(sf_obj, threshold = Inf)
    } else {
      sf_obj <- sf::st_buffer(sf_obj, buffer_deg)
      sf_obj <- sf::st_buffer(sf_obj, -buffer_deg)
      sf_obj <- sf::st_make_valid(sf_obj)
    }
  }, silent = TRUE)
  sf_obj
}

