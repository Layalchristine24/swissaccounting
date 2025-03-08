#' Calculate Total Assets by Account Description
#'
#' @description
#' This function reads a ledger file and calculates the sum of assets for each account
#' description, considering both debit and credit entries that start with '1'.
#'
#' @param ledger_file Path to the CSV ledger file
#' @param import_csv Logical indicating whether to import CSV (currently unused)
#'
#' @return A data frame containing account descriptions and their total asset values
#'
#' @examples
#' \dontrun{
#' get_assets(ledger_file = my_ledger_directory)
#' }
#'
#' @export
get_assets <- function(ledger_file = TRUE,
                       import_csv = TRUE) {
  if (is.null(ledger_file)) {
    cli_abort(".var{ledger_file} is required. Please provide a path to the ledger file.")
  } else {
    my_ledger <- read_csv(
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

    my_ledger |>
      filter(grepl("^1", debit_account) | (grepl("^1", credit_account))) |>
      reframe(
        amount = if_else(!is.na(debit_account), amount, -amount),
        .by = c(date, id, account_description, debit_account, credit_account)
      ) |>
      reframe(
        sum_assets = sum(amount, na.rm = TRUE),
        .by = account_description
      )
  }
}
