#' Write Balance Sheet Report
#'
#' @description
#' Generates a balance sheet report from ledger data for a specified date range.
#' Currently implements assets calculation, with liabilities and equity planned for
#' future implementation.
#'
#' @param ledger_file_balance character Path to the CSV ledger file
#' @param min_date_balance character,Date Optional. Minimum date to filter
#'   transactions (format: "YYYY-MM-DD")
#' @param max_date_balance character,Date Optional. Maximum date to filter
#'   transactions (format: "YYYY-MM-DD")
#' @param path_csv character Optional. Path where to save the balance sheet CSV
#'   file
#' @param my_language character Language code for account descriptions. One of
#'   "en", "fr", "de". Defaults to "fr"
#'
#' @return data.frame A data frame containing balance sheet data with columns:
#'   \item{account_base_category}{Integer. First digit of account number}
#'   \item{high_category}{Integer. First two digits of account number}
#'   \item{account_description}{Character. Account description in selected
#'     language}
#'   \item{sum_assets}{Numeric. Total values for each account}
#'
#' @examples
#' \dontrun{
#' # Generate balance sheet for specific date range in French
#' write_balance_sheet(
#'   ledger_file_balance = "path/to/ledger.csv",
#'   min_date_balance = "2024-01-01",
#'   max_date_balance = "2024-12-31",
#'   path_csv = "path/to/output.csv",
#'   my_language = "fr"
#' )
#' }
#'
#' @note Currently only implements assets calculation. Liabilities and equity
#'   calculations are planned for future implementation.
#'
#' @autoglobal
write_balance_sheet <- function(
    ledger_file_balance = NULL,
    min_date_balance = NULL,
    max_date_balance = NULL,
    path_csv = NULL,
    my_language = "fr") {
  assets <- get_assets(
    ledger_file = ledger_file_balance,
    min_date = min_date_balance,
    max_date = max_date_balance,
    language = my_language
  )

  liabilities <- get_liabilities(
    ledger_file = ledger_file_balance,
    min_date = min_date_balance,
    max_date = max_date_balance,
    language = my_language
  )

  bind_rows(assets, liabilities) |>
    filter(sum_amounts != 0)
}
