% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{get_balance_category}
\alias{get_balance_category}
\title{Get Balance Sheet Category Details}
\usage{
get_balance_category(
  ledger_data,
  target_language_ledger,
  balance_category = NULL
)
}
\arguments{
\item{ledger_data}{data.frame A ledger data frame containing accounting entries}

\item{target_language_ledger}{data.frame Account descriptions in the target
language, as returned by select_ledger_language()}

\item{balance_category}{character The balance sheet category to process. Must be
either "assets" or "liabilities"}
}
\value{
data.frame A data frame containing:
\item{account_base_category}{Integer. First digit of account number (1 or 2)}
\item{high_category}{Integer. First two digits of account number}
\item{intermediate_category}{Integer. First three digits of account number}
\item{account_number}{Integer. Full account number}
\item{account_description}{Character. Account description in target language}
\item{sum_amounts}{Numeric. Total values for each account}
\item{account_description_intermediate}{Character. Intermediate category
description}
}
\description{
Calculates and categorizes balance sheet entries for either assets or
liabilities, including intermediate category descriptions in the specified
language.
}
\examples{
\dontrun{
# Get French language assets
french_ledger <- select_ledger_language(my_ledger, "fr")
assets <- get_balance_category(
  ledger_data = my_ledger,
  target_language_ledger = french_ledger,
  balance_category = "assets"
)
}

}
