#' Consolidate Multiple Language Account Plans
#'
#' @description
#' Combines accounting plans from different languages (English, French, German)
#' into a single consolidated data frame, matching accounts by their account
#' numbers.
#'
#' @param my_accounts_model_en data.frame English account plan with columns:
#'   account_number, account_type, account_description. Defaults to
#'   accounts_model_en
#' @param my_accounts_model_fr data.frame French account plan with columns:
#'   account_number, account_type, account_description. Defaults to
#'   accounts_model_fr
#' @param my_accounts_model_de data.frame German account plan with columns:
#'   account_number, account_type, account_description. Defaults to
#'   accounts_model_de
#'
#' @return data.frame A consolidated data frame with columns:
#'   \item{account_number}{Integer. Unique account identifier}
#'   \item{account_type_en}{Character. Account type in English}
#'   \item{account_description_en}{Character. Account description in English}
#'   \item{account_type_fr}{Character. Account type in French}
#'   \item{account_description_fr}{Character. Account description in French}
#'   \item{account_type_de}{Character. Account type in German}
#'   \item{account_description_de}{Character. Account description in German}
#'
#' @examples
#' consolidated <- consolidate_accounting_plans()
#' # View first few accounts in all languages
#' head(consolidated)
#'
#' @autoglobal
consolidate_accounting_plans <- function(
    my_accounts_model_en = accounts_model_en,
    my_accounts_model_fr = accounts_model_fr,
    my_accounts_model_de = accounts_model_de) {
  my_accounts_model_en |>
    rename(
      account_type_en = account_type,
      account_description_en = account_description
    ) |>
    left_join(
      my_accounts_model_fr |>
        rename(
          account_type_fr = account_type,
          account_description_fr = account_description
        ),
      by = join_by(account_number)
    ) |>
    left_join(
      my_accounts_model_de |>
        rename(
          account_type_de = account_type,
          account_description_de = account_description
        ),
      by = join_by(account_number)
    )
}
