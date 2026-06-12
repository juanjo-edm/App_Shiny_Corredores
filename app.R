# Punto de entrada de la aplicacion Shiny.
source(file.path("R", "packages.R"))
load_app_packages()

source(file.path("R", "config.R"))
source(file.path("R", "utils.R"))
source(file.path("R", "data_loaders.R"))
source(file.path("R", "corredores.R"))
source(file.path("R", "regiones.R"))
source(file.path("R", "map_helpers.R"))
source(file.path("R", "ui.R"))
source(file.path("R", "server.R"))

diagnose_app_paths()
invisible(list2env(load_app_data(), envir = globalenv()))

shinyApp(ui = app_ui(), server = app_server)
