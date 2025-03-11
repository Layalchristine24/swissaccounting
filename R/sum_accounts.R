#' Sum Account Balances by Category
#' 
#' @description
#' Calculates the sum of account balances grouped by high-level categories and 
#' account descriptions, handling different account types in multiple languages 
#' (English, French, German).
#' 
#' @param my_ledger A data frame containing accounting ledger data with columns for
#'   account types, debit/credit accounts, amounts, and account descriptions
#' 
#' @return A grouped data frame with columns:
#'   \item{high_category}{The high-level account category}
#'   \item{account_description}{The account description}
#'   \item{sum_assets}{The sum of amounts for each category/description 
#'     combination}
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
    reframe(
      sum_assets = sum(amount, na.rm = TRUE),
      .by = c(account_base_category, high_category, intermediate_category, account_description)
    )
}
