#' Create Opening Balances
#'
#' Creates opening balance entries for the start of a new fiscal period.
#' Reads balance sheet accounts (categories 1-2) from the previous period
#' and creates opening entries using account 9100 (Opening Balance) as counterpart.
#'
#' @param ledger_file Path to the ledger CSV file
#' @param opening_date Date of new fiscal period start (as character string, e.g., "2025-01-01")
#' @param previous_closing_date Date of previous fiscal period end (as character string).
#'   If NULL, automatically calculates as opening_date - 1 day.
#' @param language Language for account descriptions: "en" (English), "fr" (French), or "de" (German).
#'   If not specified, automatically detects language from existing ledger.
#' @param overwrite If TRUE, allows overwriting existing opening entries for the same date (default: FALSE)
#'
#' @return Invisibly returns the updated ledger tibble
#' @export
#'
#' @examples
#' \dontrun{
#' # Create opening balances for 2025
#' create_opening_balances(
#'   ledger_file = "path/to/ledger.csv",
#'   opening_date = "2025-01-01",
#'   language = "en"
#' )
#' }
create_opening_balances <- function(ledger_file,
                                    opening_date,
                                    previous_closing_date = NULL,
                                    language = NULL,
                                    overwrite = FALSE) {

  # Detect language if not specified
  if (is.null(language)) {
    language <- detect_ledger_language(ledger_file)
  }

  # Validate language
  if (!language %in% c("en", "fr", "de")) {
    cli_abort("Language must be 'en', 'fr', or 'de'")
  }

  # Parse opening date
  opening_date_parsed <- ymd(opening_date)

  # Calculate previous closing date if not provided
  if (is.null(previous_closing_date)) {
    previous_closing_date_parsed <- opening_date_parsed - 1
  } else {
    previous_closing_date_parsed <- ymd(previous_closing_date)
  }

  # Check if opening already exists
  if (check_opening_exists(ledger_file, opening_date) && !overwrite) {
    cli_abort(paste0("Opening entries already exist for ", opening_date, ". Use overwrite = TRUE to replace."))
  }

  # Get balance sheet account balances (categories 1-2) at previous closing date
  bs_balances <- get_account_balances_at_date(
    ledger_file = ledger_file,
    closing_date = as.character(previous_closing_date_parsed),
    account_range = c(1L, 2L),
    language = language
  )

  # Get account model for descriptions
  account_model <- if (language == "fr") {
    accounts_model_fr
  } else if (language == "en") {
    accounts_model_en
  } else if (language == "de") {
    accounts_model_de
  }

  # Get account 9100 description
  account_9100 <- account_model |>
    filter(account_number == 9100L)

  if (nrow(account_9100) == 0) {
    cli_abort("Account 9100 (Opening Balance) not found in account model. Please add it to accounting_plan_template.R")
  }

  opening_desc_prefix <- if (language == "fr") {
    "Bilan d'ouverture:"
  } else if (language == "de") {
    "Eröffnungsbilanz:"
  } else {
    "Opening Balance:"
  }

  opening_desc <- if (language == "fr") {
    "Bilan d'ouverture"
  } else if (language == "de") {
    "Eröffnungsbilanz"
  } else {
    "Opening Balance"
  }

  closing_type <- if (language == "fr") {
    "Clôture"
  } else if (language == "de") {
    "Abschluss"
  } else {
    "Closing"
  }

  # Get next available ID
  next_id <- get_next_ledger_id(ledger_file)

  # Initialize entries list
  opening_entries <- list()
  current_id <- next_id

  # Create opening entries for each balance sheet account
  for (i in seq_len(nrow(bs_balances))) {
    account_num <- bs_balances$account_number[i]
    account_desc <- bs_balances$account_description[i]
    balance <- bs_balances$sum_amounts[i]
    account_type <- bs_balances$account_type[i]

    # Determine if this is an asset (category 1) or liability (category 2)
    is_asset <- account_type == "Asset"

    if (is_asset) {
      if (balance > 0) {
        # Asset with debit balance (normal): DR Asset, CR 9100
        # Entry 1: Debit the asset account
        opening_entries[[length(opening_entries) + 1]] <- tibble(
          date = opening_date_parsed,
          id = current_id,
          counterpart_id = current_id,
          description = paste(opening_desc_prefix, account_desc),
          debit_account = account_num,
          credit_account = NA_integer_,
          amount = abs(balance),
          account_description = account_desc,
          account_type = account_type
        )

        # Entry 2: Credit account 9100
        opening_entries[[length(opening_entries) + 1]] <- tibble(
          date = opening_date_parsed,
          id = current_id + 1L,
          counterpart_id = current_id,
          description = opening_desc,
          debit_account = NA_integer_,
          credit_account = 9100L,
          amount = abs(balance),
          account_description = account_9100$account_description[1],
          account_type = closing_type
        )
      } else {
        # Asset with credit balance (reversed): DR 9100, CR Asset
        # Entry 1: Debit account 9100
        opening_entries[[length(opening_entries) + 1]] <- tibble(
          date = opening_date_parsed,
          id = current_id,
          counterpart_id = current_id,
          description = opening_desc,
          debit_account = 9100L,
          credit_account = NA_integer_,
          amount = abs(balance),
          account_description = account_9100$account_description[1],
          account_type = closing_type
        )

        # Entry 2: Credit the asset account
        opening_entries[[length(opening_entries) + 1]] <- tibble(
          date = opening_date_parsed,
          id = current_id + 1L,
          counterpart_id = current_id,
          description = paste(opening_desc_prefix, account_desc),
          debit_account = NA_integer_,
          credit_account = account_num,
          amount = abs(balance),
          account_description = account_desc,
          account_type = account_type
        )
      }
    } else {
      # Liability account
      if (balance < 0) {
        # Liability with credit balance (normal): DR 9100, CR Liability
        # Entry 1: Debit account 9100
        opening_entries[[length(opening_entries) + 1]] <- tibble(
          date = opening_date_parsed,
          id = current_id,
          counterpart_id = current_id,
          description = opening_desc,
          debit_account = 9100L,
          credit_account = NA_integer_,
          amount = abs(balance),
          account_description = account_9100$account_description[1],
          account_type = closing_type
        )

        # Entry 2: Credit the liability account
        opening_entries[[length(opening_entries) + 1]] <- tibble(
          date = opening_date_parsed,
          id = current_id + 1L,
          counterpart_id = current_id,
          description = paste(opening_desc_prefix, account_desc),
          debit_account = NA_integer_,
          credit_account = account_num,
          amount = abs(balance),
          account_description = account_desc,
          account_type = account_type
        )
      } else {
        # Liability with debit balance (reversed): DR Liability, CR 9100
        # Entry 1: Debit the liability account
        opening_entries[[length(opening_entries) + 1]] <- tibble(
          date = opening_date_parsed,
          id = current_id,
          counterpart_id = current_id,
          description = paste(opening_desc_prefix, account_desc),
          debit_account = account_num,
          credit_account = NA_integer_,
          amount = abs(balance),
          account_description = account_desc,
          account_type = account_type
        )

        # Entry 2: Credit account 9100
        opening_entries[[length(opening_entries) + 1]] <- tibble(
          date = opening_date_parsed,
          id = current_id + 1L,
          counterpart_id = current_id,
          description = opening_desc,
          debit_account = NA_integer_,
          credit_account = 9100L,
          amount = abs(balance),
          account_description = account_9100$account_description[1],
          account_type = closing_type
        )
      }
    }

    current_id <- current_id + 2L
  }

  # Combine all entries
  all_opening_entries <- bind_rows(opening_entries)

  # Append to ledger
  updated_ledger <- append_ledger_entries(ledger_file, all_opening_entries)

  invisible(updated_ledger)
}
