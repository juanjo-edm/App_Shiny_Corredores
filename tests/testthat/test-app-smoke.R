test_that("app UI exposes the map and main controls", {
  source_app_modules()
  Dato_Regiones <<- data.frame(Region = c("Catatumbo", "Cauca", "Chocó"))
  REGIONES_RDS <<- NULL

  html <- as.character(app_ui())

  expect_match(html, 'id="mapa"', fixed = TRUE)
  expect_match(html, 'id="btn_all"', fixed = TRUE)
  expect_match(html, 'id="btn_clear"', fixed = TRUE)
  expect_equal(logo_file, "bandera.png")
  expect_true(file.exists(app_path("www", logo_file)))
})

test_that("server function can be registered", {
  source_app_modules()
  Dato_Regiones <<- data.frame(Region = c("Catatumbo", "Cauca", "Chocó"))
  Dato_Proyectos <<- NULL
  REGIONES_RDS <<- NULL
  RIOS <<- NULL
  FERREA_SHP <<- NULL

  expect_type(app_server, "closure")
  expect_s3_class(shiny::shinyApp(ui = app_ui(), server = app_server), "shiny.appobj")
})
