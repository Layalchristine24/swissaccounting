#' Detect Language Used in Ledger
#'
#' Internal helper function to detect which language is being used in the ledger
#' by examining existing account descriptions.
#'
#' @param ledger_file Path to the ledger CSV file
#'
#' @return Character - "en", "fr", or "de"
#' @keywords internal
#' @noRd
detect_ledger_language <- function(ledger_file) {
  ledger <- read_ledger_csv(ledger_file)

  # Get a sample of account descriptions
  sample_descriptions <- unique(ledger$account_description)[1:min(10, length(unique(ledger$account_description)))]

  # Check for language-specific words
  french_words <- sum(grepl("Banque|Caisse|Actif|Passif|Produit|Charge", sample_descriptions, ignore.case = TRUE))
  english_words <- sum(grepl("Bank|Cash|Asset|Liability|Income|Expense", sample_descriptions, ignore.case = TRUE))
  german_words <- sum(grepl("Aktivkonto|Passivkonto|Einnahmen|Ausgabe", sample_descriptions, ignore.case = TRUE))

  if (french_words > english_words && french_words > german_words) {
    return("fr")
  } else if (german_words > english_words && german_words > french_words) {
    return("de")
  } else {
    return("en")
  }
}

#' Get Next Available Ledger ID
#'
#' Internal helper function to find the next available ID in the ledger.
#' This function scans the entire ledger (all dates) to find the maximum ID.
#'
#' @param ledger_file Path to the ledger CSV file
#'
#' @return Integer - the next available ID (max ID + 1)
#' @keywords internal
#' @noRd
get_next_ledger_id <- function(ledger_file) {
  ledger <- read_ledger_csv(ledger_file)

  # Get max ID from the entire ledger (all dates)
  max_id <- max(ledger$id, na.rm = TRUE)

  if (is.na(max_id) || is.infinite(max_id)) {
    return(1L)
  }

  return(as.integer(max_id + 1L))
}

#' Append Ledger Entries to CSV
#'
#' Internal helper function to append new entries to the ledger CSV file.
#' Automatically detects the language used in the existing ledger.
#' Also handles automatic counterpart_id assignment for batch entries.
#'
#' @param ledger_file Path to the ledger CSV file
#' @param new_entries Tibble with new entries to append. Can include:
#'   - Entries with explicit counterpart_id (will be used as-is)
#'   - Entries without id/counterpart_id columns (will be auto-assigned sequentially)
#'
#' @return Updated ledger tibble (invisibly)
#' @keywords internal
#' @noRd
append_ledger_entries <- function(ledger_file, new_entries) {
  existing_ledger <- read_ledger_csv(ledger_file)

  # Detect language if not already specified in new_entries
  if (nrow(existing_ledger) > 0) {
    detected_language <- detect_ledger_language(ledger_file)

    # Verify new entries use the same language by checking account types
    # (The calling function should have already set the correct language)
  }

  # Check if new_entries have id/counterpart_id columns
  # If not, assign them automatically
  if (!"id" %in% colnames(new_entries)) {
    # Get next available ID
    next_id <- get_next_ledger_id(ledger_file)

    # Assign sequential IDs
    new_entries <- new_entries |>
      mutate(id = seq(from = next_id, length.out = n()))
  }

  if (!"counterpart_id" %in% colnames(new_entries)) {
    # Assign counterpart_ids: first entry of each pair has no counterpart yet
    # Subsequent entries link to the previous entry
    # Assumes entries come in pairs
    new_entries <- new_entries |>
      mutate(counterpart_id = if_else(row_number() %% 2 == 1, NA_integer_, lag(id)))
  }

  updated_ledger <- bind_rows(existing_ledger, new_entries)
  write_csv(updated_ledger, ledger_file)
  invisible(updated_ledger)
}

#' Get Account Balances at Specific Date
#'
#' Internal helper function to get balances for specific account categories at a given date.
#'
#' @param ledger_file Path to the ledger CSV file
#' @param closing_date Date to calculate balances (as character string)
#' @param account_range Vector of account base categories (e.g., c(1L, 2L) for balance sheet)
#' @param language Language for account descriptions ("en", "fr", or "de")
#'
#' @return Tibble with account numbers, balances, descriptions, and account types
#' @keywords internal
#' @noRd
get_account_balances_at_date <- function(ledger_file, closing_date, account_range, language) {
  ledger <- read_ledger_csv(ledger_file)

  # Filter by date range (from beginning to closing date)
  filtered <- filter_ledger_date_range(
    ledger_data = ledger,
    min_date = NULL,
    max_date = closing_date
  )

  # Select language
  target_language_ledger <- select_ledger_language(filtered, language)

  # Sum accounts and filter by account range
  # Note: sum_accounts() needs the full ledger data (with debit_account, credit_account, amount)
  # not target_language_ledger which only has account descriptions
  account_sums <- sum_accounts(filtered) |>
    filter(account_base_category %in% account_range) |>
    filter(sum_amounts != 0)

  # Join with account information to get account types
  account_model <- if (language == "fr") {
    accounts_model_fr
  } else if (language == "en") {
    accounts_model_en
  } else if (language == "de") {
    accounts_model_de
  } else {
    cli_abort("Language must be 'en', 'fr', or 'de'")
  }

  result <- account_sums |>
    left_join(
      account_model |> select(account_number, account_type),
      by = "account_number"
    )

  return(result)
}

#' Check if Closing Entries Exist
#'
#' Internal helper function to check if closing entries already exist for a given date.
#'
#' @param ledger_file Path to the ledger CSV file
#' @param closing_date Date to check (as character string)
#'
#' @return Logical - TRUE if closing entries exist, FALSE otherwise
#' @keywords internal
#' @noRd
check_closing_exists <- function(ledger_file, closing_date) {
  ledger <- read_ledger_csv(ledger_file)
  closing_date_parsed <- ymd(closing_date)

  closing_entries <- ledger |>
    filter(date == closing_date_parsed) |>
    filter(account_type %in% c("Closing", "Clôture", "Abschluss"))

  return(nrow(closing_entries) > 0)
}

#' Check if Opening Entries Exist
#'
#' Internal helper function to check if opening balance entries already exist for a given date.
#'
#' @param ledger_file Path to the ledger CSV file
#' @param opening_date Date to check (as character string)
#'
#' @return Logical - TRUE if opening entries exist, FALSE otherwise
#' @keywords internal
#' @noRd
check_opening_exists <- function(ledger_file, opening_date) {
  ledger <- read_ledger_csv(ledger_file)
  opening_date_parsed <- ymd(opening_date)

  opening_entries <- ledger |>
    filter(date == opening_date_parsed) |>
    filter(grepl("Opening|Ouverture|Eröffnung|Bilan d'ouverture|Opening Balance|Eröffnungsbilanz",
                       description, ignore.case = TRUE))

  return(nrow(opening_entries) > 0)
}
