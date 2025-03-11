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
    reframe(
      sum_assets = sum(amount, na.rm = TRUE),
      .by = c(high_category, account_description)
    )
}
