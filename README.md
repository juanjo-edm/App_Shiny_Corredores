# Corredores Logisticos de Colombia

Aplicacion Shiny para visualizar corredores logisticos, regiones priorizadas, proyectos, rios principales y red ferrea sobre un mapa interactivo de Colombia.

## Que muestra la app

- Corredores logisticos principales con nodos y tramos.
- Regiones priorizadas con trazos, nodos y poligonos territoriales cuando el `.rds` esta disponible.
- Proyectos asociados a corredores y regiones desde archivos Excel.
- Capas opcionales de rios principales y red ferrea.
- Popups con situacion y accion de cada proyecto.
- Ajuste automatico de zoom segun la seleccion del usuario.

## Estructura del repo

```text
.
├── app.R                         # Punto de entrada de Shiny
├── R/
│   ├── packages.R                # Carga de paquetes
│   ├── config.R                  # Variables de entorno y rutas
│   ├── utils.R                   # Helpers generales
│   ├── data_loaders.R            # Carga y normalizacion de datos
│   ├── corredores.R              # Nodos, tramos y paletas de corredores
│   ├── regiones.R                # Regiones priorizadas y tramos
│   ├── map_helpers.R             # Helpers de Leaflet, popups e iconos
│   ├── ui.R                      # Interfaz
│   └── server.R                  # Logica reactiva
├── data/
│   ├── proyectos_corredores.xlsx
│   ├── Regiones_Priorizadas.xlsx
│   └── derivado/
│       ├── regiones.rds
│       ├── rios_ne_colombia.rds
│       └── ferrea_4326_simplificada.rds
├── notebooks/
│   ├── preparacion_geodata.Rmd   # Trazabilidad de preparacion de datos
│   └── data/raw/                 # Insumos crudos curados
├── www/
│   └── bandera.png
├── tests/
│   ├── testthat.R
│   └── testthat/
└── Dockerfile
```

## Requisitos

- R 4.3 o superior recomendado.
- Paquetes R principales:
  - `shiny`
  - `leaflet`
  - `dplyr`
  - `readxl`
  - `htmltools`
  - `sf`
  - `smoothr` opcional para mejorar poligonos.
  - `testthat` y `shinytest2` para pruebas.

Instalacion local sugerida:

```r
install.packages(c(
  "shiny", "leaflet", "dplyr", "readxl", "htmltools", "sf",
  "smoothr", "testthat", "shinytest2"
))
```

## Ejecutar localmente

Desde la raiz del repo:

```r
shiny::runApp()
```

Tambien puedes ejecutar:

```bash
Rscript app.R
```

La app toma el puerto desde `PORT`; si no existe, usa `8080`.

## Variables de entorno

| Variable | Uso | Default |
| --- | --- | --- |
| `PORT` | Puerto usado por Shiny y Cloud Run. | `8080` |
| `STOP_APP_ON_SESSION_END` | Detiene la app cuando se cierra la ultima sesion. | `true` |
| `INACTIVITY_TIMEOUT_SECS` | Cierra sesiones inactivas. | `300` |

Para validaciones de costos en BigQuery:

| Variable | Uso |
| --- | --- |
| `GCP_PROJECT_ID` | ID del proyecto de Google Cloud. |
| `BQ_BILLING_DATASET` | Dataset de exportacion de billing. |
| `BQ_BILLING_TABLE` | Tabla de exportacion de billing. |
| `GOOGLE_APPLICATION_CREDENTIALS` | Ruta opcional a una llave JSON local. Si no se define, se usan Application Default Credentials. |

## Datos esperados

La app espera estos archivos:

- `data/proyectos_corredores.xlsx`: proyectos de corredores. Columnas minimas reconocidas: proyecto, latitud y longitud. Si existen, tambien usa situacion, accion, corredor y modo.
- `data/Regiones_Priorizadas.xlsx`: proyectos por region priorizada. Columnas minimas reconocidas: region, proyecto, latitud y longitud.
- `data/derivado/regiones.rds`: lista de objetos `sf` por region.
- `data/derivado/rios_ne_colombia.rds`: capa `sf` de rios.
- `data/derivado/ferrea_4326_simplificada.rds`: capa `sf` de red ferrea.

Las capas espaciales se convierten a EPSG:4326 cuando hace falta.

## Trazabilidad de datos

La carpeta `notebooks/` contiene el cuaderno `preparacion_geodata.Rmd`, que documenta paso a paso como se preparan los datos crudos y escribe las salidas finales que usa la app en `data/`.

Ese cuaderno no se ejecuta en runtime. Sirve para auditoria y reconstruccion de datos cuando sea necesario.

Para renderizarlo desde la raiz del repo:

```r
rmarkdown::render("notebooks/preparacion_geodata.Rmd")
```

Los insumos crudos curados estan en `notebooks/data/raw/`. No se incluyen archivos temporales de RStudio, locks de shapefiles ni `.zip` duplicados. Las capas crudas opcionales `RedDepartamental.*` y `RedVial_OD_5.*` se dejan fuera de Git por limites de tamano de GitHub.

## Pruebas

Ejecuta:

```bash
Rscript tests/testthat.R
```

Las pruebas cubren:

- Helpers de columnas, numeros y CRS.
- Normalizacion de datos de proyectos.
- Carga del Excel principal si esta disponible.
- Smoke test de UI: mapa, botones principales y logo de bandera.
- Registro basico del objeto Shiny.

## Docker

Construir imagen:

```bash
docker build -t corredores-logisticos .
```

Ejecutar:

```bash
docker run --rm -p 8080:8080 -e PORT=8080 corredores-logisticos
```

Abrir:

```text
http://localhost:8080
```

## Despliegue en Cloud Run

El `Dockerfile` usa `rocker/geospatial:4.3.1`, que incluye soporte geoespacial adecuado para `sf`.

Pasos generales:

1. Construir y publicar la imagen en Artifact Registry o Container Registry.
2. Desplegar en Cloud Run exponiendo el puerto `8080`.
3. Configurar `PORT=8080` si el entorno no lo inyecta automaticamente.
4. Ajustar `STOP_APP_ON_SESSION_END` e `INACTIVITY_TIMEOUT_SECS` segun el comportamiento deseado.
5. No incluir llaves JSON en la imagen. Usar cuentas de servicio, secretos o Application Default Credentials.

## Seguridad

No subas credenciales al repositorio. La raiz incluye `.gitignore` para excluir archivos como `.env`, `.Renviron`, `*.json`, `*.pem` y `*.key`.

Si necesitas autenticar scripts de BigQuery, usa `GOOGLE_APPLICATION_CREDENTIALS` apuntando a una llave local fuera del repo o usa Application Default Credentials.
