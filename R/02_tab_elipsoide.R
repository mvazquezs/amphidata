#' Calcula l'àrea, perímetres, focus i excentricitat per a dues el·lipses (Amfiteatre i Arena).
#'
#' Aquesta funció afegeix al data frame d'entrada mètriques calculades per a dues el·lipses
#' (Major i Minor), basant-se en les longituds dels seus eixos o semieixos.
#'
#' @param df Un data frame o tibble d'entrada que conté les dimensions dels eixos.
#' @param major_a El nom de la columna (sense cometes) que conté l'eix major 'a' de l'el·lipse principal (Amfiteatre).
#' @param major_b El nom de la columna (sense cometes) que conté l'eix menor 'b' de l'el·lipse principal (Amfiteatre).
#' @param minor_a El nom de la columna (sense cometes) que conté l'eix major 'a' de l'el·lipse secundària (Arena).
#' @param minor_b El nom de la columna (sense cometes) que conté l'eix menor 'b' de l'el·lipse secundària (Arena).
#' @param semieix Un valor lògic (TRUE/FALSE) que indica si les columnes d'entrada representen la longitud dels
#'        eixos sencers (TRUE, cal dividir per 2 per obtenir el semieix) o si ja són els semieixos (FALSE).
#' @param tipus_perimetre Un vector de caràcters que especifica les aproximacions de perímetre a calcular.
#'        Opcions vàlides: 'simple', 'quadratica', 'ramanujan_i', 'ramanujan_ii'.
#' @param tipus_area La cadena de caràcters que indica el nom de l'àrea a calcular. Actualment, només s'accepta
#'        la fórmula 'area' (A = pi * a * b).
#' @param focus_major Un valor lògic (TRUE/FALSE) per calcular la distància focal, l'excentricitat i les coordenades
#'        dels focus (F1 i F2) per a l'el·lipse Major.
#' @param focus_minor Un valor lògic (TRUE/FALSE) per calcular la distància focal, l'excentricitat i les coordenades
#'        dels focus (F1 i F2) per a l'el·lipse Minor.
#'
#' @details
#' Les aproximacions de perímetre disponibles són:
#' \itemize{
#'   \item \strong{simple ($P_1$):} \eqn{P_1 = \pi (a + b)} (per a semieixos)
#'   \item \strong{quadratica ($P_Q$):} \eqn{P_Q = 2 \pi \sqrt{(a^2 + b^2)/2}}
#'   \item \strong{ramanujan_i ($P_{RI}$):} \eqn{P_{RI} = \pi [3(a+b) - \sqrt{(3a+b)(a+3b)}]}
#'   \item \strong{ramanujan_ii ($P_{RII}$):} \eqn{P_{RII} \approx \pi (a+b) ( 1 + \frac{3h}{10 + \sqrt{4-3h}} )}
#' }
#' L'\strong{Àrea} calculada és: \eqn{A = \pi \cdot \frac{a}{2} \cdot \frac{b}{2}}
#'
#' @return El data frame d'entrada (`df`) amb les noves columnes de mètriques calculades.
#'
#' @importFrom dplyr mutate select rename starts_with pull bind_cols rename_with
#' @importFrom rlang .data enquo
#'
#' @examples
#' library(dplyr)
#' df_dims <- tibble(
#'   id = 1:2, Amphi_A = c(100, 80), Amphi_B = c(80, 60),
#'   Arena_A = c(50, 40), Arena_B = c(30, 20)
#' )
#'
#' df_result <- calculate_amphitheater_metrics(
#'   df_dims, major_a = Amphi_A, major_b = Amphi_B,
#'   minor_a = Arena_A, minor_b = Arena_B,
#'   semieix = TRUE,
#'   tipus_perimetre = c('quadratica', 'ramanujan_ii'),
#'   tipus_area = 'Area_A',
#'   focus_major = TRUE, focus_minor = FALSE
#' )
#' print(df_result)
#'
#' @rdname elipsoide_metrics
#' @export
elipsoide_metrics <- function(
  df,
  major_a,
  major_b,
  minor_a,
  minor_b,
  semieix = TRUE,
  tipus_perimetre = c('simple', 'quadratica', 'ramanujan_i', 'ramanujan_ii'),
  tipus_area = 'area',
  focus_major = FALSE,
  focus_minor = FALSE)
{
  
  # 1. Capturem els arguments (Tidy Evaluation)
  major_a_sym <- rlang::enquo(major_a)
  major_b_sym <- rlang::enquo(major_b)
  minor_a_sym <- rlang::enquo(minor_a)
  minor_b_sym <- rlang::enquo(minor_b)
  
  # 2. Funció interna per calcular les mètriques d'una el·lipse
  .calculate_metrics <- function(
    a_full, 
    b_full,
    noms,
    sufix) {
    
    # 2.1. Ajustar a i b si cal dividir per 2
    scale <- ifelse(semieix, 2, 1)
    a <- a_full / scale # Semieix major
    b <- b_full / scale # Semieix menor
    
    # Comprovem que 'a' sigui el semieix major (a >= b)
    if (!all(a >= b, na.rm = TRUE) && !all(is.na(a) | is.na(b))) {
      
      incorrect_indices <- which(b > a)

        if (length(incorrect_indices) > 0) {
          
          message(paste0("Per a l'el·lipse '", sufix, "', els següents amfiteatres tenen b > a: ", paste(noms[incorrect_indices], collapse = ", ")))
        
        }
      
      warning(paste('Per a l\'el·lipse', sufix, 'el semieix major (a) ha de ser >= al semieix menor (b). Es reassignaran valors si cal.'))
      
      # Utilitzem pmax i pmin per intercanviar si b > a, només per als càlculs
      a_calc <- pmax(a, b, na.rm = TRUE)
      b_calc <- pmin(a, b, na.rm = TRUE)
      a <- a_calc
      b <- b_calc
    }
    
    metrics <- tibble::tibble(a = a, b = b)
    
    # 2.2. Càlcul de mètriques en una sola crida a dplyr::mutate
    metrics <- metrics %>%
      dplyr::mutate(
        # Àrea
        area = if ('area' %in% tipus_area) base::pi * a * b else NA,
        
        # Perímetres
        perimetre_P1 = if ('simple' %in% tipus_perimetre) base::pi * (a + b) else NA,
        perimetre_PQ = if ('quadratica' %in% tipus_perimetre) 2 * base::pi * base::sqrt((a^2 + b^2) / 2) else NA,
        perimetre_RI = if ('ramanujan_i' %in% tipus_perimetre) base::pi * (3 * (a + b) - base::sqrt((3 * a + b) * (a + 3 * b))) else NA,
        
        # Perímetre de Ramanujan II (amb variable temporal 'h')
        h = if ('ramanujan_ii' %in% tipus_perimetre) (a - b)^2 / (a + b)^2 else NA,
        perimetre_RII = if ('ramanujan_ii' %in% tipus_perimetre) base::pi * (a + b) * (1 + (3 * h) / (10 + base::sqrt(4 - 3 * h))) else NA,
        
        # Focus i Excentricitat
        focus_dist_c = if (isTRUE(focus_major || focus_minor)) base::sqrt(a^2 - b^2) else NA,
        focus_dist = ifelse(!is.na(focus_dist_c), 2 * focus_dist_c, NA),
        excentricitat_e = if (isTRUE(focus_major || focus_minor)) focus_dist_c / a else NA,
        focus_1 = ifelse(!is.na(focus_dist_c), -1 * focus_dist_c, NA),
        focus_2 = ifelse(!is.na(focus_dist_c), focus_dist_c, NA))
    
    # 2.3. Seleccionar i Renombrar
    metrics %>%
      dplyr::select(-a, -b, -focus_dist_c) %>%
      dplyr::rename_with(~ paste0(.x, '_', sufix))
  }
  
  # 3. Càlcul de Mètriques per a l'El·lipse Major (Amfiteatre)
  major_metrics <- .calculate_metrics(
    a_full = dplyr::pull(df, !!major_a_sym),
    b_full = dplyr::pull(df, !!major_b_sym),
    noms = dplyr::pull(df, nom),
    sufix = 'general')
  
  # 4. Càlcul de Mètriques per a l'El·lipse Minor (Arena)
  minor_metrics <- .calculate_metrics(
    a_full = dplyr::pull(df, !!minor_a_sym),
    b_full = dplyr::pull(df, !!minor_b_sym),
    noms = dplyr::pull(df, nom),
    sufix = 'arena') 
  
  # 5. Combinar els resultats amb el data frame original
  df_result <- dplyr::bind_cols(df, major_metrics, minor_metrics)
  
  return(df_result)
}