# Validacion de costos de Cloud Run en BigQuery.
#
# Variables requeridas:
# - GCP_PROJECT_ID: proyecto de Google Cloud.
# - BQ_BILLING_DATASET: dataset de exportacion de billing.
# - BQ_BILLING_TABLE: tabla de exportacion de billing.
#
# Autenticacion:
# - Si GOOGLE_APPLICATION_CREDENTIALS apunta a una llave JSON local, se usa esa llave.
# - Si no, bigrquery usa Application Default Credentials.

suppressPackageStartupMessages({
  library(DBI)
  library(bigrquery)
  library(dplyr)
})

options(scipen = 999)

required_env <- function(name) {
  value <- Sys.getenv(name)
  if (identical(value, "")) {
    stop("Define la variable de entorno ", name, call. = FALSE)
  }
  value
}

project_id <- required_env("GCP_PROJECT_ID")
billing_dataset <- required_env("BQ_BILLING_DATASET")
billing_table <- required_env("BQ_BILLING_TABLE")
credentials_path <- Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS")

if (!identical(credentials_path, "")) {
  bq_auth(path = credentials_path)
} else {
  bq_auth()
}

bq_project_datasets(project_id)

con <- dbConnect(
  bigrquery::bigquery(),
  project = project_id,
  dataset = billing_dataset,
  billing = project_id
)

tabla_costos <- tbl(con, billing_table)

tabla_costos |>
  head(10) |>
  collect()
