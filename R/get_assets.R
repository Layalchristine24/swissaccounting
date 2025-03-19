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
#' @param accounts_plan data.frame Account plan to use for mapping descriptions.
#'   Defaults to accounts_model_en
#'
#' @return data.frame A data frame containing:
#'   \item{account_description}{Description of the account}
#'   \item{sum_assets}{Total asset values}
#'   \item{account_description_intermediate}{Mapped intermediate descriptions}
#'
#' @examples
#' \dontrun{
#' # Using default English account model
#' get_assets(ledger_file = my_ledger_directory)
#'
#' # Using French account model with date range
#' get_assets(
#'   ledger_file = my_ledger_directory,
#'   min_date = "2024-01-01",
#'   max_date = "2024-12-31",
#'   accounts_plan = accounts_model_fr
#' )
#' }
#'
#' @autoglobal
#' @export
get_assets <- function(
    ledger_file = NULL,
    min_date = NULL,
    max_date = NULL,
    accounts_plan = accounts_model_en) {
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

    sum_accounts(my_ledger_filtered) |>
      filter(account_base_category == 1L) |>
      left_join(
        accounts_plan |>
          rename(
            account_description_intermediate = account_description,
            intermediate_category = account_number
          ),
        by = join_by(intermediate_category)
      )
  }
}
