# Notebooks de trazabilidad

Esta carpeta contiene la bitacora reproducible de preparacion de datos para la app Shiny.

## Contenido

- `preparacion_geodata.Rmd`: cuaderno principal de preparacion de datos.
- `data/raw/`: insumos crudos curados usados por el cuaderno.

Los archivos en `data/raw/` se versionan para conservar trazabilidad cuando su tamano lo permite. No se copiaron archivos temporales de RStudio, historiales de sesion, locks de shapefiles ni `.zip` duplicados.

Las capas `RedDepartamental.*` y `RedVial_OD_5.*` quedan excluidas de Git porque superan los limites recomendados de GitHub. Si se necesitan para auditoria local, deben mantenerse fuera del control de versiones en `notebooks/data/raw/Capas de referencia/`.

## Que actualiza el cuaderno

Al ejecutar `preparacion_geodata.Rmd`, se escriben o actualizan:

- `../data/proyectos_corredores.xlsx`
- `../data/Regiones_Priorizadas.xlsx`
- `../data/derivado/rios_ne_colombia.rds`
- `../data/derivado/ferrea_4326_simplificada.rds`
- `../data/derivado/regiones.rds`

## Como ejecutarlo

Desde RStudio puedes abrir `preparacion_geodata.Rmd` y correr los chunks en orden.

Desde consola, en la raiz del repo:

```r
rmarkdown::render("notebooks/preparacion_geodata.Rmd")
```

El cuaderno usa rutas relativas al repo; no depende de rutas personales del computador.

## Nota sobre regiones

Los insumos crudos originales para `Regiones_Priorizadas.xlsx` y `regiones.rds` no estaban en la carpeta fuente inspeccionada. Para no perder trazabilidad, se guardaron snapshots en `data/raw/` y el cuaderno los copia a las rutas finales de la app.
