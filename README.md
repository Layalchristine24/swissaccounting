
<!-- README.md is generated from README.Rmd. Please edit that file -->

# swissaccounting

<!-- badges: start -->

<!-- badges: end -->

The goal of swissaccounting is to provide a set of functions to help
with accounting tasks in Switzerland.

## Installation

You can install the development version of swissaccounting from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Layalchristine24/swissaccounting")
```

or

``` r
# install.packages("pak")
pak::pak("Layalchristine24/swissaccounting")
```

## Example

This is a basic example which shows you how to get the accounts needed
to create a balance sheet from a ledger file. The example demonstrates a
realistic small business scenario with capital contributions, expenses
(accrued and direct), and bank interest income.

``` r
library(swissaccounting)
# Create sample ledger file for documentation purposes

# Create directory if it doesn't exist
if (!dir.exists(file.path(here::here(), "documents", "ledger"))) {
  fs::dir_create(file.path(here::here(), "documents", "ledger"))
}

ledger_file <- file.path(here::here(), "documents", "ledger", "sample-ledger.csv")

# Create sample ledger entries
if (!file.exists(file.path(here::here(), "documents", "ledger"))) {
  fs::file_create(ledger_file)
}

# 1. Capital contribution - owner deposits cash into bank
add_ledger_entry(
  date = "2024-01-15",
  language = "en",
  descr = "Capital contribution",
  debit_account = 1020,
  amount = 500,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 1 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>


add_ledger_entry(
  date = "2024-01-15",
  language = "en",
  descr = "Capital contribution",
  credit_account = 2820,
  amount = 500,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 2 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> 2 2024-01-15     2              1 Capital contribu…            NA           2820
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

# 2. Software subscription expense (accrued, not yet paid)
add_ledger_entry(
  date = "2024-01-31",
  language = "en",
  descr = "Software subscription",
  debit_account = 6570,
  amount = 50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 3 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> 2 2024-01-15     2              1 Capital contribu…            NA           2820
#> 3 2024-01-31     3              2 Software subscri…          6570             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

add_ledger_entry(
  date = "2024-01-31",
  language = "en",
  descr = "Software subscription",
  credit_account = 2300,
  amount = 50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 4 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> 2 2024-01-15     2              1 Capital contribu…            NA           2820
#> 3 2024-01-31     3              2 Software subscri…          6570             NA
#> 4 2024-01-31     4              3 Software subscri…            NA           2300
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

# 3. Another capital contribution
add_ledger_entry(
  date = "2024-02-15",
  language = "en",
  descr = "Capital contribution",
  debit_account = 1020,
  amount = 500,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 5 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> 2 2024-01-15     2              1 Capital contribu…            NA           2820
#> 3 2024-01-31     3              2 Software subscri…          6570             NA
#> 4 2024-01-31     4              3 Software subscri…            NA           2300
#> 5 2024-02-15     5              4 Capital contribu…          1020             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

add_ledger_entry(
  date = "2024-02-15",
  language = "en",
  descr = "Capital contribution",
  credit_account = 2820,
  amount = 500,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 6 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> 2 2024-01-15     2              1 Capital contribu…            NA           2820
#> 3 2024-01-31     3              2 Software subscri…          6570             NA
#> 4 2024-01-31     4              3 Software subscri…            NA           2300
#> 5 2024-02-15     5              4 Capital contribu…          1020             NA
#> 6 2024-02-15     6              5 Capital contribu…            NA           2820
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

# 4. Pay the accrued expense
add_ledger_entry(
  date = "2024-02-28",
  language = "en",
  descr = "Pay software subscription",
  debit_account = 2300,
  amount = 50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 7 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> 2 2024-01-15     2              1 Capital contribu…            NA           2820
#> 3 2024-01-31     3              2 Software subscri…          6570             NA
#> 4 2024-01-31     4              3 Software subscri…            NA           2300
#> 5 2024-02-15     5              4 Capital contribu…          1020             NA
#> 6 2024-02-15     6              5 Capital contribu…            NA           2820
#> 7 2024-02-28     7              6 Pay software sub…          2300             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

add_ledger_entry(
  date = "2024-02-28",
  language = "en",
  descr = "Pay software subscription",
  credit_account = 1020,
  amount = 50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 8 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> 2 2024-01-15     2              1 Capital contribu…            NA           2820
#> 3 2024-01-31     3              2 Software subscri…          6570             NA
#> 4 2024-01-31     4              3 Software subscri…            NA           2300
#> 5 2024-02-15     5              4 Capital contribu…          1020             NA
#> 6 2024-02-15     6              5 Capital contribu…            NA           2820
#> 7 2024-02-28     7              6 Pay software sub…          2300             NA
#> 8 2024-02-28     8              7 Pay software sub…            NA           1020
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

# 5. Monthly software expense (direct payment from bank)
add_ledger_entry(
  date = "2024-03-01",
  language = "en",
  descr = "Software subscription",
  debit_account = 6570,
  amount = 50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 9 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-15     1             NA Capital contribu…          1020             NA
#> 2 2024-01-15     2              1 Capital contribu…            NA           2820
#> 3 2024-01-31     3              2 Software subscri…          6570             NA
#> 4 2024-01-31     4              3 Software subscri…            NA           2300
#> 5 2024-02-15     5              4 Capital contribu…          1020             NA
#> 6 2024-02-15     6              5 Capital contribu…            NA           2820
#> 7 2024-02-28     7              6 Pay software sub…          2300             NA
#> 8 2024-02-28     8              7 Pay software sub…            NA           1020
#> 9 2024-03-01     9              8 Software subscri…          6570             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

add_ledger_entry(
  date = "2024-03-01",
  language = "en",
  descr = "Software subscription",
  credit_account = 1020,
  amount = 50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 10 × 9
#>    date          id counterpart_id description      debit_account credit_account
#>    <date>     <int>          <int> <chr>                    <int>          <int>
#>  1 2024-01-15     1             NA Capital contrib…          1020             NA
#>  2 2024-01-15     2              1 Capital contrib…            NA           2820
#>  3 2024-01-31     3              2 Software subscr…          6570             NA
#>  4 2024-01-31     4              3 Software subscr…            NA           2300
#>  5 2024-02-15     5              4 Capital contrib…          1020             NA
#>  6 2024-02-15     6              5 Capital contrib…            NA           2820
#>  7 2024-02-28     7              6 Pay software su…          2300             NA
#>  8 2024-02-28     8              7 Pay software su…            NA           1020
#>  9 2024-03-01     9              8 Software subscr…          6570             NA
#> 10 2024-03-01    10              9 Software subscr…            NA           1020
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

# 6. Bank interest received
add_ledger_entry(
  date = "2024-03-31",
  language = "en",
  descr = "Bank interest",
  debit_account = 1020,
  amount = 0.50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 11 × 9
#>    date          id counterpart_id description      debit_account credit_account
#>    <date>     <int>          <int> <chr>                    <int>          <int>
#>  1 2024-01-15     1             NA Capital contrib…          1020             NA
#>  2 2024-01-15     2              1 Capital contrib…            NA           2820
#>  3 2024-01-31     3              2 Software subscr…          6570             NA
#>  4 2024-01-31     4              3 Software subscr…            NA           2300
#>  5 2024-02-15     5              4 Capital contrib…          1020             NA
#>  6 2024-02-15     6              5 Capital contrib…            NA           2820
#>  7 2024-02-28     7              6 Pay software su…          2300             NA
#>  8 2024-02-28     8              7 Pay software su…            NA           1020
#>  9 2024-03-01     9              8 Software subscr…          6570             NA
#> 10 2024-03-01    10              9 Software subscr…            NA           1020
#> 11 2024-03-31    11             10 Bank interest             1020             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

add_ledger_entry(
  date = "2024-03-31",
  language = "en",
  descr = "Bank interest",
  credit_account = 6950,
  amount = 0.50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 12 × 9
#>    date          id counterpart_id description      debit_account credit_account
#>    <date>     <int>          <int> <chr>                    <int>          <int>
#>  1 2024-01-15     1             NA Capital contrib…          1020             NA
#>  2 2024-01-15     2              1 Capital contrib…            NA           2820
#>  3 2024-01-31     3              2 Software subscr…          6570             NA
#>  4 2024-01-31     4              3 Software subscr…            NA           2300
#>  5 2024-02-15     5              4 Capital contrib…          1020             NA
#>  6 2024-02-15     6              5 Capital contrib…            NA           2820
#>  7 2024-02-28     7              6 Pay software su…          2300             NA
#>  8 2024-02-28     8              7 Pay software su…            NA           1020
#>  9 2024-03-01     9              8 Software subscr…          6570             NA
#> 10 2024-03-01    10              9 Software subscr…            NA           1020
#> 11 2024-03-31    11             10 Bank interest             1020             NA
#> 12 2024-03-31    12             11 Bank interest               NA           6950
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

# 7. Another software expense
add_ledger_entry(
  date = "2024-04-01",
  language = "en",
  descr = "Software subscription",
  debit_account = 6570,
  amount = 50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 13 × 9
#>    date          id counterpart_id description      debit_account credit_account
#>    <date>     <int>          <int> <chr>                    <int>          <int>
#>  1 2024-01-15     1             NA Capital contrib…          1020             NA
#>  2 2024-01-15     2              1 Capital contrib…            NA           2820
#>  3 2024-01-31     3              2 Software subscr…          6570             NA
#>  4 2024-01-31     4              3 Software subscr…            NA           2300
#>  5 2024-02-15     5              4 Capital contrib…          1020             NA
#>  6 2024-02-15     6              5 Capital contrib…            NA           2820
#>  7 2024-02-28     7              6 Pay software su…          2300             NA
#>  8 2024-02-28     8              7 Pay software su…            NA           1020
#>  9 2024-03-01     9              8 Software subscr…          6570             NA
#> 10 2024-03-01    10              9 Software subscr…            NA           1020
#> 11 2024-03-31    11             10 Bank interest             1020             NA
#> 12 2024-03-31    12             11 Bank interest               NA           6950
#> 13 2024-04-01    13             12 Software subscr…          6570             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

add_ledger_entry(
  date = "2024-04-01",
  language = "en",
  descr = "Software subscription",
  credit_account = 1020,
  amount = 50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 14 × 9
#>    date          id counterpart_id description      debit_account credit_account
#>    <date>     <int>          <int> <chr>                    <int>          <int>
#>  1 2024-01-15     1             NA Capital contrib…          1020             NA
#>  2 2024-01-15     2              1 Capital contrib…            NA           2820
#>  3 2024-01-31     3              2 Software subscr…          6570             NA
#>  4 2024-01-31     4              3 Software subscr…            NA           2300
#>  5 2024-02-15     5              4 Capital contrib…          1020             NA
#>  6 2024-02-15     6              5 Capital contrib…            NA           2820
#>  7 2024-02-28     7              6 Pay software su…          2300             NA
#>  8 2024-02-28     8              7 Pay software su…            NA           1020
#>  9 2024-03-01     9              8 Software subscr…          6570             NA
#> 10 2024-03-01    10              9 Software subscr…            NA           1020
#> 11 2024-03-31    11             10 Bank interest             1020             NA
#> 12 2024-03-31    12             11 Bank interest               NA           6950
#> 13 2024-04-01    13             12 Software subscr…          6570             NA
#> 14 2024-04-01    14             13 Software subscr…            NA           1020
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>

balance_docs <-
  get_balance_accounts(
    ledger_file = ledger_file,
    min_date = "2024-01-01",
    max_date = "2024-12-31",
    language = "en"
  )

balance_docs$balance_accounts
#> # A tibble: 3 × 6
#>   account_base_category high_category intermediate_category account_number
#>                   <int>         <int>                 <int>          <int>
#> 1                     1            10                   102           1020
#> 2                     2            28                   282           2820
#> 3                     2            28                   289           2891
#> # ℹ 2 more variables: account_description <chr>, sum_amounts <dbl>

balance_docs$total
#> # A tibble: 2 × 2
#>   account_base_category total
#>                   <int> <dbl>
#> 1                     1  850.
#> 2                     2 -850.
```

## Simplifying with the add_transaction() Function

For cleaner code when adding many transactions, the `swissaccounting`
package provides the `add_transaction()` function that eliminates
repetitive arguments:

``` r
ledger_file <- file.path(here::here(), "documents", "ledger", "transactions-ledger.csv")

# Create transaction ledger entries
if (!file.exists(file.path(here::here(), "documents", "ledger"))) {
  fs::file_create(ledger_file)
}

# Add transactions using the built-in add_transaction() function
# Note: add_transaction() creates paired entries (debit + credit) automatically
# This example produces the exact same ledger as the add_ledger_entry() example above

# 1. Capital contribution - owner deposits cash into bank
add_transaction(
  ledger_file = ledger_file,
  date = "2024-01-15",
  descr = "Capital contribution",
  debit_account = 1020,
  credit_account = 2820,
  amount = 500
)

# 2. Software subscription expense (accrued, not yet paid)
add_transaction(
  ledger_file = ledger_file,
  date = "2024-01-31",
  descr = "Software subscription",
  debit_account = 6570,
  credit_account = 2300,
  amount = 50
)

# 3. Another capital contribution
add_transaction(
  ledger_file = ledger_file,
  date = "2024-02-15",
  descr = "Capital contribution",
  debit_account = 1020,
  credit_account = 2820,
  amount = 500
)

# 4. Pay the accrued expense
add_transaction(
  ledger_file = ledger_file,
  date = "2024-02-28",
  descr = "Pay software subscription",
  debit_account = 2300,
  credit_account = 1020,
  amount = 50
)

# 5. Monthly software expense (direct payment from bank)
add_transaction(
  ledger_file = ledger_file,
  date = "2024-03-01",
  descr = "Software subscription",
  debit_account = 6570,
  credit_account = 1020,
  amount = 50
)

# 6. Bank interest received (account 6950 = Financial Income)
add_transaction(
  ledger_file = ledger_file,
  date = "2024-03-31",
  descr = "Bank interest",
  debit_account = 1020,
  credit_account = 6950,
  amount = 0.50
)

# 7. Another software expense
add_transaction(
  ledger_file = ledger_file,
  date = "2024-04-01",
  descr = "Software subscription",
  debit_account = 6570,
  credit_account = 1020,
  amount = 50
)
```

**Benefits of add_transaction()**:

- **Package-level function**: Available to all users via
  `add_transaction()`
- **Code reduction**: From 10 lines per transaction to just 6 lines
  (with named arguments)
- **Explicit argument names**: Prevents debit/credit confusion
- **Zero duplication**: File path passed as parameter
- **Exact reproducibility**: Same ledger output as manual calls
- **Maintainability**: Package function is tested and versioned
- **Clear pattern**: Function shows the debit/credit relationship
  explicitly

This function maintains the exact same behavior as manual
`add_ledger_entry()` calls: - First entry uses `export_csv = TRUE`
without `import_csv` - Second entry uses both `import_csv = TRUE` and
`export_csv = TRUE` - Automatic counterpart_id linking works correctly

## Year-End Closing and Opening Balances

### Why Year-End Closing is Needed

When working with multi-year accounting data, you need a formal
mechanism to: 1. **Close profit and loss accounts** at fiscal year-end
2. **Transfer the net result** to equity accounts 3. **Create opening
balances** for the new fiscal year 4. **Enable accurate multi-year
queries**

Without this mechanism, querying just one fiscal year (e.g., 2025-01-01
to 2025-12-31) will miss the opening balances from the previous year,
resulting in incorrect financial statements.

### Swiss Accounting Standards Compliance

The swissaccounting package follows **Swiss GAAP** (Generally Accepted
Accounting Principles) for year-end closing:

- **Account 9200**: Current Year Profit/Loss - standard Swiss account
- **Account 9100**: Opening Balance - custom extension (permitted by
  Swiss standards)
- **Account 2891**: Balance Sheet Profit/Loss - intermediate transfer
  account
- **Double-entry bookkeeping**: All entries maintain the fundamental
  accounting equation

### The Problem Illustrated

**Scenario**: You have transactions from 2024 and 2025 in your ledger.

**Without closing/opening entries**:

``` r
# Query 2024 only (2024-01-01 to 2024-12-31)
get_balance_accounts(ledger_file, "2024-01-01", "2024-12-31", "en")
# Result: 256.45 CHF ✓

# Query 2025 only (2025-01-01 to 2025-12-31)
get_balance_accounts(ledger_file, "2025-01-01", "2025-12-31", "en")
# Result: 181.55 CHF ✗ (WRONG - missing 256.45 opening balance)

# Query both years (2024-01-01 to 2025-12-31)
get_balance_accounts(ledger_file, "2024-01-01", "2025-12-31", "en")
# Result: 438.00 CHF ✓
```

**With closing/opening entries**:

``` r
# After running close_fiscal_year() and create_opening_balances()

# Query 2025 only (2025-01-01 to 2025-12-31)
get_balance_accounts(ledger_file, "2025-01-01", "2025-12-31", "en")
# Result: 438.00 CHF ✓ (CORRECT - includes 256.45 opening + 181.55 from 2025)
```

### Step-by-Step Workflow

#### 1. Close the Fiscal Year

At the end of your fiscal year (e.g., 2024-12-31), run:

``` r
library(swissaccounting)

ledger_file <- "path/to/your/ledger.csv"

# Close fiscal year 2024
close_fiscal_year(
  ledger_file = ledger_file,
  closing_date = "2024-12-31",
  language = "en"  # Options: "en", "fr", "de"
)
```

**What this does**: 1. Closes all income accounts (category 3) to
account 9200 2. Closes all expense accounts (categories 4-8) to account
9200 3. Transfers account 9200 to account 2891 (Balance Sheet
Profit/Loss) 4. Transfers account 2891 to account 2970 (Carried Forward
Profit/Loss) or your specified equity account 5. Creates permanent
ledger entries dated 2024-12-31 with account_type = “Closing”

**Parameters**: - `ledger_file`: Path to your ledger CSV file -
`closing_date`: Date of fiscal year-end (e.g., “2024-12-31”) -
`language`: Language for account descriptions (“en”, “fr”, or “de”) -
auto-detected if not specified - `transfer_to_account`: Equity account
for final transfer (default: 2970L) - `overwrite`: Allow overwriting
existing closing entries (default: FALSE)

#### 2. Create Opening Balances

At the start of your new fiscal year (e.g., 2025-01-01), run:

``` r
# Create opening balances for 2025
create_opening_balances(
  ledger_file = ledger_file,
  opening_date = "2025-01-01",
  language = "en"  # Options: "en", "fr", "de"
)
```

**What this does**: 1. Reads all balance sheet accounts (categories 1-2)
from the previous closing date 2. Creates opening balance entries dated
2025-01-01 3. Uses account 9100 (Opening Balance) as the counterpart
account 4. Maintains original account types (Asset/Liability) for proper
balance calculation

**Parameters**: - `ledger_file`: Path to your ledger CSV file -
`opening_date`: Date of new fiscal year start (e.g., “2025-01-01”) -
`previous_closing_date`: Date of previous fiscal year-end
(auto-calculated as opening_date - 1 day if not specified) - `language`:
Language for account descriptions (“en”, “fr”, or “de”) - auto-detected
if not specified - `overwrite`: Allow overwriting existing opening
entries (default: FALSE)

#### 3. Generate Financial Statements

After closing and opening entries are created, generate statements for
any period:

``` r
# Balance sheet for 2025 only (now includes opening balances)
balance_2025 <- get_balance_accounts(
  ledger_file = ledger_file,
  min_date = "2025-01-01",
  max_date = "2025-12-31",
  language = "en"
)

# Income statement for 2025
income_2025 <- get_income_statement(
  ledger_file = ledger_file,
  min_date = "2025-01-01",
  max_date = "2025-12-31",
  language = "en"
)

# Operating result for 2025
operating_2025 <- get_operating_result(
  ledger_file = ledger_file,
  min_date = "2025-01-01",
  max_date = "2025-12-31",
  language = "en"
)
```

### Complete Example

``` r
library(swissaccounting)

ledger_file <- "documents/ledger/my-ledger.csv"

# ===================================
# YEAR-END 2024
# ===================================

# Step 1: Close fiscal year 2024
close_fiscal_year(
  ledger_file = ledger_file,
  closing_date = "2024-12-31",
  language = "en"
)

# Step 2: Create opening balances for 2025
create_opening_balances(
  ledger_file = ledger_file,
  opening_date = "2025-01-01",
  language = "en"
)

# ===================================
# VERIFY RESULTS
# ===================================

# Before closing/opening:
# Query 2025 only → 181.55 CHF (missing opening balance)

# After closing/opening:
# Query 2025 only → 438.00 CHF ✓ (includes 256.45 opening + 181.55 from 2025)

balance_2025 <- get_balance_accounts(
  ledger_file = ledger_file,
  min_date = "2025-01-01",
  max_date = "2025-12-31",
  language = "en"
)

print(balance_2025$total)
# Expected: 438.00 CHF
```

### Multilingual Support

All functions support English, French, and German:

``` r
# French
close_fiscal_year(ledger_file, "2024-12-31", language = "fr")
# Account descriptions will be in French

# German
close_fiscal_year(ledger_file, "2024-12-31", language = "de")
# Account descriptions will be in German

# English
close_fiscal_year(ledger_file, "2024-12-31", language = "en")
# Account descriptions will be in English
```

If you don’t specify a language, the functions will automatically detect
the language used in your existing ledger.

### Troubleshooting

#### Duplicate Closing Entries

**Error**: “Closing entries already exist for 2024-12-31. Use overwrite
= TRUE to replace.”

**Solution**: You’ve already run `close_fiscal_year()` for this date.
Either: - Set `overwrite = TRUE` to recreate the entries - Skip this
step if closing was already done correctly

``` r
# Overwrite existing closing
close_fiscal_year(ledger_file, "2024-12-31", language = "en", overwrite = TRUE)
```

#### Duplicate Opening Entries

**Error**: “Opening entries already exist for 2025-01-01. Use overwrite
= TRUE to replace.”

**Solution**: Similar to closing entries, set `overwrite = TRUE` or skip
if already done.

``` r
# Overwrite existing opening
create_opening_balances(ledger_file, "2025-01-01", language = "en", overwrite = TRUE)
```

#### Account 9100 Not Found

**Error**: “Account 9100 (Opening Balance) not found in account model.”

**Solution**: Update your swissaccounting package to the latest version.
Account 9100 was added in the latest version.

``` r
# Update package
pak::pak("Layalchristine24/swissaccounting")
```

#### Incorrect Balance After Opening

**Issue**: The 2025 balance doesn’t match expectations after creating
opening entries.

**Solution**: Verify that: 1. You ran `close_fiscal_year()` for
2024-12-31 first 2. You ran `create_opening_balances()` for 2025-01-01
second 3. There are no duplicate entries in your ledger 4. The closing
date and opening date are sequential (2024-12-31 → 2025-01-01)

### Important Notes

1.  **Run once per fiscal year**: Closing and opening functions create
    permanent ledger entries. Don’t run them multiple times unless you
    use `overwrite = TRUE`.

2.  **ID management**: The functions automatically assign the next
    available ID to new entries. Make sure your ledger IDs are
    sequential.

3.  **Filtered from balance sheets**: Closing entries (account_type =
    “Closing”) are automatically filtered out from balance sheet
    calculations.

4.  **Double-entry integrity**: All entries maintain double-entry
    bookkeeping. Each transaction has a debit and credit entry with the
    same counterpart_id.

5.  **Backup your ledger**: Before running closing/opening functions on
    production data, create a backup of your ledger CSV file.

### Advanced Usage

#### Custom Equity Account

Transfer the year-end result to a different equity account:

``` r
close_fiscal_year(
  ledger_file = ledger_file,
  closing_date = "2024-12-31",
  language = "en",
  transfer_to_account = 2800L  # Use account 2800 instead of 2850
)
```

#### Specify Previous Closing Date

Explicitly set the previous closing date for opening balances:

``` r
create_opening_balances(
  ledger_file = ledger_file,
  opening_date = "2025-01-01",
  previous_closing_date = "2024-12-31",
  language = "en"
)
```

#### Check Before Running

Verify balances before creating closing/opening entries:

``` r
# Check 2024 balance before closing
balance_2024 <- get_balance_accounts(ledger_file, "2024-01-01", "2024-12-31", "en")
print(balance_2024$total)

# Run closing
close_fiscal_year(ledger_file, "2024-12-31", "en")

# Verify closing worked correctly
income_2024 <- get_income_statement(ledger_file, "2024-01-01", "2024-12-31", "en")
print(income_2024)  # Should now show P&L accounts are closed
```
