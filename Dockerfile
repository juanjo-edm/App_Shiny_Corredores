# Imagen optimizada con soporte geoespacial incluido
FROM rocker/geospatial:4.3.1

# Variable obligatoria para Cloud Run
ENV PORT=8080

# Directorio de trabajo
WORKDIR /app

# Instalar solo paquetes R necesarios (sf ya viene optimizado)
RUN R -e "install.packages(c( \
    'shiny', \
    'leaflet', \
    'smoothr', \
    'magrittr', \
    'readxl', \
    'htmltools', \
    'dplyr' \
    ), repos='https://cloud.r-project.org/')"

# Copiar proyecto
COPY . /app

# Exponer puerto
EXPOSE 8080

# Comando simple y robusto
CMD R -e "shiny::runApp('/app', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8080)))"