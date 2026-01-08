#' Consolidate Multiple Language Account Plans
#'
#' @description
#' Combines accounting plans from different languages (English, French, German)
#' into a single consolidated data frame, matching accounts by their account
#' numbers. This function is used internally to provide multi-language support
#' for account descriptions and types throughout the package.
#'
#' @param my_accounts_model_en data.frame English account plan with columns:
#'   \describe{
#'     \item{account_number}{Integer. The account identifier}
#'     \item{account_type}{Character. Account type in English}
#'     \item{account_description}{Character. Account description in English}
#'   }
#'   Defaults to get_accounting_plan_template("en")
#' @param my_accounts_model_fr data.frame French account plan with columns:
#'   \describe{
#'     \item{account_number}{Integer. The account identifier}
#'     \item{account_type}{Character. Account type in French}
#'     \item{account_description}{Character. Account description in French}
#'   }
#'   Defaults to get_accounting_plan_template("fr")
#' @param my_accounts_model_de data.frame German account plan with columns:
#'   \describe{
#'     \item{account_number}{Integer. The account identifier}
#'     \item{account_type}{Character. Account type in German}
#'     \item{account_description}{Character. Account description in German}
#'   }
#'   Defaults to get_accounting_plan_template("de")
#'
#' @return data.frame A consolidated data frame with columns:
#'   \describe{
#'     \item{account_number}{Integer. Unique account identifier}
#'     \item{account_type_en}{Character. Account type in English}
#'     \item{account_description_en}{Character. Account description in English}
#'     \item{account_type_fr}{Character. Account type in French}
#'     \item{account_description_fr}{Character. Account description in French}
#'     \item{account_type_de}{Character. Account type in German}
#'     \item{account_description_de}{Character. Account description in German}
#'   }
#'
#' @examples
#' # Consolidate default account plans
#' consolidated <- consolidate_accounting_plans()
#' head(consolidated)
#'
#' \dontrun{
#' # Use custom account plans
#' custom_consolidated <- consolidate_accounting_plans(
#'   my_accounts_model_en = custom_en_plan,
#'   my_accounts_model_fr = custom_fr_plan,
#'   my_accounts_model_de = custom_de_plan
#' )
#' }
#'
#' @seealso
#' \code{\link{get_accounting_plan_template}} for account plans
#'
#' @export
#' @autoglobal
consolidate_accounting_plans <- function(
  my_accounts_model_en = get_accounting_plan_template("en"),
  my_accounts_model_fr = get_accounting_plan_template("fr"),
  my_accounts_model_de = get_accounting_plan_template("de")
) {
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
