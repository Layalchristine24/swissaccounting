# Type enforcement functions ----

#' Ensure type stability for data frame columns
#'
#' Casts columns in a data frame to specified types, with error handling and
#' informative error messages. This function ensures type stability by converting
#' columns to their expected types.
#'
#' @param .data A data frame whose columns should be cast to specified types.
#' @param ... Named arguments specifying the desired type for each column.
#'   The names should match column names in `.data`, and the values should be
#'   prototype objects that define the target type (e.g., `character()`, `integer()`,
#'   `numeric()`, `logical()`, or more complex types like `factor(levels = c("a", "b"))`).
#' @param .default Optional default type to apply to columns not explicitly specified
#'   in `...`. Can be a prototype object or an expression that evaluates to one.
#' @param .call The call environment for error reporting (used internally).
#'
#' @return A tibble with columns cast to the specified types. Only the columns
#'   mentioned in `...` (and those covered by `.default` if provided) are returned.
#'
#' @export
#' @autoglobal
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   x = c("1", "2", "3"),
#'   y = c("TRUE", "FALSE", "TRUE"),
#'   z = 1:3
#' )
#'
#' # Specify types for specific columns
#' ensure_type(df, x = integer(), y = logical())
#'
#' # Use a default type for unspecified columns
#' ensure_type(df, x = integer(), .default = character())
#' }
ensure_type <- function(
  .data,
  ...,
  .default = NULL,
  .call = rlang::caller_env()
) {
  rlang::try_fetch(
    try_ensure_type(.data, ..., .default = {{ .default }}),
    error = function(e) {
      cli_abort(
        call = .call,
        "Type stability violated",
        parent = e
      )
    }
  )
}

#' Try to ensure type stability for data frame columns
#'
#' Internal function that attempts to cast columns to specified types.
#' This is the workhorse function called by `ensure_type()`.
#'
#' @param .data A data frame whose columns should be cast to specified types.
#' @param ... Named arguments specifying the desired type for each column.
#' @param .default Optional default type to apply to unspecified columns.
#' @param .call The call environment for error reporting.
#'
#' @return A tibble with columns cast to the specified types.
#'
#' @keywords internal
#' @autoglobal
try_ensure_type <- function(
  .data,
  ...,
  .default = NULL,
  .call = rlang::caller_env()
) {
  default <- rlang::enquo(.default)
  types <- tibble(...)
  names <- names(types)

  if (!rlang::quo_is_null(default)) {
    missing <- setdiff(colnames(.data), names)
    if (length(missing) > 0) {
      default_type <- rlang::eval_tidy(default)
      for (col in missing) {
        types[[col]] <- default_type
      }
      names <- c(names, missing)
    }
  }

  if (!all(names %in% names(.data))) {
    cli_abort(
      call = .call,
      c(
        "Columns missing",
        i = "Columns {.var {setdiff(names, names(.data))}} not found in data"
      )
    )
  }

  out <- .data[names]
  for (i in seq_along(out)) {
    out[[i]] <- vec_cast(
      out[[i]],
      types[[i]],
      x_arg = names[[i]],
      call = .call
    )
  }

  out |>
    as_tibble()
}
