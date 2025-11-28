# --- Càrrega de Paquets ---

#' @title Carrega i instal·la els paquets necessaris
#' @description Aquesta funció utilitza el paquet 'pacman' per comprovar, instal·lar (si cal) i carregar totes les dependències de R per a l'anàlisi. També configura algunes opcions globals de la sessió, com evitar la creació de fitxers .RData i .Rhistory.
#' @param update_packages Lògic. Si és `TRUE`, intenta actualitzar tots els paquets a la seva darrera versió. Per defecte és `FALSE`.
#' @return No retorna cap valor, però carrega els paquets a l'entorn global.
#' @import pacman
#' @importFrom utils install.packages
#' @importFrom crayon bold blue
#' @seealso \code{\link[pacman]{p_load}}
#' @rdname amphi_load_packages
#' @export
#' @examples
#' # Carregar tots els paquets necessaris
#' # amphi_load_packages()
#' 
#' # Carregar i forçar l'actualització
#' # amphi_load_packages(update_packages = TRUE)
amphi_load_packages <- function(
  update_packages = FALSE) {

  ### Assegura que 'pacman' estigui instal·lat i carregat
  if (!requireNamespace('pacman', quietly = TRUE)) {
  
    utils::install.packages('pacman')
  
  }

### Configura el repositori de CRAN
  local({
    r <- getOption('repos')
    r['CRAN'] <- 'https://cloud.r-project.org/'
    options(repos = r)
  })

### Llista de paquets a carregar
  packages_to_load <- c(
    'devtools', 'quarto', 'usethis', 'crayon', 'janitor',
    'dplyr', 'tibble', 'readxl', 'forcats', 'data.table', 'stringr',
    'rlang', 'purrr', 'tidyr', 'missForest', 'psych',
    'DT', 'htmltools', 'knitr', 'webshot', 'webshot2', 'shiny', 'ggpubr',
    'gtsummary', 'gt', 'gtExtras', 'flextable', 'huxtable',
    'rstatix', 'Hmisc',
    'showtext', 'extrafont', 'extrafontdb', 'countrycode', 'sysfonts',
    'viridis', 'ggplot2', 'plotly')

### Carrega o instal·la els paquets amb pacman
  pacman::p_load(
    char = packages_to_load,
    install = TRUE,
    update = update_packages)
  
  # Opcions addicionals de la sessió
  options(width = getOption('width'))

  # missatge
  message(
    crayon::bold(crayon::blue('i')),
    crayon::black(' Els paquets han estat carregats correctament'))

}

