# Nodos, tramos y colores de regiones priorizadas.
## 4.4) Regiones Priorizadas (colores, nodos y tramos) ----
# Paleta fija para relleno de regiones
region_fill_colors <- c("Catatumbo" = "#66c2a5", "Cauca" = "#fc8d62", "Chocó" = "#8da0cb")

# === Coordenadas (lon, lat) para nodos de trazos de Regiones Priorizadas (WGS84) ===
coords_regiones <- list(
  "Chocó" = data.frame(
    ciudad = c("Quibdó","El Carmen de Atrato","Ciudad Bolívar","Medellín","Tadó","Pueblo Rico","Pereira"),
    lon    = c(-76.65835, -76.14205, -76.02528, -75.57151, -76.56487, -76.03026, -75.69488),
    lat    = c(  5.69188,   5.89862,   5.85389,   6.24500,   5.26598,   5.22263,   4.81428)
  ),
  "Cauca" = data.frame(
    ciudad = c("Santander de Quilichao","Cajibío","Popayán","El Tambo","Timbío","Rosas","Patía"),
    lon    = c(-76.48494, -76.57039, -76.61316, -76.81029, -76.68194, -76.73986, -77.05273),
    lat    = c(  3.00945,   2.62271,   2.43823,   2.45199,   2.35278,   2.26093,   2.06895)
  ),
  "Catatumbo" = data.frame(
    ciudad = c("La Mata","Convención","El Tarra","Tibú","Teorama","Ayacucho","Guamalito"),
    lon    = c(-73.63572, -73.33694, -73.09489, -72.73583, -73.28639, -72.79141, -73.46810),
    lat    = c(  8.608
                 
                 ,   8.46806,   8.57562,   8.63895,   8.43528,   9.07083,   8.57528)
  )
)

# === Tramos por Región (Cauca y Catatumbo actualizados) ===
segmentos_regiones <- list(
  "Chocó" = rbind(
    data.frame(desde = "Quibdó",               hasta = "El Carmen de Atrato"),
    data.frame(desde = "El Carmen de Atrato",  hasta = "Ciudad Bolívar"),
    data.frame(desde = "Ciudad Bolívar",       hasta = "Medellín"),
    data.frame(desde = "Quibdó",               hasta = "Tadó"),
    data.frame(desde = "Tadó",                 hasta = "Pueblo Rico"),
    data.frame(desde = "Pueblo Rico",          hasta = "Pereira")
  ),
  "Cauca" = rbind(
    data.frame(desde = "Santander de Quilichao", hasta = "Cajibío"),
    data.frame(desde = "Cajibío",                hasta = "Popayán"),
    data.frame(desde = "Popayán",                hasta = "El Tambo"),  # ramal
    data.frame(desde = "Popayán",                hasta = "Timbío"),    # ramal
    data.frame(desde = "Timbío",                 hasta = "Rosas"),
    data.frame(desde = "Rosas",                  hasta = "Patía"),
    data.frame(desde = "Patía",                  hasta = "El Tambo")
  ),
  "Catatumbo" = rbind(
    data.frame(desde = "La Mata",     hasta = "Convención"),
    data.frame(desde = "Convención",  hasta = "El Tarra"),
    data.frame(desde = "El Tarra",    hasta = "Tibú")
  )
)

