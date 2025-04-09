#' Generate Income Statement
#'
#' @description
#' Creates an income statement by combining income and expense data from a ledger
#' file for a specified period, filtering out zero-amount entries.
#'
#' @param ledger_file_balance character Path to the CSV ledger file containing
#'   financial transactions
#' @param min_date_balance character,Date Optional. Start date for the income
#'   statement period (format: "YYYY-MM-DD")
#' @param max_date_balance character,Date Optional. End date for the income
#'   statement period (format: "YYYY-MM-DD")
#' @param path_csv character Optional. Alternative path for CSV output
#' @param my_language character Language code for account descriptions. One of
#'   "en", "fr", "de". Defaults to "fr"
#'
#' @return data.frame A data frame containing income and expense entries with
#'   non-zero amounts, including account categories and descriptions in the
#'   specified language
#'
#' @examples
#' \dontrun{
#' # Generate income statement for 2024 Q1 in French
#' income_statement <- get_income_statement(
#'   ledger_file_balance = "path/to/ledger.csv",
#'   min_date_balance = "2024-01-01",
#'   max_date_balance = "2024-03-31",
#'   my_language = "fr"
#' )
#' }
#'
#' @seealso
#' \code{\link{get_category_total}} for detailed category calculations
#' @export
#' @autoglobal
get_income_statement <- function(
    ledger_file_balance = NULL,
    min_date_balance = NULL,
    max_date_balance = NULL,
    path_csv = NULL,
    my_language = "fr") {
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
