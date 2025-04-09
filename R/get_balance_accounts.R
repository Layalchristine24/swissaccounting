#' Get Balance Sheet Accounts
#'
#' @description
#' Generates a balance sheet report from ledger data for a specified date range.
#' Implements both assets and liabilities calculations.
#'
#' @param ledger_file character Path to the CSV ledger file
#' @param min_date character,Date Optional. Minimum date to filter
#'   transactions (format: "YYYY-MM-DD")
#' @param max_date character,Date Optional. Maximum date to filter
#'   transactions (format: "YYYY-MM-DD")
#' @param path_csv character Optional. Path where to save the balance sheet CSV
#'   file
#' @param language character Language code for account descriptions. One of
#'   "en", "fr", "de". Defaults to "fr"
#'
#' @return data.frame A data frame containing balance sheet data with columns:
#'   \item{account_base_category}{Integer. First digit of account number}
#'   \item{high_category}{Integer. First two digits of account number}
#'   \item{account_description}{Character. Account description in selected
#'     language}
#'   \item{sum_amounts}{Numeric. Total values for each account}
#'
#' @examples
#' \dontrun{
#' # Generate balance sheet for specific date range in French
#' get_balance_accounts(
#'   ledger_file = "path/to/ledger.csv",
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   path_csv = "path/to/output.csv",
#'   language = "fr"
#' )
#' }
#'
#' @export
#' @autoglobal
get_balance_accounts <- function(
    ledger_file,
    min_date,
    max_date,
    path_csv,
    language = "fr") {
  assets <- get_category_total(
    ledger_file = ledger_file,
    min_date = min_date,
    max_date = max_date,
    language = language,
    account_category_name = "assets"
  )

  liabilities <- get_category_total(
    ledger_file = ledger_file,
    min_date = min_date,
    max_date = max_date,
    language = language,
    account_category_name = "liabilities"
  )

  bind_rows(assets, liabilities) |>
    filter(sum_amounts != 0)
}
