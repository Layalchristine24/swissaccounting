
# ledger_file <- "/Users/Layal//ersatz-production/ersatz-accounting/ersatz.accounting/documents/ledger/ersatz-ledger.csv"

get_assets <- function(ledger_file = TRUE,
                       import_csv = TRUE) {
  if (is.null(ledger_file)) {
    cli::cli_abort(".var{ledger_file} is required. Please provide a path to the ledger file.")
  } else {
    my_ledger <- readr::read_csv(
      ledger_file,
      col_types = readr::cols(
        date = readr::col_date(),
        description = readr::col_character(),
        account_description = readr::col_character(),
        account_type = readr::col_character(),
        .default = readr::col_integer(),
        amount = readr::col_double()
      )
    )

    my_ledger |>
      dplyr::filter(grepl("^1", debit_account) | (grepl("^1", credit_account)))
  }
}
