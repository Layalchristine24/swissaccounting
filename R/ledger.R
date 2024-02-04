get_ledger <- function(...) {
  args <- lst(...)
}

get_last_ledger_version <- function(ledger_file = NULL,
                                    import_csv = FALSE) {
  if (is.null(ledger_file)) {
    tribble(
      ~date, ~id, ~counterpart_id, ~description, ~debit_account, ~credit_account, ~amount,
      NA_Date_, NA_integer_, NA_integer_, NA_character_, NA_integer_, NA_integer_, NA_real_
    )
  } else if (import_csv) {
    readr::read_csv(ledger_file)
  }
}
# add_ledger_entry(date = today(), descr = "Gross salaries month of December", debit_account = 5000, amount = 26900, export_csv = TRUE, filename_to_export = "~/2024-02-04_ledger.csv")
# add_ledger_entry(date = today(), counterpart_id = 1L, descr = "Net salaries month of December", credit_account = 1020, amount = 24330, import_csv = TRUE, filename_to_import = "~/2024-02-04_ledger.csv", export_csv = TRUE, filename_to_export = "~/2024-02-04_ledger.csv")
# add_ledger_entry(date = today(), counterpart_id = 1L, descr = "Social contributions month of December", credit_account = 5700, amount = 1680, import_csv = TRUE, filename_to_import = "~/2024-02-04_ledger.csv", export_csv = TRUE, filename_to_export = "~/2024-02-04_ledger.csv")
# add_ledger_entry(date = today(), counterpart_id = 1L, descr = "Contributions accident insurance paid by the employee", credit_account = 5730, amount = 890, import_csv = TRUE, filename_to_import = "~/2024-02-04_ledger.csv", export_csv = TRUE, filename_to_export = "~/2024-02-04_ledger.csv")

# https://www.banana.ch/doc/fr/node/2726
add_ledger_entry <- function(date,
                             counterpart_id = NULL,
                             debit_account = NULL,
                             credit_account = NULL,
                             descr = NULL,
                             amount,
                             import_csv = FALSE,
                             filename_to_import = NULL,
                             export_csv = FALSE,
                             filename_to_export = NULL) {
  last_ledger <- get_last_ledger_version(
    import_csv = import_csv,
    ledger_file = filename_to_import
  )

  ledger <- last_ledger |>
    add_row(
      date = date,
      id = if_else(is.na(max(last_ledger$id)), 1L, max(last_ledger$id) + 1L),
      counterpart_id = counterpart_id,
      description = descr,
      debit_account = debit_account,
      credit_account = credit_account,
      amount = amount
    ) |>
    drop_na(amount) |>
    mutate(counterpart_id = if_else(is.na(counterpart_id), id, counterpart_id))

  if (export_csv) {
    ledger |>
      readr::write_csv(filename_to_export)
  }

  ledger
}
