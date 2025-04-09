#' Get Balance Sheet Accounts
#'
#' @description
#' Generates a balance sheet report from ledger data for a specified date range.
#' Implements both assets and liabilities calculations, with support for multiple
#' languages and optional CSV export. The function filters out zero-amount entries
#' to provide a clean balance sheet view.
#'
#' @param ledger_file character Path to the CSV ledger file containing
#'   financial transactions
#' @param min_date character,Date Optional. Minimum date to filter
#'   transactions (format: "YYYY-MM-DD")
#' @param max_date character,Date Optional. Maximum date to filter
#'   transactions (format: "YYYY-MM-DD")
#' @param path_csv character Optional. Path where to save the balance sheet CSV
#'   file. If provided, the function will write the results to this file.
#' @param language character Language code for account descriptions. One of
#'   "en", "fr", "de". Defaults to "fr"
#'
#' @return data.frame A data frame containing balance sheet data with columns:
#'   \itemize{
#'     \item{account_base_category}{Integer. First digit of account number (1 or 2)}
#'     \item{high_category}{Integer. First two digits of account number}
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
#'
#' # Generate and save to CSV
#' get_balance_accounts(
#'   ledger_file = "path/to/ledger.csv",
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   path_csv = "path/to/balance_sheet.csv",
#'   language = "fr"
#' )
#' }
#'
#' @seealso
#' \code{\link{get_category_total}} for detailed category calculations
#' \code{\link{get_income_statement}} for generating income statements
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
