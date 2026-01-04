#' Calculate Account Balances by Category
#'
#' @description
#' Calculates the sum of account balances grouped by high-level categories and
#' account descriptions, handling different account types in multiple languages
#' (English, French, German). The function automatically adjusts the sign of
#' amounts based on the account type (debit/credit) and filters out closing
#' and income/expense accounts.
#'
#' @param my_ledger data.frame A data frame containing accounting ledger data with
#'   the following columns:
#'   \itemize{
#'     \item{account_type}{Character. Type of account (Asset, Liability, etc.)}
#'     \item{debit_account}{Integer. Account number for debit entries}
#'     \item{credit_account}{Integer. Account number for credit entries}
#'     \item{amount}{Numeric. Transaction amount}
#'     \item{account_description}{Character. Description of the account}
#'   }
#'
#' @return data.frame A grouped data frame with the following columns:
#'   \itemize{
#'     \item{account_base_category}{Integer. First digit of account number (1-9)}
#'     \item{high_category}{Integer. First two digits of account number}
#'     \item{intermediate_category}{Integer. First three digits of account number}
#'     \item{account_number}{Integer. Full account number (from debit or credit)}
#'     \item{account_description}{Character. Description of the account}
#'     \item{sum_amounts}{Numeric. Sum of amounts for each category combination,
#'       with sign adjusted based on account type}
#'   }
#'
#' @examples
#' # Create sample ledger data
#' ledger_data <- data.frame(
#'   account_type = c("Asset", "Liability", "Asset"),
#'   debit_account = c(1001, NA, 1002),
#'   credit_account = c(NA, 2001, NA),
#'   amount = c(1000, 500, 750),
#'   account_description = c("Cash", "Loan", "Equipment")
#' )
#'
#' # Calculate sum of accounts
#' result <- sum_accounts(ledger_data)
#' # Returns:
#' # account_base_category: 1, 2
#' # high_category: 10, 20
#' # intermediate_category: 100, 200
#' # account_number: 1001, 1002, 2001
#' # sum_amounts: 1750, -500
#'
#' @seealso
#' \code{\link{get_account_base_category}} for extracting base categories
#' \code{\link{get_high_category}} for extracting high-level categories
#' \code{\link{get_intermediate_category}} for extracting intermediate categories
#'
#' @autoglobal
sum_accounts <- function(my_ledger) {
  my_ledger |>
    filter(
      !(account_type %in%
        c(
          "Closing",
          "Cl\u00f4ture",
          "Abschluss"
        ))
    ) |>
    aggregate_accounts()
}

#' Aggregate Account Categories
#'
#' @description
#' Internal helper function that extracts and aggregates account categories
#' (base, high, and intermediate) from ledger entries. This function is used
#' internally by other functions to standardize the category extraction process.
#'
#' @param my_ledger_filtered data.frame A filtered ledger data frame with
#'   debit_account and/or credit_account columns
#'
#' @return data.frame A data frame with additional category columns:
#'   \itemize{
#'     \item{account_base_category}{Integer. First digit of account number}
#'     \item{high_category}{Integer. First two digits of account number}
#'     \item{intermediate_category}{Integer. First three digits of account number}
#'     \item{account_number}{Integer. Full account number}
#'     \item{sum_amounts}{Numeric. Sum of amounts for each category}
#'   }
#'
#' @examples
#' \dontrun{
#' # Used internally by sum_accounts()
#' aggregated <- aggregate_accounts(filtered_ledger)
#' }
#'
#' @keywords internal
#' @autoglobal
aggregate_accounts <- function(my_ledger_filtered) {
  my_ledger_filtered |>
    mutate(
      amount = case_when(
        # Assets and Expenses: debits are positive, credits are negative
        account_type %in%
          c("Asset", "Expense", "Actif", "Charge", "Aktivkonto", "Ausgabe") &
          !is.na(debit_account) ~
          amount,
        account_type %in%
          c("Asset", "Expense", "Actif", "Charge", "Aktivkonto", "Ausgabe") &
          !is.na(credit_account) ~
          -amount,
        # Liabilities and Income: credits are negative (normal balance), debits are positive (reduce balance)
        # Note: "Income/Expense" accounts are treated as Income (credits negative, debits positive)
        account_type %in%
          c(
            "Liability",
            "Income",
            "Income/Expense",
            "Passif",
            "Produit",
            "Produit/Charge",
            "Passivkonto",
            "Einnahmen",
            "Einnahmen/Ausgabe"
          ) &
          !is.na(credit_account) ~
          -amount,
        account_type %in%
          c(
            "Liability",
            "Income",
            "Income/Expense",
            "Passif",
            "Produit",
            "Produit/Charge",
            "Passivkonto",
            "Einnahmen",
            "Einnahmen/Ausgabe"
          ) &
          !is.na(debit_account) ~
          amount,
        .default = amount
      )
    ) |>
    get_high_category() |>
    get_intermediate_category() |>
    get_account_base_category() |>
    mutate(account_number = coalesce(debit_account, credit_account)) |>
    reframe(
      sum_amounts = round(sum(amount, na.rm = TRUE), 2),
      .by = c(
        account_base_category,
        high_category,
        intermediate_category,
        account_number,
        account_description
      )
    )
}
