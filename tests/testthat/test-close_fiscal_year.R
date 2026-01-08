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
