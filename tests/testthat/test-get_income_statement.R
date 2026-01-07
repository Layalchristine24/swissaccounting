test_that("get_income_statement returns correct structure", {
  # Setup: create temp ledger with income and expense transactions
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # Add income transaction (account 3xxx)
  add_transaction(
    temp_ledger,
    "2024-01-15",
    "Service revenue",
    1020,
    3000,
    1000
  )

  # Add expense transactions (accounts 4xxx, 5xxx, 6xxx)
  add_transaction(temp_ledger, "2024-01-20", "Cost of goods", 4000, 1020, 300)
  add_transaction(temp_ledger, "2024-01-25", "Salary expense", 5000, 1020, 400)
  add_transaction(temp_ledger, "2024-01-31", "Office supplies", 6000, 1020, 100)

  # Generate income statement

  result <- get_income_statement(
    ledger_file = temp_ledger,
    min_date = "2024-01-01",
    max_date = "2024-12-31",
    language = "en"
  )

  # Verify it returns a data frame
  expect_s3_class(result, "data.frame")

  # Verify columns and types using ensure_type (will error if types don't match)
  expect_no_error(
    ensure_type(
      result,
      account_base_category = integer(),
      high_category = integer(),
      intermediate_category = integer(),
      account_number = integer(),
      account_description = character(),
      sum_amounts = double()
    )
  )

  # Verify only income (3) and expense (4, 5, 6) categories are included
  expect_true(all(result$account_base_category %in% c(3L, 4L, 5L, 6L)))

  # Verify no zero amounts are included
  expect_true(all(result$sum_amounts != 0))
})

test_that("get_income_statement filters out zero-amount entries", {
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # Add an income entry and reverse it (net zero)
  add_transaction(temp_ledger, "2024-01-15", "Revenue", 1020, 3000, 500)
  add_transaction(
    temp_ledger,
    "2024-01-16",
    "Revenue reversal",
    3000,
    1020,
    500
  )

  # Add a non-zero expense
  add_transaction(temp_ledger, "2024-01-20", "Office expense", 6000, 1020, 100)

  result <- get_income_statement(
    ledger_file = temp_ledger,
    min_date = "2024-01-01",
    max_date = "2024-12-31",
    language = "en"
  )

  # Account 3000 should not appear (zero balance)
  expect_false(3000L %in% result$account_number)

  # Account 6000 should appear (non-zero balance)
  expect_true(6000L %in% result$account_number)
})

test_that("get_income_statement respects date filtering", {
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # Add transactions in different months
  add_transaction(
    temp_ledger,
    "2024-01-15",
    "January revenue",
    1020,
    3000,
    1000
  )
  add_transaction(temp_ledger, "2024-03-15", "March expense", 6000, 1020, 200)

  # Filter for January only
  result_jan <- get_income_statement(
    ledger_file = temp_ledger,
    min_date = "2024-01-01",
    max_date = "2024-01-31",
    language = "en"
  )

  # Should include January income but not March expense
  expect_true(3000L %in% result_jan$account_number)
  expect_false(6000L %in% result_jan$account_number)

  # Filter for March only
  result_mar <- get_income_statement(
    ledger_file = temp_ledger,
    min_date = "2024-03-01",
    max_date = "2024-03-31",
    language = "en"
  )

  # Should include March expense but not January income
  expect_false(3000L %in% result_mar$account_number)
  expect_true(6000L %in% result_mar$account_number)
})
