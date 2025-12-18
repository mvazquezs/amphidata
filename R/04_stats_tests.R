# --- Function for two-sample comparisons (v5.8) ---

#' @title Perform statistical tests for multiple variables and groups using `rstatix`
#' 
#' @description 
#' A high-level wrapper designed to automate two-sample statistical tests across multiple 
#' response and independent variables. It handles grouping, listwise deletion of NAs, 
#' multiple testing corrections, and result formatting for easy reporting.
#'
#' @details 
#' **Missing Values Handling (Listwise Deletion):**
#' This function performs Listwise Deletion. Observations with `NA` values in either 
#' the response variable (`y_var`) or the independent variable (`x_var`) are 
#' automatically excluded. For paired tests, if one value of the pair is missing, 
#' the entire case is removed.
#' 
#' **Argument Compatibility Table:**
#' \tabular{lcccccc}{
#'   Test \tab paired \tab conf_level \tab alternative \tab mu/p \tab comparisons \tab ref_group \cr
#'   t_test \tab Yes \tab Yes \tab Yes \tab Yes \tab Yes \tab Yes \cr
#'   wilcox_test \tab Yes \tab Yes \tab Yes \tab Yes \tab Yes \tab Yes \cr
#'   sign_test \tab No* \tab No \tab Yes \tab Yes \tab Yes \tab Yes \cr
#'   binomial_test \tab No \tab Yes \tab Yes \tab Yes \tab No \tab No \cr
#'   prop_test \tab No \tab Yes \tab Yes \tab No \tab No \tab No \cr
#'   mcnemar_test \tab No* \tab No \tab No \tab No \tab No \tab No \cr
#' }
#' *Note: Sign and McNemar tests are inherently designed for paired/dependent data.
#'
#' @param df A `data.frame` or `tibble` in long format.
#' @param x_var Character vector of independent (grouping) variables.
#' @param y_var Character vector of response variables.
#' @param group_by Optional character vector of columns to stratify the analysis.
#' @param test Type of test: 't_test', 'wilcox_test', 'sign_test', 'binomial_test', 'prop_test', 'mcnemar_test'.
#' @param comparisons List of character vectors for specific pairwise comparisons.
#' @param paired Logical, whether samples are paired. Defaults to `FALSE`.
#' @param conf_level Confidence level. Defaults to 0.95.
#' @param alternative Hypothesis: 'two.sided', 'greater', or 'less'.
#' @param detailed Logical. Return detailed output? Defaults to `FALSE`.
#' @param ref_group Reference group for comparisons.
#' @param mu Theoretical mean or difference (used as 'p' for binomial). Defaults to 0 (or 0.5).
#' @param p_adjust_by Character vector of columns to group by before p-value adjustment.
#' @param method Correction method: 'holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY', 'fdr', 'none'.
#' @param p_digits Number of decimal places for p-value formatting.
#' @param trend Logical. If `TRUE`, uses a "trend" approach for p-values (P < 0.1).
#' @param formulas Logical. If `TRUE`, returns combined formula columns and hides individual ones.
#'
#' @return A `tibble` containing statistical results, adjusted p-values, and significance labels.
#' @export
stats_bitest <- function(
    df,
    x_var,
    y_var,
    group_by = NULL,
    test = c("t_test", "wilcox_test", "sign_test", "binomial_test", "prop_test", "mcnemar_test"),
    comparisons = NULL,
    paired = FALSE,
    conf_level = 0.95,
    alternative = "two.sided",
    ref_group = NULL,
    detailed = FALSE,
    mu = NULL,
    p_adjust_by = NULL,
    method = c('holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY',  'fdr', 'none'),
    p_digits = 3,
    trend = FALSE,
    formulas = FALSE) {
  
  # --- 1. Validació i selecció del test ---
  test_label <- base::match.arg(test)
  adj_method <- base::match.arg(method)
  test_f <- utils::getFromNamespace(test_label, "rstatix")

  # --- 2. Construcció de la graella de combinacions (l_grid) ---
  l_grid <- base::expand.grid(y = y_var, x = x_var, stringsAsFactors = FALSE)

  # --- 3. Definició del valor mu/p per defecte ---
  mu_val <- if (base::is.null(mu)) { if (test == "binomial_test") 0.5 else 0 } else { mu }

  # --- 4. Execució iterativa simplificada ---
  results <- purrr::pmap_dfr(l_grid, function(y, x) {
    
    # A. Preparació de dades (Filtre + Agrupació)
    df_clean <- df %>%
      dplyr::filter(dplyr::if_all(dplyr::all_of(c(y, x)), ~ !is.na(.x)))
    
    if (!base::is.null(group_by)) {
      df_clean <- df_clean %>% 
        dplyr::group_by(dplyr::across(dplyr::all_of(group_by)))
    }
    
    # B. Construcció de la fórmula
    l_form <- stats::as.formula(base::paste0(y, " ~ ", x))
    
    # C. Càlcul del test via nesting
    df_clean %>%
      tidyr::nest() %>%
      dplyr::mutate(
        test_results = purrr::map(data, function(.x) {
          # Preparació d'arguments
          arg_list <- base::list(
            data = .x, 
            formula = l_form, 
            detailed = detailed,
            p.adjust.method = 'none'
          )
          
          if (test != "mcnemar_test") arg_list$alternative <- alternative
          
          if (test %in% c("t_test", "wilcox_test", "sign_test")) {
            arg_list$comparisons <- comparisons
            arg_list$ref.group <- ref_group
            arg_list$mu <- mu_val
          }
          
          if (test %in% c("t_test", "wilcox_test")) arg_list$paired <- paired
          
          if (test %in% c("t_test", "wilcox_test", "binomial_test", "prop_test")) {
            arg_list$conf.level <- conf_level
          }
          
          if (test == "binomial_test") arg_list$p <- mu_val

          base::do.call(test_f, arg_list)
        })
      ) %>%
  dplyr::select(-data) %>%
  tidyr::unnest(cols = test_results) %>%
  # CORRECCIÓ: any_of requereix c()
  dplyr::select(-dplyr::any_of(c(".y.", "p.adj", "p.adj.signif"))) %>%
   # Afegim labels i el tipus de test aquí per evitar errors d'àmbit (scope)
  dplyr::mutate(
    y_var = y, 
    x_var = x)
  })

  if (isTRUE(formulas)) {
  
    results <- results %>%
      dplyr::mutate(
        l_formulas = base::paste0(y_var, " ~ ", x_var),
        l_groups = base::paste0(group1, " ~ ", group2)) %>%
      dplyr::select(
        -dplyr::any_of(c('y_var', 'x_var', 'group1', 'group2')))

  }

  if (!base::is.null(p_adjust_by)) {
    
    results <- results %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(p_adjust_by))) %>%
      tidyr::nest() %>%
      dplyr::mutate(
        data = purrr::map(data, ~ format_pvalue(
          .x, 
          p_col = 'p', 
          p_digits = p_digits, 
          method = method, 
          trend = trend))) %>%
        tidyr::unnest(cols = data) %>%
        dplyr::ungroup()

  } else {
    
    results <- format_pvalue(
      df = results,
      p_col = "p",
      p_digits = p_digits,
      method = method,
      trend = trend)
  }

