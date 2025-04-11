#' Generate Balance Sheet Report
#'
#' @description
#' Generates a comprehensive balance sheet report from ledger data for a specified date range.
#' Implements both assets and liabilities calculations, with support for multiple languages.
#' The function filters out zero-amount entries to provide a clean balance sheet view.
#' Includes private account calculations and operating results. The balance sheet is generated
#' by aggregating all accounts that are not in the income statement (accounts 1-3 for assets
#' and 4-5 for liabilities).
#'
#' @param ledger_file character Path to the CSV ledger file containing
#'   financial transactions
#' @param min_date character,Date Optional. Minimum date to filter
#'   transactions (format: "YYYY-MM-DD")
#' @param max_date character,Date Optional. Maximum date to filter
#'   transactions (format: "YYYY-MM-DD")
#' @param language character Language code for account descriptions. One of
#'   "en", "fr", "de". Defaults to "fr"
#'
#' @return data.frame A data frame containing balance sheet data with columns:
#'   \itemize{
#'     \item{account_base_category}{Integer. First digit of account number (1 or 2)}
#'     \item{high_category}{Integer. First two digits of account number}
#'     \item{intermediate_category}{Integer. First three digits of account number}
#'     \item{account_number}{Integer. Full account number}
#'     \item{account_description}{Character. Account description in selected language}
#'     \item{sum_amounts}{Numeric. Total values for each account}
#'   }
#'
#' @examples
#' \dontrun{
#' # Generate balance sheet for specific date range in French
#' balance_sheet <- get_balance_accounts(
#'   ledger_file = "path/to/ledger.csv",
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   language = "fr"
#' )
#' }
#'
#' @seealso
#' \code{\link{get_category_total}} for detailed category calculations
#' \code{\link{get_income_statement}} for generating income statements
#' \code{\link{get_private_account}} for private account calculations
#' \code{\link{aggregate_accounts}} for category aggregation
#'
#' @export
#' @autoglobal
get_balance_accounts <- function(
    ledger_file,
    min_date,
    max_date,
    language = "fr") {
  assets <- get_category_total(
    ledger_file = ledger_file,
    min_date = min_date,
    max_date = max_date,
    language = language,
    account_category_name = "assets"
  )

  private_account <- get_private_account(
    ledger_file = ledger_file,
    min_date = min_date,
    max_date = max_date,
    language = language
  )

  liabilities <- get_category_total(
    ledger_file = ledger_file,
    min_date = min_date,
    max_date = max_date,
    language = language,
    account_category_name = "liabilities"
  ) |>
    bind_rows(private_account)

  assets |>
    bind_rows(liabilities) |>
    reframe(
      sum_amounts = sum(sum_amounts, na.rm = TRUE),
      .by = c("account_base_category", "high_category", "intermediate_category", "account_number", "account_description")
    ) |>
    filter(sum_amounts != 0)
}
