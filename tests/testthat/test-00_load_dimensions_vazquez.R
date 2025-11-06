# tests/testthat/00_test_load_dimensions_vazquez.R

# Carrega les llibreries necessàries per als tests
library(testthat)
library(dplyr)
library(tibble)

# Assegura't que les funcions a provar estiguin disponibles
# En un paquet, devtools::load_all() s'encarregaria d'això.
# Per a un script independent, carreguem les dependències manualment.
source('../../R/05_funcions_accessories.R') # amphi_read_data
source('../../R/00_dimensions_amfiteatres_vazquez.R')

# Inici del bloc de tests per a la funció load_dimensions_vazquez

# Mockup de la funció system.file per evitar dependre de la instal·lació del paquet
# Això assumeix que els arxius de dades estan a la ubicació correcta relativa al projecte
# Aquesta és una part complicada de provar sense un projecte/paquet formal.
# Si el test falla aquí, pot ser per no trobar els arxius CSV.

# Com que la funció depèn de fitxers externs, el test és més d'integració.
# Si els fitxers no existeixen, la funció hauria de fallar amb un error.
# Aquí assumim que existeixen per provar la lògica posterior.
df_vazquez <- load_dimensions_vazquez()

test_that('La funció retorna un tibble no buit', {
  expect_s3_class(df_vazquez, 'tbl_df')
  expect_true(nrow(df_vazquez) > 0)
  # El nombre de columnes per defecte és 32
  expect_equal(ncol(df_vazquez), 32)
})

# Test 2: Assegurar que la modificació de dades és correcta
test_that('Les columnes calculades i els tipus de dades són correctes', {
  # Comprova l'existència de columnes calculades
  expect_true('ratio_arena' %in% names(df_vazquez))
  expect_true('superficie_general' %in% names(df_vazquez))
  expect_true('provincia_romana' %in% names(df_vazquez)) # Afegida a partir del nom del fitxer
  
  # Comprova que les columnes numèriques siguin del tipus correcte
  expect_type(df_vazquez$ratio_arena, 'double')
  expect_type(df_vazquez$superficie_general, 'double')
  expect_type(df_vazquez$nombre_places, 'double')
  
  # Comprova que les columnes de caràcter siguin del tipus correcte
  expect_type(df_vazquez$nom, 'character')
  expect_type(df_vazquez$pais, 'character')
})

# Test 3: Assegurar que el filtratge de dades funciona
test_that('El filtratge per tipus edifici funciona', {
  df_amphitheater <- load_dimensions_vazquez(filtrar_edifici = 'amphitheater')
  
  # Comprova que totes les files són del tipus 'amphitheater'
  expect_equal(unique(df_amphitheater$t_building), 'amphitheater')
  expect_true(nrow(df_amphitheater) > 0)
  expect_false(nrow(df_amphitheater) == nrow(df_vazquez))
})

test_that('El filtratge per província funciona', {
  df_hispania <- load_dimensions_vazquez(filtrar_provincia = 'hispania')
  
  # Comprova que totes les files pertanyen a províncies d'Hispania
  expect_true(all(grepl('hispania', unique(df_hispania$provincia_romana))))
  expect_true(nrow(df_hispania) > 0)
  expect_false(nrow(df_hispania) == nrow(df_vazquez))
})

test_that('La selecció de columnes funciona', {
  df_seleccionat <- load_dimensions_vazquez(seleccionar_columnes = c(amplada_arena, alcada_arena))
  
  # Comprova que les columnes seleccionades existeixen, a més de les clau
  expect_true(all(c('index_id', 'nom', 't_building', 'provincia_romana', 'pais', 'amplada_arena', 'alcada_arena') %in% names(df_seleccionat)))
  expect_equal(ncol(df_seleccionat), 7)
})

# Test 4: Assegurar que les etiquetes es generen correctament
test_that('Les etiquetes (labels) es generen correctament', {
  df_etiquetes <- load_dimensions_vazquez(etiquetes = TRUE)
  
  # Comprova que les noves columnes d'etiquetes existeixen
  expect_true(all(c('etiq_provincia_i', 'etiq_provincia_ii', 'etiq_pais_i', 
                     'lb_provincia_i', 'lb_provincia_ii', 'lb_pais2_i', 'lb_pais3_i') %in% names(df_etiquetes)))
  
  # Comprova el contingut de les etiquetes per a una fila coneguda (p. ex. Hispania/Spain)
  df_hispania <- df_etiquetes %>% dplyr::filter(pais == 'spain')
  
  # Comprova el codi de provincia ad-hoc
  # Nota: Aquest test pot ser fràgil si les dades canvien. S'assumeix que 'hispania' existeix.
  if(nrow(df_hispania) > 0) {
    expect_equal(unique(df_hispania$lb_provincia_i)[1], 'HIS')
  }

  # Comprova els codis de país ISO
  if(nrow(df_hispania) > 0) {
    expect_equal(unique(df_hispania$lb_pais2_i), 'ES')
    expect_equal(unique(df_hispania$lb_pais3_i), 'ESP')
  }
  
  # Comprova el nom del país en català
  if(nrow(df_hispania) > 0) {
    expect_equal(unique(df_hispania$etiq_pais_i), 'Espanya')
  }
})