#' Add a Complete Transaction (Debit + Credit Pair)
#'
#' @description
#' Simplified function to add a complete double-entry transaction with one call.
#' This function adds two ledger entries (debit and credit) automatically, maintaining
#' the exact same behavior as manual calls to \code{add_ledger_entry()}.
#'
#' The function creates two entries:
#' \itemize{
#'   \item{First entry (debit): Creates an entry with self-linked counterpart_id}
#'   \item{Second entry (credit): Automatically links to the first entry via counterpart_id}
#' }
#'
#' This ensures proper double-entry bookkeeping and maintains Swiss GAAP compliance.
#'
#' @param ledger_file Path to the ledger CSV file
#' @param date Transaction date (character or Date object)
#' @param descr Transaction description
#' @param debit_account Account number to debit
#' @param credit_account Account number to credit
#' @param amount Transaction amount (positive number)
#'
#' @return Invisibly returns NULL. Side effect: updates the ledger CSV file
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Define ledger file path
#' ledger_file <- "path/to/ledger.csv"
#'
#' # Add a simple transaction
#' add_transaction(
#'   ledger_file = ledger_file,
#'   date = "2024-01-15",
#'   descr = "Office supplies",
#'   debit_account = 4000,
#'   credit_account = 1020,
#'   amount = 500
#' )
#'
#' # Add service revenue
#' add_transaction(
#'   ledger_file = ledger_file,
#'   date = "2024-02-15",
#'   descr = "Consulting services",
#'   debit_account = 1020,
#'   credit_account = 3000,
#'   amount = 3000
#' )
#' }
add_transaction <- function(ledger_file, date, descr, debit_account, credit_account, amount) {
  # First entry: export only (no import) - creates entry with self-linked counterpart_id
  add_ledger_entry(
    date = date,
    descr = descr,
    debit_account = debit_account,
    amount = amount,
    export_csv = TRUE,
    filename_to_export = ledger_file
  )

  # Second entry: import and export - automatically links to previous entry via counterpart_id
  add_ledger_entry(
    date = date,
    descr = descr,
    credit_account = credit_account,
    amount = amount,
    import_csv = TRUE,
    filename_to_import = ledger_file,
    export_csv = TRUE,
    filename_to_export = ledger_file
  )

  invisible(NULL)
}
