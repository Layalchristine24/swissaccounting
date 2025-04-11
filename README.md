
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

## Example

This is a basic example which shows you how to get the accounts needed
to create a balance sheet from a ledger file.

``` r
library(swissaccounting)
# Create sample ledger file for documentation purposes

# Create directory if it doesn't exist
if (!dir.exists(file.path(here::here(), "documents", "ledger"))) {
  fs::dir_create(file.path(here::here(), "documents", "ledger"))
}

# Create sample ledger entries
ledger_file <- file.path(here::here(), "documents", "ledger", "sample-ledger.csv")

# Initial cash deposit
add_ledger_entry(
  date = "2024-01-01",
  descr = "Initial cash deposit",
  debit_account = 1020,
  amount = 10000,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 1 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

# Office supplies purchase
add_ledger_entry(
  date = "2024-01-15",
  descr = "Office supplies",
  debit_account = 4000,
  amount = 500,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 2 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> 2 2024-01-15     2              2 Office supplies            4000             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

add_ledger_entry(
  date = "2024-01-15",
  counterpart_id = 2L,
  descr = "Office supplies payment",
  credit_account = 1020,
  amount = 500,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 3 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> 2 2024-01-15     2              2 Office supplies            4000             NA
#> 3 2024-01-15     3              2 Office supplies …            NA           1020
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

# Monthly rent
add_ledger_entry(
  date = "2024-01-31",
  descr = "Monthly rent",
  debit_account = 6000,
  amount = 2000,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 4 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> 2 2024-01-15     2              2 Office supplies            4000             NA
#> 3 2024-01-15     3              2 Office supplies …            NA           1020
#> 4 2024-01-31     4              4 Monthly rent               6000             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

add_ledger_entry(
  date = "2024-01-31",
  counterpart_id = 4L,
  descr = "Monthly rent payment",
  credit_account = 1020,
  amount = 2000,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 5 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> 2 2024-01-15     2              2 Office supplies            4000             NA
#> 3 2024-01-15     3              2 Office supplies …            NA           1020
#> 4 2024-01-31     4              4 Monthly rent               6000             NA
#> 5 2024-01-31     5              4 Monthly rent pay…            NA           1020
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

# Service revenue
add_ledger_entry(
  date = "2024-02-15",
  descr = "Service revenue",
  debit_account = 1020,
  amount = 3000,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 6 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> 2 2024-01-15     2              2 Office supplies            4000             NA
#> 3 2024-01-15     3              2 Office supplies …            NA           1020
#> 4 2024-01-31     4              4 Monthly rent               6000             NA
#> 5 2024-01-31     5              4 Monthly rent pay…            NA           1020
#> 6 2024-02-15     6              6 Service revenue            1020             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

add_ledger_entry(
  date = "2024-02-15",
  counterpart_id = 6L,
  descr = "Service revenue",
  credit_account = 3000,
  amount = 3000,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 7 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> 2 2024-01-15     2              2 Office supplies            4000             NA
#> 3 2024-01-15     3              2 Office supplies …            NA           1020
#> 4 2024-01-31     4              4 Monthly rent               6000             NA
#> 5 2024-01-31     5              4 Monthly rent pay…            NA           1020
#> 6 2024-02-15     6              6 Service revenue            1020             NA
#> 7 2024-02-15     7              6 Service revenue              NA           3000
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

# Equipment purchase
add_ledger_entry(
  date = "2024-03-01",
  descr = "Computer equipment",
  debit_account = 1000,
  amount = 1500,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 8 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> 2 2024-01-15     2              2 Office supplies            4000             NA
#> 3 2024-01-15     3              2 Office supplies …            NA           1020
#> 4 2024-01-31     4              4 Monthly rent               6000             NA
#> 5 2024-01-31     5              4 Monthly rent pay…            NA           1020
#> 6 2024-02-15     6              6 Service revenue            1020             NA
#> 7 2024-02-15     7              6 Service revenue              NA           3000
#> 8 2024-03-01     8              8 Computer equipme…          1000             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

add_ledger_entry(
  date = "2024-03-01",
  counterpart_id = 8L,
  descr = "Computer equipment payment",
  credit_account = 1020,
  amount = 1500,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 9 × 9
#>   date          id counterpart_id description       debit_account credit_account
#>   <date>     <int>          <int> <chr>                     <int>          <int>
#> 1 2024-01-01     1              1 Initial cash dep…          1020             NA
#> 2 2024-01-15     2              2 Office supplies            4000             NA
#> 3 2024-01-15     3              2 Office supplies …            NA           1020
#> 4 2024-01-31     4              4 Monthly rent               6000             NA
#> 5 2024-01-31     5              4 Monthly rent pay…            NA           1020
#> 6 2024-02-15     6              6 Service revenue            1020             NA
#> 7 2024-02-15     7              6 Service revenue              NA           3000
#> 8 2024-03-01     8              8 Computer equipme…          1000             NA
#> 9 2024-03-01     9              8 Computer equipme…            NA           1020
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

# Bank interest
add_ledger_entry(
  date = "2024-03-31",
  descr = "Bank interest",
  debit_account = 1020,
  amount = 25.50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 10 × 9
#>    date          id counterpart_id description      debit_account credit_account
#>    <date>     <int>          <int> <chr>                    <int>          <int>
#>  1 2024-01-01     1              1 Initial cash de…          1020             NA
#>  2 2024-01-15     2              2 Office supplies           4000             NA
#>  3 2024-01-15     3              2 Office supplies…            NA           1020
#>  4 2024-01-31     4              4 Monthly rent              6000             NA
#>  5 2024-01-31     5              4 Monthly rent pa…            NA           1020
#>  6 2024-02-15     6              6 Service revenue           1020             NA
#>  7 2024-02-15     7              6 Service revenue             NA           3000
#>  8 2024-03-01     8              8 Computer equipm…          1000             NA
#>  9 2024-03-01     9              8 Computer equipm…            NA           1020
#> 10 2024-03-31    10             10 Bank interest             1020             NA
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r

add_ledger_entry(
  date = "2024-03-31",
  counterpart_id = 10L,
  descr = "Bank interest",
  credit_account = 2850,
  amount = 25.50,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
#> # A tibble: 11 × 9
#>    date          id counterpart_id description      debit_account credit_account
#>    <date>     <int>          <int> <chr>                    <int>          <int>
#>  1 2024-01-01     1              1 Initial cash de…          1020             NA
#>  2 2024-01-15     2              2 Office supplies           4000             NA
#>  3 2024-01-15     3              2 Office supplies…            NA           1020
#>  4 2024-01-31     4              4 Monthly rent              6000             NA
#>  5 2024-01-31     5              4 Monthly rent pa…            NA           1020
#>  6 2024-02-15     6              6 Service revenue           1020             NA
#>  7 2024-02-15     7              6 Service revenue             NA           3000
#>  8 2024-03-01     8              8 Computer equipm…          1000             NA
#>  9 2024-03-01     9              8 Computer equipm…            NA           1020
#> 10 2024-03-31    10             10 Bank interest             1020             NA
#> 11 2024-03-31    11             10 Bank interest               NA           2850
#> # ℹ 3 more variables: amount <dbl>, account_description <chr>,
#> #   account_type <chr>
```

``` r


get_balance_accounts(
  ledger_file = ledger_file,
  min_date = "2024-01-01",
  max_date = "2024-12-31",
  language = "fr"
)
#> # A tibble: 3 × 6
#>   account_base_category high_category intermediate_category account_number
#>                   <int>         <int>                 <int>          <int>
#> 1                     1            10                   100           1020
#> 2                     1            10                   100           1000
#> 3                     2            20                   280           2850
#> # ℹ 2 more variables: account_description <chr>, sum_amounts <dbl>
```
