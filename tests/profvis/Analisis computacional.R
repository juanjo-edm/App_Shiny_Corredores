
# 1) Librerías necesarias
library(profvis)
library(shiny)
library(htmlwidgets)

# -------------------------------
# PERFILAR APP SIN GUARDAR ARCHIVO
# -------------------------------
profvis({
  runApp("~/Library/Mobile Documents/com~apple~CloudDocs/Proyecto empredimiento/Nuevo plan de trabajo/R programación/Almauro/Tablero_Ligero")
})

#Esto abre un visor interactivo en RStudio para analizar:
# - Tiempo por función
# - Uso de memoria
# - Llamadas internas

# -------------------------------
# PERFILAR APP Y GUARDAR COMO HTML
# -------------------------------
# p <- profvis({
#   runApp("~/Library/Mobile Documents/com~apple~CloudDocs/Proyecto empredimiento/Nuevo plan de trabajo/R programación/Almauro/Tablero_Ligero")
# })
# htmlwidgets::saveWidget(p, "perfil_shiny.html")
# Esto genera un archivo HTML portable para compartir el análisis.

# -------------------------------
# PERFILAR CON Rprof (más detallado)
# -------------------------------
# 1️⃣ Iniciar perfil con memoria
Rprof("tests/profvis/perfil_shiny.Rprof", memory.profiling = TRUE)

# Ejecutar la app (bloquea hasta cerrar)
runApp("~/Library/Mobile Documents/com~apple~CloudDocs/Proyecto empredimiento/Nuevo plan de trabajo/R programación/Almauro/Tablero_Ligero")

# Detener perfil
Rprof(NULL)

# -------------------------------
# 2️⃣ Resumir resultados
resumen <- summaryRprof("tests/profvis/perfil_shiny.Rprof", memory = "both")

# 3️⃣ Convertir a data frames
by_self  <- as.data.frame(resumen$by.self)   # Tiempo por función individual
by_total <- as.data.frame(resumen$by.total)  # Tiempo acumulado por función

# 4️⃣ Guardar como CSV
write.csv(by_self, "perfil_by_self.csv")
write.csv(by_total, "perfil_by_total.csv")
