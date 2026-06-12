
# ============================================================
# MONITOREO DE CPU Y RAM DE UNA APP SHINY (proceso hijo)
# ============================================================

# 0) Paquetes
req_pkgs <- c("ps", "callr", "ggplot2")
to_install <- req_pkgs[!suppressWarnings(sapply(req_pkgs, requireNamespace, quietly = TRUE))]
if (length(to_install)) install.packages(to_install)
library(ps)
library(callr)
library(ggplot2)

# 1) Directorios de salida
outdir <- file.path("tests", "Computational")
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
ts_tag <- format(Sys.time(), "%Y%m%d_%H%M%S")
csv_file  <- file.path(outdir, paste0("metrics_", ts_tag, ".csv"))
plot_file <- file.path(outdir, paste0("metrics_plot_", ts_tag, ".png"))

# 2) Ruta de la app
app_dir <- "~/Library/Mobile Documents/com~apple~CloudDocs/Proyecto empredimiento/Nuevo plan de trabajo/R programación/Almauro/Tablero_Ligero"

# 3) Arrancar la app en proceso hijo
p <- callr::r_bg(function(app_dir) {
  options(shiny.launch.browser = TRUE)
  if (!requireNamespace("shiny", quietly = TRUE)) install.packages("shiny")
  shiny::runApp(app_dir, launch.browser = TRUE)
}, args = list(app_dir = app_dir))

pid <- p$get_pid()
h <- ps::ps_handle(pid)
message("✅ App Shiny lanzada en proceso hijo. PID: ", pid)

# 4) Helpers robustos
get_named_numeric <- function(x, name) {
  if (is.null(x)) return(NA_real_)
  if (is.list(x) || !is.null(names(x))) {
    val <- x[[name]]
    return(suppressWarnings(as.numeric(val)))
  }
  NA_real_
}

get_rss_mb <- function(h) {
  mi <- ps::ps_memory_info(h)
  rss_bytes <- get_named_numeric(mi, "rss")
  rss_bytes / (1024^2)
}

get_cpu_pct <- function(h, prev_cpu, prev_wall, ncpu) {
  ct <- ps::ps_cpu_times(h)
  now <- Sys.time()
  delta_cpu <- (get_named_numeric(ct, "user") + get_named_numeric(ct, "system")) -
    (get_named_numeric(prev_cpu, "user") + get_named_numeric(prev_cpu, "system"))
  delta_wall <- as.numeric(difftime(now, prev_wall, units = "secs"))
  cpu_pct <- if (!is.na(delta_wall) && delta_wall > 0) (delta_cpu / delta_wall) * 100 / ncpu else NA_real_
  list(cpu_pct = cpu_pct, ct = ct, now = now)
}

# 5) Bucle de muestreo
ncpu <- tryCatch(parallel::detectCores(logical = TRUE), error = function(e) 1)
interval_sec <- 1.0
samples <- data.frame(t_sec = numeric(), rss_mb = numeric(), cpu_percent = numeric(), n_threads = integer())

t0 <- Sys.time()
prev_cpu <- ps::ps_cpu_times(h)
prev_wall <- Sys.time()

while (p$is_alive()) {
  rss_mb <- tryCatch(get_rss_mb(h), error = function(e) NA_real_)
  cpu_info <- tryCatch(get_cpu_pct(h, prev_cpu, prev_wall, ncpu), error = function(e) {
    list(cpu_pct = NA_real_, ct = prev_cpu, now = Sys.time())
  })
  n_thr <- tryCatch({
    thr <- ps::ps_threads(h)
    if (is.data.frame(thr)) nrow(thr) else length(thr)
  }, error = function(e) NA_integer_)
  
  # Validar que todas las variables tengan longitud 1 y no sean vacías
  if (length(rss_mb) == 1 && length(cpu_info$cpu_pct) == 1 && length(cpu_info$now) == 1 && length(n_thr) == 1) {
    samples <- rbind(samples, data.frame(
      t_sec = as.numeric(difftime(cpu_info$now, t0, units = "secs")),
      rss_mb = rss_mb,
      cpu_percent = cpu_info$cpu_pct,
      n_threads = n_thr
    ))
  } else {
    message("⚠️ Iteración saltada por datos incompletos.")
  }
  
  prev_cpu <- cpu_info$ct
  prev_wall <- cpu_info$now
  Sys.sleep(interval_sec)
}

# 6) Guardar métricas
write.csv(samples, csv_file, row.names = FALSE)
message("📄 CSV guardado en: ", csv_file)

# 7) Estadísticos y gráfico
peak_rss  <- max(samples$rss_mb, na.rm = TRUE)
peak_cpu  <- max(samples$cpu_percent, na.rm = TRUE)
mean_rss  <- mean(samples$rss_mb, na.rm = TRUE)
mean_cpu  <- mean(samples$cpu_percent, na.rm = TRUE)

message(sprintf("🔎 Pico RAM: %.1f MB | Promedio RAM: %.1f MB", peak_rss, mean_rss))
message(sprintf("🔎 Pico CPU: %.1f%% | Promedio CPU: %.1f%%", peak_cpu, mean_cpu))

scale_factor <- if (is.finite(peak_cpu) && peak_cpu > 0) max(1, peak_rss / peak_cpu) else 1
gg <- ggplot(samples, aes(x = t_sec)) +
  geom_line(aes(y = rss_mb, color = "RAM (MB)"), size = 0.9, na.rm = TRUE) +
  geom_line(aes(y = cpu_percent * scale_factor, color = sprintf("CPU (%%) x%.1f", scale_factor)), size = 0.9, na.rm = TRUE) +
  labs(title = "Consumo de RAM y CPU del proceso Shiny",
       subtitle = sprintf("Pico RAM: %.1f MB | Pico CPU: %.1f%%", peak_rss, peak_cpu),
       x = "Tiempo (seg)", y = "Valor (ver leyenda)", color = "Métrica") +
  theme_minimal(base_size = 12)

ggsave(plot_file, gg, width = 10, height = 6, dpi = 160)
message("🖼️ Gráfico guardado en: ", plot_file)
message("✅ Monitoreo finalizado.")
