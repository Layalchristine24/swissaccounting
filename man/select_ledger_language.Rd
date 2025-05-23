% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{select_ledger_language}
\alias{select_ledger_language}
\title{Select Language for Ledger Accounts}
\usage{
select_ledger_language(ledger_data, language)
}
\arguments{
\item{ledger_data}{data.frame A ledger data frame with account information}

\item{language}{character Language code for account descriptions. One of "en",
"fr", "de"}
}
\value{
data.frame A data frame with columns:
\itemize{
\item{account_number}{Integer. The account identifier}
\item{account_type}{Character. Account type in selected language}
\item{account_description}{Character. Account description in selected
language}
}
}
\description{
Filters the consolidated accounting plans to return account descriptions in the
specified language, removing language suffixes from column names. This function
is used internally to support multi-language account descriptions in reports.
}
\examples{
\dontrun{
# Get French account descriptions
french_accounts <- select_ledger_language(my_ledger, "fr")

# Get German account descriptions
german_accounts <- select_ledger_language(my_ledger, "de")
}

}
\seealso{
\code{\link{consolidate_accounting_plans}} for combining language plans
}
