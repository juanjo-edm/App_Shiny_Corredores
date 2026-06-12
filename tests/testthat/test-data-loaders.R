test_that("project data normalization produces canonical columns", {
  source_app_modules()

  raw <- data.frame(
    "Nombre del proyecto" = "Proyecto 1",
    "Situacion actual" = "En estructuracion",
    "Accion" = "Priorizar",
    "Corredor" = "Bogotá - Yopal",
    "Modo" = "Carretero",
    "Latitud" = "4,5",
    "Longitud" = "-74,1",
    check.names = FALSE
  )

  normalized <- normalize_project_data(raw)

  expect_true(all(c("Proyecto", "Situación", "Acción", "Corredor", "Modo", "Latitud", "Longitud") %in% names(normalized)))
  expect_equal(normalized$Latitud, 4.5)
  expect_equal(normalized$Longitud, -74.1)
})

test_that("region project normalization requires region and coordinates", {
  source_app_modules()

  raw <- data.frame(
    "Region" = "Cauca",
    "Proyecto" = "Proyecto regional",
    "Latitud" = "2.4",
    "Longitud" = "-76.6",
    check.names = FALSE
  )

  normalized <- normalize_region_project_data(raw)

  expect_true(all(c("Region", "Proyecto", "Latitud", "Longitud") %in% names(normalized)))
  expect_equal(normalized$Region, "Cauca")
  expect_equal(normalized$Latitud, 2.4)
})

test_that("configured project workbook exists and can be normalized", {
  source_app_modules()

  skip_if_not(file.exists(ruta_excel), paste("No existe", ruta_excel))

  projects <- load_project_data()

  expect_s3_class(projects, "data.frame")
  expect_true(all(c("Proyecto", "Latitud", "Longitud") %in% names(projects)))
})
