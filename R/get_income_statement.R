#' Generate Income Statement
#'
#' @description
#' Creates an income statement by combining income and expense data from a ledger
#' file for a specified period, filtering out zero-amount entries. The function
#' supports multiple languages and optional CSV export. It calculates both revenue
#' and expense categories to provide a comprehensive view of the company's financial
#' performance.
#'
#' @param ledger_file character Path to the CSV ledger file containing
#'   financial transactions
#' @param min_date character,Date Optional. Start date for the income
#'   statement period (format: "YYYY-MM-DD")
#' @param max_date character,Date Optional. End date for the income
#'   statement period (format: "YYYY-MM-DD")
#' @param path_csv character Optional. Path where to save the income statement CSV
#'   file. If provided, the function will write the results to this file.
#' @param language character Language code for account descriptions. One of
#'   "en", "fr", "de". Defaults to "fr"
#'
#' @return data.frame A data frame containing income and expense entries with
#'   non-zero amounts, including:
#'   \itemize{
#'     \item{account_base_category}{Integer. First digit of account number (3-6)}
#'     \item{high_category}{Integer. First two digits of account number}
#'     \item{intermediate_category}{Integer. First three digits of account number}
#'     \item{account_number}{Integer. Full account number}
#'     \item{account_description}{Character. Account description in selected language}
#'     \item{sum_amounts}{Numeric. Total values for each account}
#'   }
#'
#' @examples
#' \dontrun{
#' # Generate income statement for 2024 in French
#' income_statement <- get_income_statement(
#'   ledger_file = "path/to/ledger.csv",
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   language = "fr"
#' )
#'
#' # Generate and save to CSV
#' get_income_statement(
#'   ledger_file = "path/to/ledger.csv",
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   path_csv = "path/to/income_statement.csv",
#'   language = "fr"
#' )
#' }
#'
#' @seealso
#' \code{\link{get_category_total}} for detailed category calculations
#' \code{\link{get_balance_accounts}} for generating balance sheets
#'
#' @export
#' @autoglobal
get_income_statement <- function(
    ledger_file,
    min_date,
    max_date,
    path_csv,
    language = "fr") {
  income <- get_category_total(
    ledger_file = ledger_file,
    min_date = min_date,
    max_date = max_date,
    language = language,
    account_category_name = "income"
  )

  expenses <- get_category_total(
    ledger_file = ledger_file,
    min_date = min_date,
    max_date = max_date,
    language = language,
    account_category_name = "expense"
  )
  bind_rows(income, expenses) |>
    filter(sum_amounts != 0)
}
