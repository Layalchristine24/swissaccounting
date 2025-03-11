sum_accounts <- function(my_ledger) {
  my_ledger |>
    get_high_category() |>
    get_intermediate_category() |> 
    reframe(
      amount = case_when(
        high_category == 1e1 &
          !is.na(debit_account) ~ amount,
        .default = -amount
      ),
      .by = c(date, id, account_description, debit_account, credit_account)
    ) |>
    reframe(
      sum_assets = sum(amount, na.rm = TRUE),
      .by = account_description
    )
}
ledger_file <- "/Users/Layal/github/ersatz-production/ersatz-accounting/ersatz.accounting/documents/ledger/ersatz-ledger.csv"
