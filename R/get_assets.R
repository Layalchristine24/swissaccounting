#' Calculate Total Assets by Account Description
#'
#' @description
#' This function reads a ledger file and calculates the sum of assets for each
#' account description, considering both debit and credit entries that start with
#' '1'.
#'
#' @param ledger_file character Path to the CSV ledger file
#' @param min_date character,Date Optional. Minimum date to filter transactions
#'   (format: "YYYY-MM-DD")
#' @param max_date character,Date Optional. Maximum date to filter transactions
#'   (format: "YYYY-MM-DD")
#' @param language character Language code for account descriptions. One of "en",
#'   "fr", "de". Defaults to "fr"
#'
#' @return data.frame A data frame containing:
#'   \item{account_base_category}{Integer. First digit of account number (1-9)}
#'   \item{high_category}{Integer. First two digits of account number}
#'   \item{intermediate_category}{Integer. First three digits of account number}
#'   \item{account_number}{Integer. Full account number}
#'   \item{account_description}{Character. Account description in selected
#'     language}
#'   \item{sum_assets}{Numeric. Total asset values}
#'   \item{account_description_intermediate}{Character. Intermediate level
#'     description}
#'
#' @examples
#' \dontrun{
#' # Using French account descriptions (default)
#' get_assets(ledger_file = my_ledger_directory)
#'
#' # Using German account descriptions with date range
#' get_assets(
#'   ledger_file = my_ledger_directory,
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   language = "de"
#' )
#' }
#'
#' @autoglobal
#' @export
get_assets <- function(
    ledger_file = NULL,
    min_date = NULL,
    max_date = NULL,
    language = "fr") {
  if (is.null(ledger_file)) {
    cli_abort(".var{ledger_file} is required. Please provide a path to the ledger CSV file.")
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
    my_ledger_min_filtered <-
      if (!is.null(min_date)) {
        my_ledger |>
          filter(date >= ymd(min_date))
      } else {
        my_ledger
      }
    my_ledger_filtered <-
      if (!is.null(max_date)) {
        my_ledger_min_filtered |>
          filter(date <= ymd(max_date))
      } else {
        my_ledger_min_filtered
      }

    consolidated_accounts <-
      consolidate_accounting_plans() |>
      select(account_number, ends_with(language)) |>
      rename_with(~ str_remove(., paste0("_", language, "$")))

    sum_accounts(my_ledger_filtered) |>
      select(-account_description) |>
      left_join(
        consolidated_accounts |>
          select(-account_type),
        by = join_by(account_number)
      ) |>
      filter(account_base_category == 1L) |>
      left_join(
        consolidated_accounts |>
          rename(
            account_description_intermediate = account_description,
            intermediate_category = account_number
          ),
        by = join_by(intermediate_category)
      )
  }
}
