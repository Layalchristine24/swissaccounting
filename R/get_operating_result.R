#' Calculate Operating Result
#'
#' @description
#' Calculates the operating result (profit/loss) from the income statement for a specified period.
#' The function processes income and expense accounts, adjusting the sign of amounts
#' to provide a net operating result. Income accounts (category 3) are kept positive,
#' while expense accounts are converted to negative values.
#'
#' @param ledger_file character Path to the CSV ledger file
#' @param min_date character,Date Start date (YYYY-MM-DD)
#' @param max_date character,Date End date (YYYY-MM-DD)
#' @param language character Language for descriptions ("en", "fr", "de").
#'   Defaults to "fr"
#'
#' @return data.frame A data frame with a single column:
#'   \itemize{
#'     \item{amount}{Numeric. The net operating result (positive for profit, negative for loss)}
#'   }
#'
#' @examples
#' \dontrun{
#' # Calculate operating result for 2024
#' result <- get_operating_result(
#'   ledger_file = "path/to/ledger.csv",
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   language = "fr"
#' )
#' }
#'
#' @seealso
#' \code{\link{get_income_statement}} for generating income statements
#' \code{\link{get_balance_accounts}} for generating balance sheets
#'
#' @export
#' @autoglobal
get_operating_result <- function(
    ledger_file,
    min_date,
    max_date,
    language = "fr") {
  get_income_statement(
    ledger_file = ledger_file,
    min_date = min_date,
    max_date = max_date,
    language = language,
  ) |>
    mutate(
      sum_amounts = if_else(account_base_category == 3L,
        sum_amounts,
        -sum_amounts
      )
    ) |>
    reframe(
      amount = sum(sum_amounts)
    )
}
