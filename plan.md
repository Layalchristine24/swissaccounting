## Latest: Fix counterpart_id Pairing in Transactions (2026-01-05)

**Status**: ✅ COMPLETED

### Overview

Fixed `counterpart_id` assignment so transaction pairs are correctly linked. Previously, the first entry of each transaction was incorrectly linking to the previous transaction's entry instead of having `NA`.

### Issues Fixed

1. **First entry had wrong counterpart_id**: First entry of a new transaction was getting `counterpart_id` pointing to the previous transaction's last entry instead of `NA`

2. **Second entry relied on implicit linking**: Second entry used `max(last_ledger$id)` which worked but was fragile. Now explicitly passes the first entry's ID.

### Files Modified

1. ✅ `R/ledger.R` - Added `is_first_entry` parameter to `add_ledger_entry()` to explicitly mark first entries (sets `counterpart_id = NA`)
2. ✅ `R/add_transaction.R` - Captures first entry's ID and explicitly passes it as `counterpart_id` to second entry
3. ✅ `R/ledger_helpers.R` - Updated `append_ledger_entries()` to use `NA_integer_` for first entries instead of self-linking

### Result

Transactions now correctly paired:
```
id=1, counterpart_id=NA     # First entry of transaction 1
id=2, counterpart_id=1      # Second entry links to first
id=3, counterpart_id=NA     # First entry of transaction 2
id=4, counterpart_id=3      # Second entry links to first
```

---

## Previous: Fix Balance Sheet to Include Operating Result (2026-01-04)

**Status**: ✅ COMPLETED

### Overview

Fixed `get_balance_accounts()` to automatically include the current year's profit/loss (account 2891 - Balance Sheet P/L) so the balance sheet balances during the fiscal year before closing.

### Issue Fixed

4. **Balance sheet didn't balance during fiscal year**: Added operating result calculation to `get_balance_accounts`
   - During the fiscal year, income/expense accounts (3-6) affect assets but aren't shown on balance sheet
   - Now automatically calculates P&L from income statement and adds it as account 2891
   - Balance sheet now balances: Assets = |Liabilities| at all times

### Files Modified

1. ✅ `R/get_balance_accounts.R` - Added automatic operating result as Balance Sheet P/L (2891)

### Verification

Balance sheet now properly balanced during fiscal year:
```r
# A tibble: 5 × 3
  account_number account_description                              sum_amounts
           <int> <chr>                                                  <dbl>
1           1020 Bank                                                   19026
2           1000 Cash                                                    1500
3           2800 Share Capital                                         -10000
4           2000 Creditors                                             -10000
5           2891 Balance Sheet P/L                                       -526

# A tibble: 2 × 2
  account_base_category total
                  <int> <dbl>
1                     1  20526  # Assets
2                     2 -20526  # Liabilities (equals assets in absolute value) ✓
```

All 22 tests pass.

Note: README.md needs to be regenerated with `devtools::build_readme()` once pandoc is available.

---

## Previous: Fix Fiscal Year Closing and Balance Sheet (2026-01-04)

**Status**: ✅ COMPLETED

### Overview

Fixed critical accounting issues in fiscal year closing and balance sheet generation to follow Swiss GAAP standards.

### Issues Fixed

1. **Wrong default account for profit transfer**: Changed from 2850 (Private Account) to 2970 (Carried Forward Profit/Loss)
   - Private account is for owner withdrawals/contributions, not profit allocation
   - Per Swiss GAAP, profit should go to reserves (2970) not private account (2850)

2. **Incorrect sign convention in aggregate_accounts**: Fixed `sum_accounts.R`
   - Credits to liability/income accounts now correctly negative
   - Debits to asset/expense accounts now correctly positive
   - This fixes the net P&L calculation for closing

3. **Spurious private account in balance sheet**: Removed auto-generated private account entry from `get_balance_accounts`
   - Previously, `get_balance_accounts` called `get_private_account` which synthesized an entry
   - This caused double-counting after closing since profit was already in 2970
   - Now balance sheet only shows actual ledger entries

### Files Modified

1. ✅ `R/close_fiscal_year.R` - Changed default `transfer_to_account` from 2850L to 2970L
2. ✅ `R/sum_accounts.R` - Fixed sign convention in `aggregate_accounts()`
3. ✅ `R/get_balance_accounts.R` - Removed synthetic private account entry
4. ✅ `README.Rmd` - Updated documentation for new default account

### Verification

Balance sheet now properly balanced:
```r
# After closing:
# A tibble: 3 × 3
  account_number account_description                              sum_amounts
           <int> <chr>                                                  <dbl>
1           1020 Bank                                                    1300
2           2800 Share Capital                                          -1000
3           2970 Carried Forward Profit / Loss                           -300

# A tibble: 2 × 2
  account_base_category total
                  <int> <dbl>
1                     1  1300  # Assets
2                     2 -1300  # Liabilities (equals assets in absolute value) ✓
```

All 22 tests pass.

---

## Previous Notes (Reference)




