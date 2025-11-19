# R Script per renderitzar el Quarto Dashboard

# 1. Carregar la llibreria Quarto
# Assegureu-vos que teniu el paquet 'quarto' instal·lat. Si no és així, executeu: install.packages('quarto')
# També necessiteu tenir instal·lat el motor Quarto al vostre sistema.
library(quarto)

# 2. Definir els noms dels fitxers .qmd que voleu renderitzar
fitxers_a_renderitzar <- c(
  "01_golvin_dashboard.qmd", 
  "02_vazquez_dashboard.qmd"
)

# 3. Iterar i Renderitzar cada fitxer
for (fitxer_qmd in fitxers_a_renderitzar) {
  
  tryCatch({
    
    # Comprovació per evitar errors si el fitxer no existeix
    if (!file.exists(fitxer_qmd)) {
      message(paste("AVÍS: El fitxer", fitxer_qmd, "no s'ha trobat al directori de treball. Saltant."))
      next
    }
    
    message(paste("Iniciant la renderització de:", fitxer_qmd))
    
    # Renderitza el document al format definit a la capçalera YAML.
    quarto_render(
      input = fitxer_qmd, 
      quiet = FALSE
    )
    
    fitxer_sortida <- sub("\\.qmd$", ".html", fitxer_qmd)
    message(paste("Renderització completada amb èxit. Dashboard guardat a:", fitxer_sortida))
    
  }, error = function(e) {
    
    # Gestió d'errors per capturar qualsevol problema específic de la renderització
    warning(paste("ERROR: La renderització de", fitxer_qmd, "ha fallat. Missatge:", e$message))
    
  })
}

# Opcional: Obrir automàticament el darrer fitxer HTML al navegador
# if (exists("fitxer_sortida")) {
#   browseURL(fitxer_sortida)
# }