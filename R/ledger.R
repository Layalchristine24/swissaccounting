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
    read_csv(ledger_file,
      col_types = cols(
        date = col_date(),
        description = col_character(),
        account_description = col_character(),
        account_type = col_character(),
        .default = col_integer(),
        amount = col_double()
      )
    )
  }
}
# add_ledger_entry(date = today(), descr = "Gross salaries month of December", debit_account = 5000, amount = 26900, export_csv = TRUE, filename_to_export = "~/2024-02-04_ledger.csv")
# add_ledger_entry(date = today(), counterpart_id = 1L, descr = "Net salaries month of December", credit_account = 1020, amount = 24330, import_csv = TRUE, filename_to_import = "~/2024-02-04_ledger.csv", export_csv = TRUE, filename_to_export = "~/2024-02-04_ledger.csv")
# add_ledger_entry(date = today(), counterpart_id = 1L, descr = "Social contributions month of December", credit_account = 5700, amount = 1680, import_csv = TRUE, filename_to_import = "~/2024-02-04_ledger.csv", export_csv = TRUE, filename_to_export = "~/2024-02-04_ledger.csv")
# add_ledger_entry(date = today(), counterpart_id = 1L, descr = "Contributions accident insurance paid by the employee", credit_account = 5730, amount = 890, import_csv = TRUE, filename_to_import = "~/2024-02-04_ledger.csv", export_csv = TRUE, filename_to_export = "~/2024-02-04_ledger.csv")

# https://www.banana.ch/doc/fr/node/2726
#' @export
add_ledger_entry <- function(date,
                             language = "en",
                             counterpart_id = NULL,
                             debit_account = NULL,
                             credit_account = NULL,
                             descr = NULL,
                             amount,
                             import_csv = FALSE,
                             filename_to_import = NULL,
                             export_csv = FALSE,
                             filename_to_export = NULL) {
  if (is.character(date)) {
    date <- lubridate::as_date(date)
  }

  if (!is.null(debit_account)) {
    debit_account <- as.integer(debit_account)
  }

  if (!is.null(credit_account)) {
    credit_account <- as.integer(credit_account)
  }

  last_ledger <- get_last_ledger_version(
    import_csv = import_csv,
    ledger_file = filename_to_import
  )

  account_model <- if (language == "fr") {
    accounts_model_fr
  } else if (language == "en") {
    accounts_model_en
  } else if (language == "de") {
    accounts_model_de
  }

  .counterpart_id <- if (is.null(counterpart_id)) {
    NA_integer_
  } else {
    counterpart_id
  }

  rm(counterpart_id)

  ledger_raw <-
    tibble(
      date = date,
      id = if_else(is.na(max(last_ledger$id)), 1L, max(last_ledger$id) + 1L),
      counterpart_id = .counterpart_id,
      description = descr,
      debit_account = debit_account,
      credit_account = credit_account,
      amount = amount
    ) |>
    drop_na(amount) |>
    mutate(counterpart_id = if_else(is.na(.counterpart_id), id, counterpart_id))

  new_ledger <- if (is.null(filename_to_import)) {
    if (!is.null(debit_account)) {
      ledger_raw |>
        left_join(
          account_model,
          by = c(debit_account = "account_number")
        )
    } else if (!is.null(credit_account)) {
      ledger_raw |>
        left_join(
          account_model,
          by = c(credit_account = "account_number")
        )
    }
  } else {
    if (!is.null(debit_account)) {
      ledger_raw |>
        left_join(
          account_model |>
            rename(debit_account = account_number),
          by = join_by(debit_account)
        )
    } else if (!is.null(credit_account)) {
      ledger_raw |>
        left_join(
          account_model |>
            rename(credit_account = account_number),
          by = join_by(credit_account)
        )
    }
  }

  ledger <-
    last_ledger |>
    bind_rows(
      new_ledger
    ) |>
    drop_na(id)

  if (export_csv) {
    ledger |>
      write_csv(filename_to_export)
  }
  ledger
}
