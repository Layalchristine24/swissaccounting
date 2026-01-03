test_that("add_transaction creates two entries per call", {
  # Setup: create temp file
temp_ledger <- tempfile(fileext = ".csv")
on.exit(unlink(temp_ledger))

# Add first transaction
add_transaction(
  ledger_file = temp_ledger,
  date = "2024-01-01",
  descr = "Test transaction 1",
  debit_account = 6000,
  credit_account = 1020,
  amount = 100
)

# Read and verify: should have 2 entries
ledger <- read_ledger_csv(temp_ledger)
expect_equal(nrow(ledger), 2)
expect_equal(ledger$id, c(1L, 2L))
expect_equal(ledger$counterpart_id, c(1L, 1L))
})

test_that("add_transaction preserves previous entries when called multiple times", {
  # Setup: create temp file
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # Add first transaction
  add_transaction(
    ledger_file = temp_ledger,
    date = "2024-01-01",
    descr = "Test transaction 1",
    debit_account = 6000,
    credit_account = 1020,
    amount = 100
  )

  # Add second transaction
  add_transaction(
    ledger_file = temp_ledger,
    date = "2024-01-02",
    descr = "Test transaction 2",
    debit_account = 4000,
    credit_account = 1020,
    amount = 200
  )

  # Read and verify: should have 4 entries (2 per transaction)
  ledger <- read_ledger_csv(temp_ledger)
  expect_equal(nrow(ledger), 4)
  expect_equal(ledger$id, c(1L, 2L, 3L, 4L))

  # Verify first transaction still exists
  expect_equal(ledger$description[1], "Test transaction 1")
  expect_equal(ledger$amount[1], 100)

  # Verify second transaction exists
  expect_equal(ledger$description[3], "Test transaction 2")
  expect_equal(ledger$amount[3], 200)
})

test_that("add_transaction with three consecutive calls preserves all entries", {
  # Setup: create temp file
  temp_ledger <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_ledger))

  # Add three transactions
  add_transaction(temp_ledger, "2024-01-01", "Transaction 1", 6000, 1020, 100)
  add_transaction(temp_ledger, "2024-01-02", "Transaction 2", 4000, 1020, 200)
  add_transaction(temp_ledger, "2024-01-03", "Transaction 3", 5000, 1020, 300)

  # Read and verify: should have 6 entries
  ledger <- read_ledger_csv(temp_ledger)
  expect_equal(nrow(ledger), 6)
  expect_equal(ledger$id, 1:6)

  # Verify all amounts are present
  expect_true(100 %in% ledger$amount)
  expect_true(200 %in% ledger$amount)
  expect_true(300 %in% ledger$amount)
})
