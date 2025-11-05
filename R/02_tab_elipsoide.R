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
#'        la fórmula 'Area_A' (A = pi * a * b).
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
  tipus_area = 'Area_A', 
  focus_major = FALSE, 
  focus_minor = FALSE)
{

  # 1. Capturem els arguments (Tidy Evaluation)
  major_a_sym <- dplyr::enquo(major_a)
  major_b_sym <- dplyr::enquo(major_b)
  minor_a_sym <- dplyr::enquo(minor_b)
  minor_b_sym <- dplyr::enquo(minor_b)

  # 2. Funció interna per calcular les mètriques d'una el·lipse
  .calculate_metrics <- function(a_full, b_full, prefix) {
    
    # 2.1. Ajustar a i b si cal dividir per 2
    scale <- ifelse(semieix, 2, 1)
    a <- a_full / scale # Semieix major
    b <- b_full / scale # Semieix menor
    
    # Comprovem que 'a' sigui el semieix major (a >= b)
    if (!all(a >= b, na.rm = TRUE)) {
      warning(paste("Per a l'el·lipse", prefix, "el semieix major (a) ha de ser >= al semieix menor (b). Es reassignaran valors si cal."))
      # Utilitzem pmax i pmin per intercanviar si b > a, només per als càlculs
      a_calc <- pmax(a, b)
      b_calc <- pmin(a, b)
      a <- a_calc
      b <- b_calc
    }

    metrics <- tibble::tibble(a = a, b = b)
    
    # 2.2. Càlcul de l'Àrea (A = pi * a * b)
    if ('Area_A' %in% tipus_area) {
      metrics <- metrics %>% dplyr::mutate(
        Area_A = base::pi * a * b
      )
    }
    
    # 2.3. Càlcul dels Perímetres
    if ('simple' %in% tipus_perimetre) {
      metrics <- metrics %>% dplyr::mutate(
        Perimeter_P1 = base::pi * (a + b)
      )
    }
    if ('quadratica' %in% tipus_perimetre) {
      metrics <- metrics %>% dplyr::mutate(
        Perimeter_PQ = 2 * base::pi * base::sqrt((a^2 + b^2) / 2)
      )
    }
    if ('ramanujan_i' %in% tipus_perimetre) {
      metrics <- metrics %>% dplyr::mutate(
        Perimeter_RI = base::pi * (3 * (a + b) - base::sqrt((3 * a + b) * (a + 3 * b)))
      )
    }
    if ('ramanujan_ii' %in% tipus_perimetre) {
      metrics <- metrics %>% dplyr::mutate(
        h = (a - b)^2 / (a + b)^2,
        Perimeter_RII = base::pi * (a + b) * (1 + (3 * .data$h) / (10 + base::sqrt(4 - 3 * .data$h)))
      ) %>% dplyr::select(-.data$h) # Eliminem la variable h temporal
    }

    # 2.4. Càlcul de Focus i Excentricitat
    if ((prefix == "Major_" && focus_major) || (prefix == "Minor_" && focus_minor)) {
      # Càlcul de la distància focal 'c' (c = sqrt(a^2 - b^2))
      metrics <- metrics %>% dplyr::mutate(
        # Distància del centre al focus (c)
        focus_dist_c = base::sqrt(a^2 - b^2),
        # Distància entre focus (2c)
        Focus_Distance = 2 * focus_dist_c,
        # Excentricitat (e = c/a)
        Excentricity = focus_dist_c / a,
        # Coordenades dels focus (assumint el centre a (0,0) i eix major a l'eix x)
        Focus_F1 = -1 * focus_dist_c, # Coordenada x de F1
        Focus_F2 = focus_dist_c       # Coordenada x de F2
      ) %>% dplyr::select(-focus_dist_c) # Eliminem la variable c temporal
    }
    
    # 2.5. Seleccionar i Renombrar
    metrics %>%
      dplyr::select(-a, -b) %>%
      dplyr::rename_with(~ paste0(prefix, .x))
  }

  # 3. Càlcul de Mètriques per a l'El·lipse Major (Amfiteatre)
  major_metrics <- .calculate_metrics(
    a_full = dplyr::pull(df, !!major_a_sym),
    b_full = dplyr::pull(df, !!major_b_sym),
    prefix = "Major_"
  )

  # 4. Càlcul de Mètriques per a l'El·lipse Minor (Arena)
  minor_metrics <- .calculate_metrics(
    a_full = dplyr::pull(df, !!minor_a_sym),
    b_full = dplyr::pull(df, !!minor_b_sym),
    prefix = "Minor_"
  )

  # 5. Combinar els resultats amb el data frame original
  df_result <- dplyr::bind_cols(df, major_metrics, minor_metrics)

  return(df_result)
}