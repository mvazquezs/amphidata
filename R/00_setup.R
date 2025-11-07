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
    'DT', 'htmltools', 'knitr', 'webshot', 'webshot2', 'shiny',
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