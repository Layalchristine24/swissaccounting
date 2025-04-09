#' Calculate Total Assets by Account Description
#'
#' @description
#' Reads a ledger file, filters by date range if specified, and calculates the sum
#' of assets for each account description in the selected language. This is a
#' convenience wrapper around get_balance_side() for assets.
#'
#' @param ledger_file character Path to the CSV ledger file
#' @param min_date character,Date Optional. Minimum date to filter transactions
#'   (format: "YYYY-MM-DD")
#' @param max_date character,Date Optional. Maximum date to filter transactions
#'   (format: "YYYY-MM-DD")
#' @param language character Language code for account descriptions. One of "en",
#'   "fr", "de". Defaults to "fr"
#'
#' @return data.frame A data frame containing:
#'   \item{account_base_category}{Integer. First digit of account number (1-9)}
#'   \item{high_category}{Integer. First two digits of account number}
#'   \item{intermediate_category}{Integer. First three digits of account number}
#'   \item{account_number}{Integer. Full account number}
#'   \item{account_description}{Character. Account description in selected
#'     language}
#'   \item{sum_amounts}{Numeric. Total asset values}
#'   \item{account_description_intermediate}{Character. Intermediate level
#'     description}
#'
#' @examples
#' \dontrun{
#' # Using French account descriptions (default)
#' get_assets(ledger_file = my_ledger_directory)
#'
#' # Using German account descriptions with date range
#' get_assets(
#'   ledger_file = my_ledger_directory,
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   language = "de"
#' )
#' }
#'
#' @seealso
#' \code{\link{get_balance_side}} for the underlying implementation
#'
#' @autoglobal
#' @export
get_assets <- function(
    ledger_file = NULL,
    min_date = NULL,
    max_date = NULL,
    language = "fr") {
  if (is.null(ledger_file)) {
    cli_abort(".var{ledger_file} is required. Please provide a path to the ledger CSV file.")
  } else {
    get_balance_side(
      ledger_file = ledger_file,
      min_date = min_date,
      max_date = max_date,
      language = language,
      account_category_name = "assets"
    )
  }
}
