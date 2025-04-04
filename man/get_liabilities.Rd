% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_liabilities.R
\name{get_liabilities}
\alias{get_liabilities}
\title{Calculate Total Liabilities by Account Description}
\usage{
get_liabilities(
  ledger_file = NULL,
  min_date = NULL,
  max_date = NULL,
  language = "fr"
)
}
\arguments{
\item{ledger_file}{character Path to the CSV ledger file}

\item{min_date}{character,Date Optional. Minimum date to filter transactions
(format: "YYYY-MM-DD")}

\item{max_date}{character,Date Optional. Maximum date to filter transactions
(format: "YYYY-MM-DD")}

\item{language}{character Language code for account descriptions. One of "en",
"fr", "de". Defaults to "fr"}
}
\value{
data.frame A data frame containing:
\item{account_base_category}{Integer. First digit of account number (2)}
\item{high_category}{Integer. First two digits of account number}
\item{intermediate_category}{Integer. First three digits of account number}
\item{account_number}{Integer. Full account number}
\item{account_description}{Character. Account description in selected
language}
\item{sum_amounts}{Numeric. Total liability values}
\item{account_description_intermediate}{Character. Intermediate level
description}
}
\description{
Reads a ledger file, filters by date range if specified, and calculates the sum
of liabilities for each account description in the selected language. This is a
convenience wrapper around get_balance_side() for liabilities.
}
\examples{
\dontrun{
# Using French account descriptions (default)
get_liabilities(ledger_file = my_ledger_directory)

# Using German account descriptions with date range
get_liabilities(
  ledger_file = my_ledger_directory,
  min_date = "2024-01-01",
  max_date = "2024-12-31",
  language = "de"
)
}

}
\seealso{
\code{\link{get_balance_side}} for the underlying implementation
}
