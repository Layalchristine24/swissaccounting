#' Get Account Base Category
#'
#' @description
#' Extracts the base category (first digit) from account numbers in a ledger by
#' removing the last three digits. For example:
#' - Account 1234 -> Category 1 (Assets)
#' - Account 2000 -> Category 2 (Liabilities)
#' - Account 3400 -> Category 3 (Revenue)
#'
#' @param my_ledger data.frame A data frame containing ledger entries with at least
#'   one of these columns: debit_account or credit_account
#'
#' @return data.frame A data frame with an additional integer column 
#'   'account_base_category' containing the base category (1-9) of each account. 
#'   Uses the first non-NULL account between debit and credit accounts.
#'
#' @examples
#' ledger <- data.frame(
#'   debit_account = c(1000, NA, 3400),
#'   credit_account = c(NA, 2000, 5000),
#'   amount = c(100, 200, 300)
#' )
#'
#' result <- get_account_base_category(ledger)
#' # Returns:
#' # account_base_category: 1, 2, 3
#'
#' @autoglobal
get_account_base_category <- function(my_ledger) {
  my_ledger |>
    mutate(
      account_base_category = as.integer((coalesce(debit_account, credit_account) -
        coalesce(debit_account, credit_account) %% 1e3) / 1e3)    
    )
}

#' Extract High-Level Account Categories
#'
#' @description
#' Extracts the high-level category (first digit) from account numbers in a ledger.
#' For example, account 1234 would be categorized as 12.
#'
#' @param my_ledger data.frame A data frame containing ledger entries with 
#'   debit_account and/or credit_account columns
#'
#' @return data.frame A data frame with an additional integer column 
#'   'high_category' containing the high-level category numbers
#'
#' @examples
#' ledger <- data.frame(
#'   debit_account = c(1000, 2000, 3000),
#'   credit_account = c(4000, 5000, NA),
#'   amount = c(100, 200, 300)
#' )
#'
#' categorized_ledger <- get_high_category(ledger)
#' print(categorized_ledger)
#'
#' @autoglobal
get_high_category <- function(my_ledger) {
  my_ledger |>
    mutate(
      high_category = as.integer((coalesce(debit_account, credit_account) -
        coalesce(debit_account, credit_account) %% 1e3) / 1e2)
    )
}

#' Extract Intermediate Account Categories
#'
#' @description
#' Extracts the intermediate category (first two digits) from account numbers in a ledger.
#' For example, account 1234 would be categorized as 12.
#'
#' @param my_ledger data.frame A data frame containing ledger entries with 
#'   debit_account and/or credit_account columns
#'
#' @return data.frame A data frame with an additional integer column 
#'   'intermediate_category' containing the intermediate category numbers
#'
#' @examples
#' ledger <- data.frame(
#'   debit_account = c(1234, 2345, 3456),
#'   credit_account = c(4567, 5678, NA),
#'   amount = c(100, 200, 300)
#' )
#'
#' categorized_ledger <- get_intermediate_category(ledger)
#' print(categorized_ledger)
#'
#' @autoglobal
get_intermediate_category <- function(my_ledger) {
  my_ledger |>
    mutate(
      intermediate_category = as.integer((coalesce(debit_account, credit_account) -
        coalesce(debit_account, credit_account) %% 1e2) / 1e1)    
    )
}
