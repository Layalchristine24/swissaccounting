#' Read Ledger CSV File
#'
#' @description
#' Reads a CSV ledger file with predefined column types for accounting data.
#' Automatically converts dates, numeric values, and text fields to appropriate
#' data types.
#'
#' @param ledger_file character Path to the CSV ledger file to read
#'
#' @return data.frame A data frame with the following columns:
#'   \item{date}{Date. Transaction date}
#'   \item{description}{Character. Transaction description}
#'   \item{account_description}{Character. Description of the account}
#'   \item{account_type}{Character. Type of account}
#'   \item{amount}{Numeric. Transaction amount}
#'   \item{Other integer columns}{Integer. Additional numeric columns default to
#'     integer type}
#'
#' @examples
#' \dontrun{
#' ledger_data <- read_ledger_csv("path/to/ledger.csv")
#' }
#'
#' @autoglobal
read_ledger_csv <- function(ledger_file) {
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


#' Filter Ledger Data by Date Range
#'
#' @description
#' Filters a ledger data frame by an optional date range. If no dates are
#' provided, returns the original data frame unchanged.
#'
#' @param ledger_data data.frame A ledger data frame containing a 'date' column
#' @param min_date character,Date Optional. Minimum date to include in filter
#'   (format: "YYYY-MM-DD")
#' @param max_date character,Date Optional. Maximum date to include in filter
#'   (format: "YYYY-MM-DD")
#'
#' @return data.frame The filtered ledger data frame. If no date filters are
#'   provided, returns the original data frame
#'
#' @examples
#' \dontrun{
#' # Filter ledger for year 2024
#' filtered_data <- filter_ledger_date_range(
#'   ledger_data = my_ledger,
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31"
#' )
#'
#' # Filter from specific date onwards
#' from_date <- filter_ledger_date_range(
#'   ledger_data = my_ledger,
#'   min_date = "2024-03-01"
#' )
#' }
#'
#' @autoglobal
filter_ledger_date_range <- function(ledger_data, min_date, max_date) {
  my_ledger_min_filtered <-
    if (!is.null(min_date)) {
      ledger_data |>
        filter(date >= ymd(min_date))
    } else {
      ledger_data
    }

  if (!is.null(max_date)) {
    my_ledger_min_filtered |>
      filter(date <= ymd(max_date))
  } else {
    my_ledger_min_filtered
  }
}


#' Select Language for Ledger Accounts
#'
#' @description
#' Filters the consolidated accounting plans to return account descriptions in the
#' specified language, removing language suffixes from column names.
#'
#' @param ledger_data data.frame A ledger data frame with account information
#' @param language character Language code for account descriptions. One of "en",
#'   "fr", "de"
#'
#' @return data.frame A data frame with columns:
#'   \item{account_number}{Integer. The account identifier}
#'   \item{account_type}{Character. Account type in selected language}
#'   \item{account_description}{Character. Account description in selected
#'     language}
#'
#' @examples
#' \dontrun{
#' # Get French account descriptions
#' french_accounts <- select_ledger_language(my_ledger, "fr")
#'
#' # Get German account descriptions
#' german_accounts <- select_ledger_language(my_ledger, "de")
#' }
#'
#' @autoglobal
select_ledger_language <- function(ledger_data, language) {
  consolidate_accounting_plans() |>
    select(account_number, ends_with(language)) |>
    rename_with(~ str_remove(., paste0("_", language, "$")))
}


#' Get Balance Sheet Category Details
#'
#' @description
#' Calculates and categorizes balance sheet entries for either assets or
#' liabilities, including intermediate category descriptions in the specified
#' language.
#'
#' @param ledger_data data.frame A ledger data frame containing accounting entries
#' @param target_language_ledger data.frame Account descriptions in the target
#'   language, as returned by select_ledger_language()
#' @param balance_category character The balance sheet category to process. Must be
#'   either "assets" or "liabilities"
#'
#' @return data.frame A data frame containing:
#'   \item{account_base_category}{Integer. First digit of account number (1 or 2)}
#'   \item{high_category}{Integer. First two digits of account number}
#'   \item{intermediate_category}{Integer. First three digits of account number}
#'   \item{account_number}{Integer. Full account number}
#'   \item{account_description}{Character. Account description in target language}
#'   \item{sum_amounts}{Numeric. Total values for each account}
#'   \item{account_description_intermediate}{Character. Intermediate category
#'     description}
#'
#' @examples
#' \dontrun{
#' # Get French language assets
#' french_ledger <- select_ledger_language(my_ledger, "fr")
#' assets <- get_account_category(
#'   ledger_data = my_ledger,
#'   target_language_ledger = french_ledger,
#'   balance_category = "assets"
#' )
#' }
#'
#' @autoglobal
get_account_category <- function(ledger_data, target_language_ledger, balance_category = NULL) {
  if (is.null(balance_category)) {
    cli_abort("Balance category is required. Please provide a balance category, either 'assets' or 'liabilities'.")
  }
  balance_category_integer <-
    if (balance_category == "assets") {
      1L
    } else if (balance_category == "liabilities") {
      2L
    } else {
      cli_abort("Balance category is required. Please provide a balance category, either 'assets' or 'liabilities'.")
    }

  sum_accounts(ledger_data) |>
    select(-account_description) |>
    left_join(
      target_language_ledger |>
        select(-account_type),
      by = join_by(account_number)
    ) |>
    filter(account_base_category == balance_category_integer) |>
    left_join(
      target_language_ledger |>
        rename(
          account_description_intermediate = account_description,
          intermediate_category = account_number
        ),
      by = join_by(intermediate_category)
    )
}

#' Get Balance Sheet Side (Assets or Liabilities)
#'
#' @description
#' Processes one side of a balance sheet (assets or liabilities) by reading the
#' ledger, applying date filters, and calculating totals in the specified
#' language.
#'
#' @param ledger_file character Path to the CSV ledger file
#' @param min_date character,Date Optional. Minimum date to filter transactions
#'   (format: "YYYY-MM-DD")
#' @param max_date character,Date Optional. Maximum date to filter transactions
#'   (format: "YYYY-MM-DD")
#' @param language character Language code for account descriptions. One of "en",
#'   "fr", "de"
#' @param balance_category character The balance sheet category to process. Must be
#'   either "assets" or "liabilities"
#'
#' @return data.frame A data frame containing:
#'   \item{account_base_category}{Integer. First digit of account number (1 or 2)}
#'   \item{high_category}{Integer. First two digits of account number}
#'   \item{intermediate_category}{Integer. First three digits of account number}
#'   \item{account_number}{Integer. Full account number}
#'   \item{account_description}{Character. Account description in target language}
#'   \item{sum_amounts}{Numeric. Total values for each account}
#'   \item{account_description_intermediate}{Character. Intermediate category
#'     description}
#'
#' @examples
#' \dontrun{
#' # Get assets in French for a specific period
#' assets <- get_balance_side(
#'   ledger_file = "path/to/ledger.csv",
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   language = "fr",
#'   balance_category = "assets"
#' )
#' }
#'
#' @seealso
#' \code{\link{read_ledger_csv}} for reading the ledger file
#' \code{\link{filter_ledger_date_range}} for date filtering
#' \code{\link{select_ledger_language}} for language selection
#' \code{\link{get_account_category}} for balance calculation
#'
#' @autoglobal
get_balance_side <- function(ledger_file, min_date, max_date, language, balance_category) {
  my_ledger <- read_ledger_csv(ledger_file)

  my_ledger_filtered <-
    filter_ledger_date_range(
      ledger_data = my_ledger,
      min_date = min_date,
      max_date = max_date
    )

  target_language_ledger <-
    select_ledger_language(
      ledger_data = my_ledger_filtered,
      language = language
    )

  get_account_category(
    ledger_data = my_ledger_filtered,
    target_language_ledger = target_language_ledger,
    balance_category = balance_category
  )
}
