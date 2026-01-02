#' Close Fiscal Year
#'
#' Creates year-end closing entries following Swiss GAAP accounting standards.
#' Closes all profit and loss accounts (categories 3-8) to account 9200
#' (Current Year Profit/Loss), then transfers to account 2891 (Balance Sheet
#' Profit/Loss), and finally to the specified equity account (default: 2850
#' Private Account).
#'
#' @param ledger_file Path to the ledger CSV file
#' @param closing_date Date of fiscal year end (as character string, e.g., "2024-12-31")
#' @param language Language for account descriptions: "en" (English), "fr" (French), or "de" (German).
#'   If not specified, automatically detects language from existing ledger.
#' @param transfer_to_account Account number to receive final P&L transfer (default: 2850L for Private Account)
#' @param overwrite If TRUE, allows overwriting existing closing entries for the same date (default: FALSE)
#'
#' @return Invisibly returns the updated ledger tibble
#' @export
#'
#' @examples
#' \dontrun{
#' # Close fiscal year 2024
#' close_fiscal_year(
#'   ledger_file = "path/to/ledger.csv",
#'   closing_date = "2024-12-31",
#'   language = "en"
#' )
#' }
close_fiscal_year <- function(ledger_file,
                              closing_date,
                              language = NULL,
                              transfer_to_account = 2850L,
                              overwrite = FALSE) {

  # Detect language if not specified
  if (is.null(language)) {
    language <- detect_ledger_language(ledger_file)
  }

  # Validate language
  if (!language %in% c("en", "fr", "de")) {
    cli_abort("Language must be 'en', 'fr', or 'de'")
  }

  # Check if closing already exists
  if (check_closing_exists(ledger_file, closing_date) && !overwrite) {
    cli_abort(paste0("Closing entries already exist for ", closing_date, ". Use overwrite = TRUE to replace."))
  }

  # Parse closing date
  closing_date_parsed <- ymd(closing_date)

  # Get P&L account balances (categories 3-8) up to closing date
  pl_balances <- get_account_balances_at_date(
    ledger_file = ledger_file,
    closing_date = closing_date,
    account_range = c(3L, 4L, 5L, 6L, 7L, 8L),
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

  # Get account 9200 description
  account_9200 <- account_model |>
    filter(account_number == 9200L)

  if (nrow(account_9200) == 0) {
    cli_abort("Account 9200 (Current Year Profit/Loss) not found in account model")
  }

  closing_type <- if (language == "fr") {
    "Clôture"
  } else if (language == "de") {
    "Abschluss"
  } else {
    "Closing"
  }

  closing_desc_prefix <- if (language == "fr") {
    "Clôture:"
  } else if (language == "de") {
    "Abschluss:"
  } else {
    "Closing:"
  }

  transfer_desc <- if (language == "fr") {
    "Transfert au bilan"
  } else if (language == "de") {
    "Übertrag zur Bilanz"
  } else {
    "Transfer to Balance Sheet"
  }

  transfer_to_private_desc <- if (language == "fr") {
    "Transfert au compte privé"
  } else if (language == "de") {
    "Übertrag zum Privatkonto"
  } else {
    "Transfer to Private Account"
  }

  # Get next available ID
  next_id <- get_next_ledger_id(ledger_file)

  # Initialize entries list
  closing_entries <- list()
  current_id <- next_id

  # Create closing entries for each P&L account
  for (i in seq_len(nrow(pl_balances))) {
    account_num <- pl_balances$account_number[i]
    account_desc <- pl_balances$account_description[i]
    balance <- pl_balances$sum_amounts[i]
    account_base_cat <- pl_balances$account_base_category[i]

    # Determine if this is income (category 3) or expense (categories 4-8)
    is_income <- account_base_cat == 3L

    if (is_income) {
      # Income accounts: DR Income, CR 9200
      # Entry 1: Debit the income account
      closing_entries[[length(closing_entries) + 1]] <- tibble(
        date = closing_date_parsed,
        id = current_id,
        counterpart_id = current_id,
        description = paste(closing_desc_prefix, account_desc),
        debit_account = account_num,
        credit_account = NA_integer_,
        amount = abs(balance),
        account_description = account_desc,
        account_type = closing_type
      )

      # Entry 2: Credit account 9200
      closing_entries[[length(closing_entries) + 1]] <- tibble(
        date = closing_date_parsed,
        id = current_id + 1L,
        counterpart_id = current_id,
        description = paste(closing_desc_prefix, account_desc),
        debit_account = NA_integer_,
        credit_account = 9200L,
        amount = abs(balance),
        account_description = account_9200$account_description[1],
        account_type = closing_type
      )
    } else {
      # Expense accounts: DR 9200, CR Expense
      # Entry 1: Debit account 9200
      closing_entries[[length(closing_entries) + 1]] <- tibble(
        date = closing_date_parsed,
        id = current_id,
        counterpart_id = current_id,
        description = paste(closing_desc_prefix, account_desc),
        debit_account = 9200L,
        credit_account = NA_integer_,
        amount = abs(balance),
        account_description = account_9200$account_description[1],
        account_type = closing_type
      )

      # Entry 2: Credit the expense account
      closing_entries[[length(closing_entries) + 1]] <- tibble(
        date = closing_date_parsed,
        id = current_id + 1L,
        counterpart_id = current_id,
        description = paste(closing_desc_prefix, account_desc),
        debit_account = NA_integer_,
        credit_account = account_num,
        amount = abs(balance),
        account_description = account_desc,
        account_type = closing_type
      )
    }

    current_id <- current_id + 2L
  }

  # Calculate net P&L (sum of all balances)
  # Income accounts have negative sum_amounts, expenses have positive
  net_pl <- sum(pl_balances$sum_amounts)

  # Get account 2891 description
  account_2891 <- account_model |>
    filter(account_number == 2891L)

  if (nrow(account_2891) == 0) {
    cli_abort("Account 2891 (Balance Sheet Profit/Loss) not found in account model")
  }

  # Transfer 9200 to 2891
  if (net_pl < 0) {
    # Profit: DR 9200, CR 2891
    closing_entries[[length(closing_entries) + 1]] <- tibble(
      date = closing_date_parsed,
      id = current_id,
      counterpart_id = current_id,
      description = transfer_desc,
      debit_account = 9200L,
      credit_account = NA_integer_,
      amount = abs(net_pl),
      account_description = account_9200$account_description[1],
      account_type = closing_type
    )

    closing_entries[[length(closing_entries) + 1]] <- tibble(
      date = closing_date_parsed,
      id = current_id + 1L,
      counterpart_id = current_id,
      description = transfer_desc,
      debit_account = NA_integer_,
      credit_account = 2891L,
      amount = abs(net_pl),
      account_description = account_2891$account_description[1],
      account_type = "Liability"
    )
  } else {
    # Loss: DR 2891, CR 9200
    closing_entries[[length(closing_entries) + 1]] <- tibble(
      date = closing_date_parsed,
      id = current_id,
      counterpart_id = current_id,
      description = transfer_desc,
      debit_account = 2891L,
      credit_account = NA_integer_,
      amount = abs(net_pl),
      account_description = account_2891$account_description[1],
      account_type = "Liability"
    )

    closing_entries[[length(closing_entries) + 1]] <- tibble(
      date = closing_date_parsed,
      id = current_id + 1L,
      counterpart_id = current_id,
      description = transfer_desc,
      debit_account = NA_integer_,
      credit_account = 9200L,
      amount = abs(net_pl),
      account_description = account_9200$account_description[1],
      account_type = closing_type
    )
  }

  current_id <- current_id + 2L

  # Get transfer_to_account description
  transfer_account <- account_model |>
    filter(account_number == transfer_to_account)

  if (nrow(transfer_account) == 0) {
    cli_abort(paste0("Account ", transfer_to_account, " not found in account model"))
  }

  # Transfer 2891 to transfer_to_account (default: 2850)
  if (net_pl < 0) {
    # Profit: DR 2891, CR 2850
    closing_entries[[length(closing_entries) + 1]] <- tibble(
      date = closing_date_parsed,
      id = current_id,
      counterpart_id = current_id,
      description = transfer_to_private_desc,
      debit_account = 2891L,
      credit_account = NA_integer_,
      amount = abs(net_pl),
      account_description = account_2891$account_description[1],
      account_type = "Liability"
    )

    closing_entries[[length(closing_entries) + 1]] <- tibble(
      date = closing_date_parsed,
      id = current_id + 1L,
      counterpart_id = current_id,
      description = transfer_to_private_desc,
      debit_account = NA_integer_,
      credit_account = transfer_to_account,
      amount = abs(net_pl),
      account_description = transfer_account$account_description[1],
      account_type = "Liability"
    )
  } else {
    # Loss: DR 2850, CR 2891
    closing_entries[[length(closing_entries) + 1]] <- tibble(
      date = closing_date_parsed,
      id = current_id,
      counterpart_id = current_id,
      description = transfer_to_private_desc,
      debit_account = transfer_to_account,
      credit_account = NA_integer_,
      amount = abs(net_pl),
      account_description = transfer_account$account_description[1],
      account_type = "Liability"
    )

    closing_entries[[length(closing_entries) + 1]] <- tibble(
      date = closing_date_parsed,
      id = current_id + 1L,
      counterpart_id = current_id,
      description = transfer_to_private_desc,
      debit_account = NA_integer_,
      credit_account = 2891L,
      amount = abs(net_pl),
      account_description = account_2891$account_description[1],
      account_type = "Liability"
    )
  }

  # Combine all entries
  all_closing_entries <- bind_rows(closing_entries)

  # Append to ledger
  updated_ledger <- append_ledger_entries(ledger_file, all_closing_entries)

  invisible(updated_ledger)
}
