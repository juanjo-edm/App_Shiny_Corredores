source_app_modules <- function(load_data = FALSE) {
  repo_root <- find_repo_root()
  Sys.setenv(APP_ROOT = repo_root)

  source(file.path(repo_root, "R", "packages.R"))
  load_app_packages()

  source(file.path(repo_root, "R", "config.R"))
  source(file.path(repo_root, "R", "utils.R"))
  source(file.path(repo_root, "R", "data_loaders.R"))
  source(file.path(repo_root, "R", "corredores.R"))
  source(file.path(repo_root, "R", "regiones.R"))
  source(file.path(repo_root, "R", "map_helpers.R"))

  if (isTRUE(load_data)) {
    old_wd <- setwd(repo_root)
    on.exit(setwd(old_wd), add = TRUE)
    list2env(load_app_data(), envir = globalenv())
  }

  source(file.path(repo_root, "R", "ui.R"))
  source(file.path(repo_root, "R", "server.R"))
}

find_repo_root <- function(start = getwd()) {
  current <- normalizePath(start, mustWork = TRUE)
  repeat {
    if (file.exists(file.path(current, "app.R"))) {
      return(current)
    }
    parent <- dirname(current)
    if (identical(parent, current)) {
      stop("No se pudo encontrar la raiz del repo con app.R", call. = FALSE)
    }
    current <- parent
  }
}
