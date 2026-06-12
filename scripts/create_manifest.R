# Genera manifest.json para desplegar la app en Posit Connect Cloud.
#
# Uso desde la raiz del repo:
#   Rscript scripts/create_manifest.R

find_repo_root <- function(start = getwd()) {
  current <- normalizePath(start, mustWork = TRUE)

  repeat {
    if (file.exists(file.path(current, "app.R"))) {
      return(current)
    }

    parent <- dirname(current)
    if (identical(parent, current)) {
      stop("No se pudo encontrar la raiz del repo con app.R.", call. = FALSE)
    }

    current <- parent
  }
}

repo_root <- find_repo_root()
app_file <- file.path(repo_root, "app.R")
manifest_file <- file.path(repo_root, "manifest.json")

if (!file.exists(app_file)) {
  stop("No existe app.R en la raiz del repo: ", repo_root, call. = FALSE)
}

if (!requireNamespace("rsconnect", quietly = TRUE)) {
  install.packages("rsconnect", repos = "https://cloud.r-project.org")
}

old_wd <- setwd(repo_root)
on.exit(setwd(old_wd), add = TRUE)

runtime_dirs <- c("R", "data", "www")
runtime_files <- unlist(
  lapply(runtime_dirs, function(path) {
    if (!dir.exists(path)) {
      return(character())
    }
    list.files(path, recursive = TRUE, all.files = FALSE, full.names = TRUE, no.. = TRUE)
  }),
  use.names = FALSE
)

app_files <- c("app.R", runtime_files)
app_files <- app_files[file.exists(app_files)]

rsconnect::writeManifest(
  appDir = repo_root,
  appFiles = app_files,
  appPrimaryDoc = "app.R"
)

if (!file.exists(manifest_file)) {
  stop("rsconnect::writeManifest() no genero manifest.json.", call. = FALSE)
}

message("Manifest generado: ", manifest_file)
