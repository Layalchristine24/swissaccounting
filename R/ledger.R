get_ledger <- function(...) {
  args <- lst(...)
}

get_last_ledger_version <- function(csv_ledger_file = NULL) {
  if (is.null(csv_ledger_file)) {
    tribble(
      ~date, ~id, ~description, ~debit, ~credit, ~amount,
      NA_Date_, NA_integer_, NA_character_, NA_integer_, NA_integer_, NA_real_
    )
  } else {
    readr::read_csv(csv_ledger_file)
  }
}

check_flow <- function(flow = NULL) {
  allowed_flow <- c(
    "debit",
    "credit"
  )

  if (is.null(flow)) {
    cli_abort("{.var flow} should be either {allowed_flow[[1]]} or {allowed_flow[[2]]}.")
  }

  ans <- match.arg(flow,
    choices = allowed_flow,
    several.ok = FALSE
  )
  ans
}

# Assuming the 'accounts_model_fr' tribble is already loaded

# Function to classify account types based on account number
classify_account_type <- function(account_number) {
  if (startsWith(as.character(account_number), "1")) {
    return("Asset")
  } else if (startsWith(as.character(account_number), "5")) {
    return("Expense")
  } else {
    return("Other")
  }
}

# Applying the function to the 'numero_de_compte' column and adding a new column 'classification'
accounts_model_fr <- mutate(accounts_model_fr, classification = classify_account_type(numero_de_compte))

# Displaying the result with account ID
print(accounts_model_fr[, c("numero_de_compte", "description_du_compte", "type", "classification")])

# add_ledger_entry(date = today(), account_number = 1000, descr = "smth")
# add_ledger_entry(date = today(), flow = "debit", account_number = 1000, descr = "smth")
# https://www.banana.ch/doc/fr/node/2726
add_ledger_entry <- function(date, account_number, flow = NULL,
                             descr = NULL, counterpart = list(...), amount) {
  last_ledger <- get_last_ledger_version()
  flow <- check_flow(flow)

  if (starts_with(c(1, 5), )) {
    last_ledger |>
      add_row(
        date = date,
        id = if_else(is.na(max(last_ledger$id)), 1L, max(last_ledger$id) + 1L),
        account_number = classify_account_type(as.integer(account_number)), # FIXME DEBIT OR CREDIT
        description = descr
      )
  }
}
