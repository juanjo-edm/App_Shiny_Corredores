test_that("safe_find returns the first matching column", {
  source_app_modules()

  cols <- c("Nombre del proyecto", "Latitud", "Longitud")

  expect_equal(safe_find(cols, c("^Proyecto$", "nombre.*proyecto")), "Nombre del proyecto")
  expect_true(is.na(safe_find(cols, c("^Region$"))))
})

test_that("to_num normalizes decimal separators and dash variants", {
  source_app_modules()

  expect_equal(to_num(c("1,5", "2.25")), c(1.5, 2.25))
  expect_equal(to_num("\u22123,5"), -3.5)
  expect_true(is.na(to_num("sin dato")))
})

test_that("to4326 assigns missing CRS without changing geometry", {
  source_app_modules()

  point <- sf::st_sfc(sf::st_point(c(-74, 4)))
  converted <- to4326(point)

  expect_equal(sf::st_crs(converted)$epsg, 4326)
})
