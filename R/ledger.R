#' Get Last Ledger Version
#'
#' @description
#' Retrieves the most recent version of the ledger, either creating an empty one or
#' importing from a CSV file.
#'
#' @param ledger_file Path to the CSV ledger file
#' @param import_csv Logical indicating whether to import from CSV
#'
#' @return A tibble containing ledger data or an empty ledger structure if no file
#'   is provided
#' @autoglobal
#' @keywords internal
get_ledger <- function(ledger_file = NULL,
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

#' Add Ledger Entry
#'
#' @description
#' Adds a new entry to the accounting ledger with support for multiple languages 
#' and optional CSV import/export functionality.
#'
#' @param date Date of the ledger entry
#' @param language Language code for account descriptions ("en", "fr", or "de")
#' @param counterpart_id ID of the counterpart entry
#' @param debit_account Account number for debit entry
#' @param credit_account Account number for credit entry
#' @param descr Description of the transaction
#' @param amount Transaction amount
#' @param import_csv Logical indicating whether to import from CSV
#' @param filename_to_import Path to import CSV file
#' @param export_csv Logical indicating whether to export to CSV
#' @param filename_to_export Path to export CSV file
#'
#' @return A tibble containing the updated ledger with the new entry
#'
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

  last_ledger <- get_ledger(
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
