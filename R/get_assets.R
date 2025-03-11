#' Calculate Total Assets by Account Description
#'
#' @description
#' This function reads a ledger file and calculates the sum of assets for each
#' account description, considering both debit and credit entries that start with
#' '1'.
#'
#' @param ledger_file Path to the CSV ledger file
#' @param accounts_plan Account plan to use for mapping descriptions. Defaults to
#'   accounts_model_en
#'
#' @return A data frame containing account descriptions and their total asset
#'   values, joined with the corresponding account plan descriptions
#'
#' @examples
#' \dontrun{
#' # Using default English account model
#' get_assets(ledger_file = my_ledger_directory)
#'
#' # Using French account model
#' get_assets(
#'   ledger_file = my_ledger_directory, 
#'   accounts_plan = accounts_model_fr
#' )
#' }
#'
#' @autoglobal
#' @export
get_assets <- function(
    ledger_file = TRUE,
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
    sum_accounts(my_ledger) |>
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
