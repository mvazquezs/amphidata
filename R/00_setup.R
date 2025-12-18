# --- Package Loading and Configuration ---

#' @title Load and install essential dependencies for 'salutUNEDstats'
#' @description This function uses the 'pacman' package to check, install (if necessary),
#' and load the key dependencies of the 'salutUNEDstats' package for solving the exercises.
#'
#' @param update_packages Logical. If `TRUE`, it attempts to update all packages
#' to their latest version. Defaults to `FALSE`.
#' @return No return value, but loads the packages into the global environment.
#' @import pacman
#' @importFrom utils install.packages
#' @importFrom crayon bold blue
#' @rdname amphi_load_packages 
#' 
#' @export
amphi_load_packages  <- function(
  update_packages = FALSE) {

### Ensure 'pacman' is installed and loaded
  if (!requireNamespace(c('languageserver', 'devtools'), quietly = TRUE)) {

    utils::install.packages(
      c(
      'pacman','languageserver', 'devtools', 
      'labelled', 'dplyr', 'e1071'), 
      repos = 'https://cloud.r-project.org/')
  
  }

### Configure CRAN repository and UTF-8
  local({
    r <- getOption('repos')
    r['CRAN'] <- 'https://cloud.r-project.org/'
    options(repos = r)
    options(encoding = 'UTF-8') 
  })

### List of packages to load (Optimized and Minimalist)
  packages_to_load <- c(
    'stats', 'broom',
    'rstatix', 'nortest', 'missForest', 'psych',
    'tidyverse', 'janitor',
    'DT', 'quarto',
    'ggplot2', 'viridis', 'scales',
    'DT', 'htmltools', 'webshot', 'webshot2', 'shiny', 
    'ggpubr', 'extrafont', 'extrafontdb', 'countrycode', 'sysfonts',
    'viridis', 'ggplot2', 'plotly')

### Load or install packages with pacman
  pacman::p_load(
    char = packages_to_load,
    install = TRUE,
    update = update_packages)
  
### Additional session options
  options(width = getOption('width'))

### Confirmation message
  message(
    crayon::bold(crayon::blue('i')),
    crayon::black(' All packages for amphidata have been loaded.'))

}