results <- results %>%
  dplyr::select(
    dplyr::any_of(group_by),
    # 1. Variables
    dplyr::any_of(c('l_formulas', 'y_var', 'x_var')),
    # 2. Grups
    dplyr::any_of(c('l_groups', 'group1', 'group2')),
    # 3. N
    dplyr::any_of(c("n1", "n2", "n")),
    # 4. Estadística
    dplyr::any_of(c("statistic", "df")),
    # 5. Estimat (mitjanes, diferències, etc)
    dplyr::any_of(c("estimate", "conf.low", "conf.high")),
    # 6. P-valors (8 columnes generades per format_pvalue)
    raw_pval, raw_pval_text, raw_pval_signif,
    adj_pval, adj_pval_text, adj_pval_signif,
    # 7. Metadades del test
    dplyr::everything())

  # --- 5. Feedback per consola ---
  base::cat(
    crayon::bold(crayon::blue("i")),
    crayon::black(
      base::paste0(
        " S'han processat ", crayon::bold(base::nrow(l_grid)),
        " combinacions de variables per al test ", crayon::bold(test), ".\n"
      )
    )
  )

  return(results)
}

# --- Function for multi-sample comparisons and post-hoc tests ---

#' @title Perform multi-group statistical tests and post-hoc comparisons using `rstatix`
#' 
#' @description 
#' A high-level wrapper designed to automate multi-group tests (ANOVA, Kruskal-Wallis, Friedman) 
#' and their respective post-hoc comparisons across multiple response and independent variables.
#'
#' @details 
#' **Missing Values Handling (Listwise Deletion):**
#' This function performs Listwise Deletion. Observations with `NA` values in either 
#' the response variable (`y_var`) or the independent variable (`x_var`) are 
#' automatically excluded.
#' 
#' **Argument Compatibility Table:**
#' \tabular{lccccc}{
#'   Test \tab Type \tab paired \tab ref_group \tab detailed \tab Post-hoc nature \cr
#'   anova_test \tab Parametric \tab Yes/No \tab No \tab Yes \tab Global \cr
#'   welch_anova_test \tab Parametric \tab No \tab No \tab No \tab Global \cr
#'   kruskal_test \tab Non-Parametric \tab No \tab No \tab No \tab Global \cr
#'   friedman_test \tab Non-Parametric \tab Yes \tab No \tab No \tab Global \cr
#'   tukey_hsd \tab Post-hoc \tab No \tab No \tab Yes \tab Pairwise \cr
#'   dunn_test \tab Post-hoc \tab No \tab Yes \tab Yes \tab Pairwise \cr
#'   games_howell_test \tab Post-hoc \tab No \tab No \tab Yes \tab Pairwise \cr
#'   scheffe_test \tab Post-hoc \tab No \tab No \tab Yes \tab Pairwise \cr
#'   emmeans_test \tab Model-based \tab Yes/No \tab Yes \tab Yes \tab Pairwise/EMMs \cr
#' }
#'
#' @param df A `data.frame` or `tibble` in long format.
#' @param x_var Character vector of independent (grouping) variables.
#' @param y_var Character vector of response variables.
#' @param group_by Optional character vector of columns to stratify the analysis.
#' @param test Type of test: 'anova_test', 'kruskal_test', 'friedman_test', 'welch_anova_test', 'tukey_hsd', 'dunn_test', 'games_howell_test', 'scheffe_test', 'emmeans_test'.
#' @param paired Logical, whether samples are paired (used for ANOVA/Friedman/EMMs). Defaults to `FALSE`.
#' @param detailed Logical. Return detailed output? Defaults to `FALSE`.
#' @param ref_group Reference group (mainly for dunn_test or emmeans_test).
#' @param p_adjust_by Character vector of columns to group by before p-value adjustment.
#' @param method Correction method: 'holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY', 'fdr', 'none'.
#' @param p_digits Number of decimal places for p-value formatting.
#' @param trend Logical. If `TRUE`, uses a "trend" approach for p-values (P < 0.1).
#' @param formulas Logical. If `TRUE`, returns combined formula columns.
#'
#' @return A `tibble` containing statistical results and formatted p-values.
#' @export
stats_multitest <- function(
    df,
    x_var,
    y_var,
    group_by = NULL,
    test = c("anova_test", "kruskal_test", "friedman_test", "welch_anova_test", 
             "tukey_hsd", "dunn_test", "games_howell_test", "scheffe_test", "emmeans_test"),
    paired = FALSE,
    detailed = FALSE,
    ref_group = NULL,
    p_adjust_by = NULL,
    method = c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"),
    p_digits = 3,
    trend = FALSE,
    formulas = FALSE) {

  # --- 1. Validació i selecció del test ---
  test_label <- base::match.arg(test)
  adj_method <- base::match.arg(method)
  test_f <- utils::getFromNamespace(test_label, "rstatix")

  # --- 2. Construcció de la graella de combinacions ---
  l_grid <- base::expand.grid(y = y_var, x = x_var, stringsAsFactors = FALSE)

  # --- 3. Execució iterativa ---
  results <- purrr::pmap_dfr(l_grid, function(y, x) {
    
    # A. Preparació de dades
    df_clean <- df %>%
      dplyr::filter(dplyr::if_all(dplyr::all_of(c(y, x)), ~ !is.na(.x)))
    
    if (!base::is.null(group_by)) {
      df_clean <- df_clean %>% 
        dplyr::group_by(dplyr::across(dplyr::all_of(group_by)))
    }
    
    # B. Construcció dinàmica de la fórmula
    l_form <- stats::as.formula(base::paste0(y, " ~ ", x))
    
    # C. Càlcul del test via nesting
    df_clean %>%
      tidyr::nest() %>%
      dplyr::mutate(
        test_results = purrr::map(data, function(.x) {
          # Arguments base
          arg_list <- base::list(data = .x, formula = l_form)
          
          # Gestió d'arguments específics per test
          if (test_label %in% c("anova_test", "tukey_hsd", "dunn_test", 
                               "games_howell_test", "scheffe_test", "emmeans_test")) {
            arg_list$detailed <- detailed
          }
          
          # Arguments per a comparacions post-hoc o emmeans
          if (test_label %in% c("dunn_test", "emmeans_test")) {
            arg_list$ref.group <- ref_group
          }
          
          if (test_label %in% c("emmeans_test")) {
            arg_list$p.adjust.method <- "none" # Ajustarem nosaltres després
          }

          # Execució via do.call
          base::do.call(test_f, arg_list)
        })
      ) %>%
      dplyr::select(-data) %>%
      tidyr::unnest(cols = test_results) %>%
      # Neteja de columnes rstatix que puguin interferir amb el nostre format_pvalue
      dplyr::select(-dplyr::any_of(c(".y.", "p.adj", "p.adj.signif"))) %>%
      dplyr::mutate(
        y_var = y, 
        x_var = x,
        test_method = test_label
      )
  })

  # --- 4. Ajust de P-valors ---
  # Identificació de la columna de p-valor (pot variar segons el test de rstatix)
  possible_p <- c("p", "p.value", "p.adj") # emmeans a vegades ja retorna p.adj
  target_p <- base::intersect(possible_p, base::names(results))[1]
  
  if (base::is.na(target_p)) base::stop("No p-value column found in results.")

  if (!base::is.null(p_adjust_by)) {
    results <- results %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(p_adjust_by))) %>%
      tidyr::nest() %>%
      dplyr::mutate(data = purrr::map(data, function(.x) {
        format_pvalue_multi(.x, p_col = target_p, p_digits = p_digits, method = adj_method, trend = trend)
      })) %>%
      tidyr::unnest(cols = data) %>%
      dplyr::ungroup()
  } else {
    results <- format_pvalue_multi(df = results, p_col = target_p, p_digits = p_digits, method = adj_method, trend = trend)
  }

  # --- 5. Gestió de columnes de format "Fórmula" ---
  if (base::isTRUE(formulas)) {
    results <- results %>%
      dplyr::mutate(
        l_formulas = base::paste0(y_var, " ~ ", x_var)
      )
    if ("group1" %in% base::names(results)) {
       results <- results %>% dplyr::mutate(l_groups = base::paste0(group1, " ~ ", group2))
    }
    results <- results %>%
      dplyr::select(-dplyr::any_of(c("y_var", "x_var", "group1", "group2")))
  }

  if (!base::is.null(p_adjust_by)) {
    
    results <- results %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(p_adjust_by))) %>%
      tidyr::nest() %>%
      dplyr::mutate(
        data = purrr::map(data, ~ format_pvalue(
          .x, 
          p_col = 'p', 
          p_digits = p_digits, 
          method = method, 
          trend = trend))) %>%
        tidyr::unnest(cols = data) %>%
        dplyr::ungroup()

  } else {
    
    results <- format_pvalue(
      df = results,
      p_col = "p",
      p_digits = p_digits,
      method = method,
      trend = trend)
  }

  # --- 6. Selecció i Ordenació Final ---
  results <- results %>%
    dplyr::select(
      dplyr::any_of(group_by),
      dplyr::any_of(c("l_formulas", "y_var", "x_var")),
      dplyr::any_of(c("l_groups", "group1", "group2")),
      dplyr::any_of(c("n", "DFn", "DFd", "df")),
      dplyr::any_of(c("statistic", "F", "estimate")),
      raw_pval, raw_pval_text, raw_pval_signif,
      adj_pval, adj_pval_text, adj_pval_signif,
      test_method,
      dplyr::everything()
    )

  # --- 7. Feedback per consola ---
  base::cat(
    crayon::bold(crayon::blue("i")),
    crayon::black(
      base::paste0(" Multi-test processing complete. Method: ", crayon::bold(test_label), ".\n")
    )
  )

  return(results)
}