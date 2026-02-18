test_that("close_fiscal_year works without debit_account error", {
  # Setup: create temp ledger with transactions
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # Add some transactions
  add_transaction(temp_ledger, "2024-01-01", "Revenue", 1020, 3000, 1000)
  add_transaction(temp_ledger, "2024-06-01", "Expense", 6000, 1020, 500)

  # This should NOT throw 'debit_account' not found error
  expect_no_error(
    close_fiscal_year(
      ledger_file = temp_ledger,
      closing_date = "2024-12-31",
      language = "en"
    )
  )

  # Verify closing entries were created
  ledger <- read_ledger_csv(temp_ledger)
  closing_entries <- ledger[ledger$account_type == "Closing", ]
  expect_true(nrow(closing_entries) > 0)
})

test_that("get_account_balances_at_date returns correct structure", {
  # Setup: create temp ledger with transactions
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # Add a transaction
  add_transaction(temp_ledger, "2024-01-01", "Test expense", 6000, 1020, 100)

  # Call the internal function
  balances <- get_account_balances_at_date(
    ledger_file = temp_ledger,
    closing_date = "2024-12-31",
    account_range = c(6L),
    language = "en"
  )

  # Verify it has the expected columns
  expect_true("account_number" %in% colnames(balances))
  expect_true("sum_amounts" %in% colnames(balances))
  expect_true("account_description" %in% colnames(balances))

  # Verify the balance is correct
  expect_equal(nrow(balances), 1)
  expect_equal(balances$account_number[1], 6000L)
  expect_equal(balances$sum_amounts[1], 100)
})

test_that("close_fiscal_year produces correct P&L closing amounts on multi-year ledger", {
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # === Year 1 (2024) ===
  add_transaction(temp_ledger, "2024-01-01", "Capital contribution", 1020, 2820, 10000)
  add_transaction(temp_ledger, "2024-06-01", "Service revenue", 1020, 3000, 1000)
  add_transaction(temp_ledger, "2024-09-01", "Office supplies", 6000, 1020, 500)

  close_fiscal_year(temp_ledger, "2024-12-31", language = "en")
  create_opening_balances(temp_ledger, "2025-01-01", language = "en")

  # === Year 2 (2025) ===
  add_transaction(temp_ledger, "2025-06-01", "Service revenue", 1020, 3000, 2000)
  add_transaction(temp_ledger, "2025-09-01", "Office supplies", 6000, 1020, 800)

  close_fiscal_year(temp_ledger, "2025-12-31", language = "en")

  # Verify: closing amounts should reflect ONLY year 2 P&L
  ledger <- read_ledger_csv(temp_ledger)
  closing_2025 <- ledger |>
    dplyr::filter(date == lubridate::ymd("2025-12-31"), account_type == "Closing")

  # Income closing: DR 3000 = 2000 (NOT 3000 which would include year 1)
  income_closing <- closing_2025 |>
    dplyr::filter(!is.na(debit_account), debit_account == 3000L)
  expect_equal(nrow(income_closing), 1)
  expect_equal(income_closing$amount, 2000)

  # Expense closing: CR 6000 = 800 (NOT 1300 which would include year 1)
  expense_closing <- closing_2025 |>
    dplyr::filter(!is.na(credit_account), credit_account == 6000L)
  expect_equal(nrow(expense_closing), 1)
  expect_equal(expense_closing$amount, 800)

  # Net P&L transfer to 2970: should be 1200 (profit = 2000 - 800)
  transfer_to_2970 <- ledger |>
    dplyr::filter(
      date == lubridate::ymd("2025-12-31"),
      !is.na(credit_account),
      credit_account == 2970L
    )
  expect_equal(nrow(transfer_to_2970), 1)
  expect_equal(transfer_to_2970$amount, 1200)
})

test_that("create_opening_balances produces correct balance sheet carry-forwards on multi-year ledger", {
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # === Year 1 (2024) ===
  add_transaction(temp_ledger, "2024-01-01", "Capital contribution", 1020, 2820, 10000)
  add_transaction(temp_ledger, "2024-06-01", "Service revenue", 1020, 3000, 1000)
  add_transaction(temp_ledger, "2024-09-01", "Office supplies", 6000, 1020, 500)

  close_fiscal_year(temp_ledger, "2024-12-31", language = "en")
  create_opening_balances(temp_ledger, "2025-01-01", language = "en")

  # === Year 2 (2025) ===
  add_transaction(temp_ledger, "2025-06-01", "Service revenue", 1020, 3000, 2000)
  add_transaction(temp_ledger, "2025-09-01", "Office supplies", 6000, 1020, 800)

  close_fiscal_year(temp_ledger, "2025-12-31", language = "en")
  create_opening_balances(temp_ledger, "2026-01-01", language = "en")

  # Verify: opening balances should reflect correct carry-forwards
  ledger <- read_ledger_csv(temp_ledger)
  opening_2026 <- ledger |>
    dplyr::filter(date == lubridate::ymd("2026-01-01"))

  # Bank (1020): 10000 + 1000 - 500 + 2000 - 800 = 11700
  bank_opening <- opening_2026 |>
    dplyr::filter(!is.na(debit_account), debit_account == 1020L)
  expect_equal(nrow(bank_opening), 1)
  expect_equal(bank_opening$amount, 11700)

  # Capital (2820): -10000 -> opening: DR 9100 10000, CR 2820 10000
  capital_opening <- opening_2026 |>
    dplyr::filter(!is.na(credit_account), credit_account == 2820L)
  expect_equal(nrow(capital_opening), 1)
  expect_equal(capital_opening$amount, 10000)

  # Carried Forward P&L (2970): -500 - 1200 = -1700 -> opening: DR 9100 1700, CR 2970 1700
  retained_opening <- opening_2026 |>
    dplyr::filter(!is.na(credit_account), credit_account == 2970L)
  expect_equal(nrow(retained_opening), 1)
  expect_equal(retained_opening$amount, 1700)
})
