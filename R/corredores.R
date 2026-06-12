# Nodos, tramos y paleta de corredores logisticos.
## 4.1) Corredores (nodos base) ----
corredores <- list(
  "Bogotá – Buenaventura – Ipiales" = data.frame(
    ciudad = c("Bogotá","Girardot","Armenia","Neiva","Hobo (Huila)","Popayán","Buga","Cali","Loboguerrero","Buenaventura","Pasto","Ipiales","Tumaco"),
    lon = c(-74.0721,-74.8019,-75.6750,-75.2519,-75.4511,-76.6147,-76.2978,-76.5320,-76.6687,-76.9969,-77.2811,-77.6400,-78.7650),
    lat = c( 4.7110, 4.3003, 4.5350, 2.9386, 2.5825, 2.4448, 3.9009, 3.4516, 3.7636, 3.8894, 1.2136, 0.8281, 1.8100)
  ),
  "Cali – Medellín – Cartagena" = data.frame(
    ciudad = c("Cali","Cartago","Pereira","Medellín","Armenia","Manizales","Montería","Turbo","Sincelejo","Cartagena"),
    lon = c(-76.5320,-75.9117,-75.6961,-75.5812,-75.6811,-75.5174,-75.8814,-76.7283,-75.3978,-75.4794),
    lat = c( 3.4516, 4.7464, 4.8143, 6.2442, 4.5350, 5.0703, 8.7489, 8.0926, 9.3047, 10.3910)
  ),
  "Bogotá – Barranquilla" = data.frame(
    ciudad = c("Bogotá","La Dorada","Bosconia","Santa Marta","Barranquilla","Cartagena","Maicao (La Guajira)","Valledupar","Bosconia*","Cartagena*"),
    lon = c(-74.0721,-74.6642,-73.8781,-74.1990,-74.7813,-75.4794,-72.2400,-73.2532,-73.8781,-75.4794),
    lat = c( 4.7110, 5.4478, 9.9737, 11.2408, 10.9685, 10.3910, 11.3830, 10.4631, 9.9737, 10.3910)
  ),
  "Bogotá – Cúcuta" = data.frame(
    ciudad = c("Bogotá","Tunja","Duitama","Pamplona","Cúcuta","Aguachica","Bucaramanga","Barrancabermeja"),
    lon = c(-74.0721,-73.3678,-72.9289,-72.64654046102444,-72.5050,-73.6150,-73.1198,-73.85472),
    lat = c( 4.7110, 5.5353, 5.8266, 7.373391481983761, 7.8942, 8.3083, 7.1254, 7.06528)
  ),
  "Medellín – Bucaramanga" = data.frame(
    ciudad = c("Medellín","Puerto Berrío","Barrancabermeja","Bucaramanga"),
    lon = c(-75.5812,-74.4850,-73.8615,-73.1198),
    lat = c( 6.2442, 6.4941, 7.0653, 7.1254)
  ),
  "Bogotá – Yopal" = data.frame(
    ciudad = c("Bogotá","Villavicencio","El Porvenir","San José del Guaviare","Aguazul","Sogamoso","Chocontá","Yopal",
               "Tame","Saravena","Arauca","Saravena*","Cravo Norte","Monterrey (Casanare)"),
    lon = c(-74.0721,-73.6359,-71.399193,-72.6459,-72.5560,-72.9440,-73.6833,-72.3959,-71.7590,-71.8720,-70.7580,-71.8720,-69.429774,-72.89575),
    lat = c( 4.7110, 4.1420, 4.737641, 2.5660, 5.1720, 5.7190, 5.0670, 5.3476, 6.4600, 6.9190, 7.0847, 6.9190, 6.101016, 4.87802)
  ),
  "Bogotá – Puerto Asís" = data.frame(
    ciudad = c("Bogotá","Girardot","Neiva","Altamira","Florencia","San Vicente del Caguán","Mocoa","Pasto","Puerto Asís","Puerto Colón"),
    lon = c(-74.0721,-74.8019,-75.2519,-75.8333,-75.6131,-74.8031,-76.6450,-77.2811,-76.5000,-76.4960),
    lat = c( 4.7110, 4.3003, 2.9386, 2.0333, 1.6144, 2.0000, 1.1467, 1.2136, 0.5133, 0.4780)
  )
)
## 4.2) Tramos de Corredores ----
tramos_1 <- data.frame(
  desde = c("Bogotá","Girardot","Girardot","Neiva","Hobo (Huila)","Armenia","Buga","Buga","Cali","Cali","Loboguerrero","Popayán","Pasto","Ipiales"),
  hasta = c("Girardot","Armenia","Neiva","Hobo (Huila)","Popayán","Buga","Cali","Loboguerrero","Loboguerrero","Popayán","Buenaventura","Pasto","Ipiales","Tumaco")
)
tramos_2 <- data.frame(
  desde = c("Cali","Cartago","Cartago","Pereira","Pereira","Medellín","Medellín","Montería","Montería","Sincelejo"),
  hasta = c("Cartago","Pereira","Medellín","Armenia","Manizales","Montería","Turbo","Turbo","Sincelejo","Cartagena")
)
tramos_3 <- data.frame(
  desde = c("Bogotá","La Dorada","Bosconia","Santa Marta","Barranquilla","Santa Marta","Maicao (La Guajira)","Valledupar","Bosconia*","Cartagena*"),
  hasta = c("La Dorada","Bosconia","Santa Marta","Barranquilla","Cartagena","Maicao (La Guajira)","Valledupar","Bosconia*","Cartagena*",NA)
)
tramos_4 <- data.frame(
  desde = c("Bogotá","Tunja","Duitama","Pamplona","Cúcuta","Bucaramanga","Pamplona","Bogotá","Bucaramanga"),
  hasta = c("Tunja","Duitama","Pamplona","Cúcuta","Aguachica","Pamplona","Cúcuta","Bucaramanga","Barrancabermeja")
)
tramos_5 <- data.frame(
  desde = c("Medellín","Puerto Berrío","Barrancabermeja"),
  hasta = c("Puerto Berrío","Barrancabermeja","Bucaramanga")
)
tramos_6 <- data.frame(
  desde = c("Bogotá","Villavicencio","Villavicencio","Aguazul","Aguazul","Aguazul","Yopal","Tame","Tame","Arauca","El Porvenir","Villavicencio","Monterrey (Casanare)","Chocontá"),
  hasta = c("Villavicencio","El Porvenir","San José del Guaviare","Sogamoso","Chocontá","Yopal","Tame","Saravena","Arauca","Saravena*","Cravo Norte","Monterrey (Casanare)","Aguazul","Monterrey (Casanare)")
)
tramos_7 <- data.frame(
  desde = c("Bogotá","Girardot","Neiva","Altamira","Altamira","Altamira","Florencia","San Vicente del Caguán","Mocoa","Mocoa","Puerto Asís","Puerto Asís"),
  hasta = c("Girardot","Neiva","Altamira","Florencia","Florencia","San Vicente del Caguán","Mocoa","Mocoa","Pasto","Puerto Asís","Puerto Colón",NA)
)
segmentos <- list(
  "Bogotá – Buenaventura – Ipiales" = tramos_1,
  "Cali – Medellín – Cartagena"     = tramos_2,
  "Bogotá – Barranquilla"           = tramos_3,
  "Bogotá – Cúcuta"                 = tramos_4,
  "Medellín – Bucaramanga"          = tramos_5,
  "Bogotá – Yopal"                  = tramos_6,
  "Bogotá – Puerto Asís"            = tramos_7
)
pal_corredores <- leaflet::colorFactor("Set1", domain = names(corredores))