#' @title Aplica formats comuns a taules DT
#' @description Aquesta funció és un embolcall (`wrapper`) que simplifica l'aplicació
#'   de formats comuns a les taules creades amb el paquet `DT`. Permet encadenar
#'   formats com `formatStyle`, `formatRound` i `formatPercentage` d'una manera
#'   declarativa i consistent.
#' @param df L'objecte `datatable` al qual s'aplicarà el format, normalment rebut a través d'un pipe (`%>%`).
#' @param columns Un vector de noms de columna a les quals aplicar el format.
#' @param format Un string que especifica el tipus de format a aplicar. Valors
#'   vàlids són: `"style"`, `"round"`, `"percentage"`.
#' @param ... Arguments addicionals que es passen a la funció de format de `DT`
#'   corresponent.
#'   \itemize{
#'     \item Per a `format = "style"`:
#'       \itemize{
#'         \item `n_intervals` (per defecte `19`): Nombre d'intervals per a la paleta de colors.
#'         \item `paleta` (per defecte `colorRampPalette(...)`): Una funció que genera una paleta de colors.
#'         \item Altres arguments de `formatStyle` com `backgroundSize`, `backgroundRepeat`, `backgroundPosition`.
#'       }
#'     \item Per a `format = "round"`: `digits` (per defecte `2`).
#'     \item Per a `format = "percentage"`: `digits` (per defecte `0`).
#'   }
#' @return L'objecte datatable amb el format aplicat.
#' @import DT
#' @seealso
#'   Documentació oficial de DT: \url{https://rstudio.github.io/DT/}
#'   Referència de funcions de format: \url{https://rstudio.github.io/DT/functions.html}
#' @rdname format_dtable
#' @export
#' @examples
#' if (interactive()) {
#'   library(DT)
#'
#'   data <- data.frame(
#'     Producte = LETTERS[1:5],
#'     Vendes = c(1500, 800, 2200, 500, 1200),
#'     Creixement = c(0.053, -0.021, 0.128, 0.015, 0.08),
#'     QuotaMercat = c(0.25, 0.12, 0.35, 0.08, 0.20)
#'   )
#'
#'   DT::datatable(data) %>%
#'     format_dtable(columns = "Vendes", format = "style") %>%
#'     format_dtable(columns = "Creixement", format = "percentage", digits = 1) %>%
#'     format_dtable(columns = "QuotaMercat", format = "round", digits = 3)
#' }
format_dtable <- function(
  df,
  columns,> DT::datatable(
+   df_g %>%
+     dplyr::mutate(
+       nom = stringr::str_to_title(nom)) %>%
+     dplyr::mutate_at(
+       vars(starts_with('amplada'), starts_with('alcada')), 
+       ~ round(., digits = 1)) %>%
+     dplyr::mutate_at(
+       vars(starts_with('superficie'), starts_with('ratio')), 
+       ~ round(., digits = 2)) %>%
+     dplyr::mutate_at(
+       vars(starts_with('etiq_')), 
+       ~ as.factor(.)) %>%
+     dplyr::select(
+       nom,
+       starts_with('etiq_'), 
+       amplada_arena, alcada_arena, 
+       amplada_general, alcada_general, 
+       starts_with('superficie'), 
+       ratio_arena, nombre_places,
+       -superficie_cavea),
+     colnames = c(
+       'Nom' = 'nom',
+       'País' = 'etiq_pais_i',
+       'Província' = 'etiq_provincia_i',
+       'Regió' = 'etiq_provincia_ii',
+       'Amplada arena (m)' = 'amplada_arena',
+       'Alçada arena (m)' = 'alcada_arena',
+       'Amplada general (m)' = 'amplada_general',
+       'Alçada general (m)' = 'alcada_general',
+       'Superfície arena (m2)' = 'superficie_arena',
+       'Superfície general (m2)' = 'superficie_general',
+       'Ratio arena' = 'ratio_arena',
+       'Aforament' = 'nombre_places'),
+     extensions = 'Buttons',
+     filter = 'top',
+     options = list(
+       pageLength = 10,
+       lengthMenu = c(5, 10, 25, 50, 100),
+       autoWidth = TRUE,
+       scrollX = TRUE,
+       dom = 'Bfrtip',
+       buttons = list(
+         list(extend = 'csv', text = 'CSV'),
+         list(extend = 'excel', text = 'XLSX'),
+         list(extend = 'colvis', text = 'Ocultar Columnes')),
+     caption = 'Dimensions d\'amfiteatres segons Golvin (1988)')) %>%
+   format_dtable(
+     df_object = .,
+     columns = c('Superfície arena (m2)', 'Superfície general (m2)', 'Aforament'),
+     format = 'style')

Error in `format_dtable()`:
! argument "df" is missing, with no default
Show Traceback
  format,
  ...) {

  # Helper per a valors per defecte (equivalent a l'operador %||% de rlang)
  `%||%` <- function(a, b) if (is.null(a)) b else a

  args <- list(...)
  
  switch(format,
    "style" = {
      n_intervals <- args$n_intervals %||% 19
      paleta_func <- args$paleta %||% colorRampPalette(c('#B0E0E6', 'white', '#E9967A'))
      
      # Arguments d'estil addicionals amb valors per defecte
      backgroundSize <- args$backgroundSize %||% '100% 90%'
      backgroundRepeat <- args$backgroundRepeat %||% 'no-repeat'
      backgroundPosition <- args$backgroundPosition %||% 'center'

      # Accedir a les dades força l'avaluació de qualsevol expressió
      # pendent (com una cadena de dplyr) que es va passar a DT::datatable.
      df_data <- df$x$data
      
      if (is.null(df_data)) {
        stop("No s'han pogut trobar les dades dins de l'objecte datatable. ",
             "Assegura't que el dataframe no és buit.")
      }
      
      all_values <- unlist(df_data[, columns, drop = FALSE])
      rang_dades <- range(all_values, na.rm = TRUE)

      cuts <- seq(from = rang_dades[1], to = rang_dades[2], length.out = n_intervals)
      rampa_color <- paleta_func(n_intervals + 1)

      DT::formatStyle(
        table = df,
        columns = columns,
        backgroundColor = styleInterval(cuts, rampa_color),
        backgroundSize = backgroundSize,
        backgroundRepeat = backgroundRepeat,
        backgroundPosition = backgroundPosition
      )
    },
    "round" = {
      DT::formatRound(table = df, columns = columns, ...)
    },
    "percentage" = {
      DT::formatPercentage(table = df, columns = columns, ...)
    },
    stop("Format no reconegut. Utilitza 'style', 'round', o 'percentage'.")
  )
}
