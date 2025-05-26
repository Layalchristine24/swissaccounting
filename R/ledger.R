#' Retrieve Ledger Data
#'
#' @description
#' Retrieves the most recent version of the ledger, either creating an empty one or
#' importing from a CSV file. This is an internal function used by add_ledger_entry.
#'
#' @param ledger_file character Path to the CSV ledger file. If NULL, returns an empty ledger structure.
#' @param import_csv logical Whether to import from CSV file. Defaults to FALSE.
#'
#' @return tibble A tibble containing ledger data with columns:
#'   \itemize{
#'     \item{date}{Date. Transaction date}
#'     \item{id}{Integer. Unique transaction identifier}
#'     \item{counterpart_id}{Integer. ID of the counterpart entry}
#'     \item{description}{Character. Transaction description}
#'     \item{debit_account}{Integer. Account number for debit entry}
#'     \item{credit_account}{Integer. Account number for credit entry}
#'     \item{amount}{Numeric. Transaction amount}
#'   }
#'
#' @examples
#' \dontrun{
#' # Create empty ledger
#' empty_ledger <- get_ledger()
#'
#' # Import from CSV
#' ledger_data <- get_ledger("path/to/ledger.csv", import_csv = TRUE)
#' }
#'
#' @keywords internal
#' @autoglobal
get_ledger <- function(ledger_file = NULL, import_csv = FALSE) {
  if (is.null(ledger_file)) {
    # fmt: skip
    tribble(
      ~date, ~id, ~counterpart_id, ~description, ~debit_account, ~credit_account, ~amount,
      NA_Date_, NA_integer_, NA_integer_, NA_character_, NA_integer_, NA_integer_, NA_real_
    )
  } else if (import_csv) {
    read_csv(
      ledger_file,
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

#' Add Entry to Accounting Ledger
#'
#' @description
#' Adds a new entry to the accounting ledger with support for multiple languages
#' and optional CSV import/export functionality. The function handles both debit
#' and credit entries, with automatic account type and description lookup based
#' on the specified language.
#'
#' @param date Date,character Date of the ledger entry. If character, will be converted to Date.
#' @param language character Language code for account descriptions. One of "en", "fr", "de".
#'   Defaults to "en".
#' @param counterpart_id integer Optional. ID of the counterpart entry for double-entry bookkeeping.
#' @param debit_account integer Optional. Account number for debit entry.
#' @param credit_account integer Optional. Account number for credit entry.
#' @param descr character Description of the transaction.
#' @param amount numeric Transaction amount.
#' @param import_csv logical Whether to import from CSV file. Defaults to FALSE.
#' @param filename_to_import character Optional. Path to import CSV file.
#' @param export_csv logical Whether to export to CSV file. Defaults to FALSE.
#' @param filename_to_export character Optional. Path to export CSV file.
#'
#' @return tibble A tibble containing the updated ledger with the new entry.
#'   See get_ledger() for column descriptions.
#'
#' @examples
#' \dontrun{
#' # Add a simple debit entry
#' ledger <- add_ledger_entry(
#'   date = "2024-01-01",
#'   descr = "Office supplies",
#'   debit_account = 4000,
#'   amount = 100
#' )
#'
#' # Add a credit entry with counterpart
#' ledger <- add_ledger_entry(
#'   date = "2024-01-01",
#'   descr = "Payment for office supplies",
#'   credit_account = 1020,
#'   amount = 100,
#'   counterpart_id = 1
#' )
#' }
#'
#' @seealso
#' \code{\link{get_ledger}} for retrieving ledger data
#' \code{\link{accounts_model_en}} for English account descriptions
#' \code{\link{accounts_model_fr}} for French account descriptions
#' \code{\link{accounts_model_de}} for German account descriptions
#'
#' @export
#' @autoglobal
add_ledger_entry <- function(
  date,
  language = "en",
  counterpart_id = NULL,
  debit_account = NULL,
  credit_account = NULL,
  descr = NULL,
  amount,
  import_csv = FALSE,
  filename_to_import = NULL,
  export_csv = FALSE,
  filename_to_export = NULL
) {
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
