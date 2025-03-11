#' Extract High-Level Account Categories
#'
#' @description
#' Extracts the high-level category (first digit) from account numbers in a ledger.
#' For example, account 1234 would be categorized as 12.
#'
#' @param my_ledger A data frame containing ledger entries with debit_account
#'   and/or credit_account columns
#'
#' @return A data frame with an additional column 'high_category' containing
#'   the high-level category numbers
#'
#' @examples
#' # Create a sample ledger
#' ledger <- data.frame(
#'   debit_account = c(1000, 2000, 3000),
#'   credit_account = c(4000, 5000, NA),
#'   amount = c(100, 200, 300)
#' )
#'
#' # Get high-level categories
#' categorized_ledger <- get_high_category(ledger)
#' print(categorized_ledger)
#'
#' @export
get_high_category <- function(my_ledger) {
  my_ledger |>
    mutate(
      high_category = (coalesce(debit_account, credit_account) -
        coalesce(debit_account, credit_account) %% 1e3) / 1e2
    )
}

#' Extract Intermediate Account Categories
#'
#' @description
#' Extracts the intermediate category (first two digits) from account numbers in a ledger.
#' For example, account 1234 would be categorized as 12.
#'
#' @param my_ledger A data frame containing ledger entries with debit_account
#'   and/or credit_account columns
#'
#' @return A data frame with an additional column 'intermediate_category' containing
#'   the intermediate category numbers
#'
#' @examples
#' # Create a sample ledger
#' ledger <- data.frame(
#'   debit_account = c(1234, 2345, 3456),
#'   credit_account = c(4567, 5678, NA),
#'   amount = c(100, 200, 300)
#' )
#'
#' # Get intermediate categories
#' categorized_ledger <- get_intermediate_category(ledger)
#' print(categorized_ledger)
#'
#' @export
get_intermediate_category <- function(my_ledger) {
  my_ledger |>
    mutate(
      intermediate_category = (coalesce(debit_account, credit_account) -
        coalesce(debit_account, credit_account) %% 1e2) / 1e1
    )
}
