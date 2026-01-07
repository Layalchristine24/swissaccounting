#' Calculate Private Account Balance
#'
#' @description
#' Calculates the private account balance by processing ledger entries for a specified period.
#' This function is used to track personal withdrawals and contributions to the business,
#' with support for multiple languages and automatic category aggregation. The private
#' account balance is calculated based on the operating result, with positive results
#' increasing the private account and negative results decreasing it.
#'
#' @param ledger_file character Path to the CSV ledger file
#' @param min_date character,Date Start date (YYYY-MM-DD)
#' @param max_date character,Date End date (YYYY-MM-DD)
#' @param language character Language for descriptions ("en", "fr", "de").
#'   Defaults to "fr"
#'
#' @return data.frame A data frame with private account details:
#'   \describe{
#'     \item{account_number}{Integer. Account identifier (2850)}
#'     \item{account_description}{Character. Account description in selected language}
#'     \item{sum_amounts}{Numeric. Total balance of the private account}
#'     \item{account_base_category}{Integer. First digit of account number}
#'     \item{high_category}{Integer. First two digits of account number}
#'     \item{intermediate_category}{Integer. First three digits of account number}
#'   }
#'
#' @examples
#' \dontrun{
#' private_account <- get_private_account(
#'   ledger_file = "path/to/ledger.csv",
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   language = "fr"
#' )
#' }
#'
#' @seealso
#' \code{\link{get_balance_accounts}} for generating balance sheets
#' \code{\link{get_income_statement}} for generating income statements
#' \code{\link{get_operating_result}} for calculating operating results
#' \code{\link{aggregate_accounts}} for category aggregation
#'
#' @export
#' @autoglobal
get_private_account <- function(
  ledger_file,
  min_date,
  max_date,
  language = "fr"
) {
  my_ledger <- read_ledger_csv(ledger_file)
  selected_ledger <- select_ledger_language(my_ledger, language)

  operating_result <-
    get_operating_result(
      ledger_file = ledger_file,
      min_date = min_date,
      max_date = max_date,
      language = language
    )

  abs(operating_result) |>
    mutate(
      account_number = 2850L,
      debit_account = if_else(
        operating_result < 0,
        account_number,
        NA_integer_
      ),
      credit_account = if_else(
        operating_result >= 0,
        account_number,
        NA_integer_
      )
    ) |>
    left_join(selected_ledger, by = join_by(account_number)) |>
    aggregate_accounts()
}
