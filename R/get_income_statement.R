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
