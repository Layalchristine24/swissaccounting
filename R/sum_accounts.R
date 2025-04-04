#' Sum Account Balances by Category
#'
#' @description
#' Calculates the sum of account balances grouped by high-level categories and
#' account descriptions, handling different account types in multiple languages
#' (English, French, German).
#'
#' @param my_ledger data.frame A data frame containing accounting ledger data with
#'   columns:
#'   \item{account_type}{Character. Type of account (Asset, Liability, etc.)}
#'   \item{debit_account}{Integer. Account number for debit entries}
#'   \item{credit_account}{Integer. Account number for credit entries}
#'   \item{amount}{Numeric. Transaction amount}
#'   \item{account_description}{Character. Description of the account}
#'
#' @return data.frame A grouped data frame with columns:
#'   \item{account_base_category}{Integer. First digit of account number (1-9)}
#'   \item{high_category}{Integer. First two digits of account number}
#'   \item{intermediate_category}{Integer. First three digits of account number}
#'   \item{account_number}{Integer. Full account number (from debit or credit)}
#'   \item{account_description}{Character. Description of the account}
#'   \item{sum_amounts}{Numeric. Sum of amounts for each category combination,
#'     with sign adjusted based on account type}
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
#'
#' @autoglobal
sum_accounts <- function(my_ledger) {
  my_ledger |>
    filter(!(account_type %in%
      c("Income/Expense", "Closing", "Produit/Charge", "Cl\u00f4ture", "Einnahmen/Ausgabe", "Abschluss"))) |>
    mutate(
      amount = case_when(
        account_type %in% c("Asset", "Expense", "Actif", "Charge", "Aktivkonto", "Ausgabe") &
          !is.na(debit_account) ~ amount,
        account_type %in% c("Liability", "Income", "Passif", "Produit", "Passivkonto", "Einnahmen") &
          !is.na(credit_account) ~ amount,
        .default = -amount
      )
    ) |>
    get_high_category() |>
    get_intermediate_category() |>
    get_account_base_category() |>
    mutate(account_number = coalesce(debit_account, credit_account)) |>
    reframe(
      sum_amounts = round(sum(amount, na.rm = TRUE), 2),
      .by = c(account_base_category, high_category, intermediate_category, account_number, account_description)
    )
}
