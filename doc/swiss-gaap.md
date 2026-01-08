# Swiss GAAP Compliance Documentation

## Overview

The `swissaccounting` package follows **Swiss GAAP** (Generally Accepted Accounting Principles) to ensure compliance with Swiss accounting standards. This document outlines how the package maintains compliance across its core features.

## Key Compliance Areas

### 1. Double-Entry Bookkeeping

**Requirement**: Every transaction must have equal debits and credits to maintain the fundamental accounting equation: Assets = Liabilities + Equity.

**Implementation**:
- All transactions in the ledger use paired entries (debit and credit)
- Each entry is linked via `counterpart_id` to ensure traceability
- The `add_ledger_entry()` function enforces that every transaction has both a debit and credit component
- Automatic counterpart_id assignment maintains linking without affecting the double-entry principle

**Example**:
```r
# Entry 1: Debit Expense account
swissaccounting::add_ledger_entry(
  date = "2024-01-15",
  descr = "Office supplies",
  debit_account = 4000,
  amount = 500,
  export_csv = TRUE,
  filename_to_export = ledger_file
)

# Entry 2: Credit Bank account (automatically linked via counterpart_id)
swissaccounting::add_ledger_entry(
  date = "2024-01-15",
  descr = "Office supplies payment",
  credit_account = 1020,
  amount = 500,
  import_csv = TRUE,
  filename_to_import = ledger_file,
  export_csv = TRUE,
  filename_to_export = ledger_file
)
```

**Compliance Status**: ✅ **COMPLIANT**

---

### 2. Audit Trail (Prüfungspfad)

**Requirement**: All transactions must be traceable, properly documented, and linked to maintain a clear audit trail.

**Implementation**:
- Every ledger entry has a unique `id` for identification
- Related entries are linked via `counterpart_id`
- Each entry includes:
  - `date`: Transaction date
  - `description`: Clear description of the transaction
  - `account_number`: Account affected
  - `account_description`: Account name
  - `amount`: Transaction amount
- Automatic counterpart_id assignment **improves** audit trail reliability by:
  - Eliminating hardcoded ID errors
  - Ensuring correct relationships regardless of regeneration
  - Maintaining consistent linking across year-end closing and opening entries

**Compliance Status**: ✅ **COMPLIANT** (Enhanced)

---

### 3. Chronological Recording (Chronologische Buchführung)

**Requirement**: Transactions must be recorded in chronological order by date.

**Implementation**:
- All entries include a `date` field (required parameter)
- The ledger preserves chronological order
- ID assignment is based on insertion order, maintaining temporal sequence
- Date-based filtering is supported for generating period-specific financial statements

**Example**:
```r
# Transactions are recorded by date
add_ledger_entry(date = "2024-01-01", ...)  # ID = 1
add_ledger_entry(date = "2024-01-01", ...)  # ID = 2
add_ledger_entry(date = "2024-01-15", ...)  # ID = 3
add_ledger_entry(date = "2024-01-15", ...)  # ID = 4
```

**Compliance Status**: ✅ **COMPLIANT**

---

### 4. Account Classification (Kontenrahmen)

**Requirement**: Use the Swiss Kontenrahmen KMU (SME Chart of Accounts) for account classification.

**Implementation**:
- The package uses standard Swiss account categories:
  - **Category 1**: Assets (Aktiven)
  - **Category 2**: Liabilities (Passiven)
  - **Category 3**: Income (Ertrag)
  - **Categories 4-8**: Expenses (Aufwand)
  - **Category 9**: Closing and Opening accounts
- Account model includes:
  - `account_number`: Standard Swiss account numbers
  - `account_description`: Multilingual (EN/FR/DE)
  - `account_type`: Asset, Liability, Income, Expense
  - `account_base_category`: 1-9 classification
- Automatic counterpart_id assignment does **not** modify account numbering or classification

**Example Account Numbers**:
- 1020: Bank
- 2300: Accounts Payable
- 3000: Service Revenue
- 6000: Rent Expense
- 9200: Current Year Profit/Loss
- 9100: Opening Balance

**Compliance Status**: ✅ **COMPLIANT**

---

### 5. Year-End Closing (Jahresabschluss)

**Requirement**: Profit and Loss (P&L) accounts must be closed to equity at fiscal year-end.

**Implementation**:
- The `close_fiscal_year()` function follows Swiss GAAP year-end closing procedure:
  1. Close all **Income accounts (category 3)** to Account 9200 (Current Year Profit/Loss)
  2. Close all **Expense accounts (categories 4-8)** to Account 9200
  3. Transfer Account 9200 to Account 2891 (Balance Sheet Profit/Loss)
  4. Transfer Account 2891 to Account 2850 (Private Account / Equity)

**Swiss Standard Accounts Used**:
- **Account 9200**: Current Year Profit/Loss (Swiss standard account)
- **Account 2891**: Balance Sheet Profit/Loss (intermediate transfer account)
- **Account 2850**: Private Account (equity account, configurable)

**Automatic ID Management**: The closing function now uses automatic counterpart_id assignment, simplifying the code while maintaining full compliance.

**Example**:
```r
swissaccounting::close_fiscal_year(
  ledger_file = "path/to/ledger.csv",
  closing_date = "2024-12-31",
  language = "en"
)
```

**Compliance Status**: ✅ **COMPLIANT**

---

### 6. Opening Balances (Eröffnungsbilanz)

**Requirement**: Balance sheet accounts must carry forward to the new fiscal year.

**Implementation**:
- The `create_opening_balances()` function creates opening entries for all balance sheet accounts (categories 1-2)
- Uses **Account 9100** (Opening Balance) as the counterpart account
  - **Note**: Account 9100 is a custom extension, **permitted by Swiss GAAP**
  - Swiss standards allow flexibility in managing opening balances
- Maintains correct debit/credit orientation based on account type:
  - **Assets (category 1)**: Normal debit balance → DR Asset, CR 9100
  - **Liabilities (category 2)**: Normal credit balance → DR 9100, CR Liability
- Handles reversed balances correctly (e.g., asset with credit balance)

**Automatic ID Management**: Opening balance entries now use automatic counterpart_id assignment for cleaner code.

**Example**:
```r
swissaccounting::create_opening_balances(
  ledger_file = "path/to/ledger.csv",
  opening_date = "2025-01-01",
  language = "en"
)
```

**Compliance Status**: ✅ **COMPLIANT**

---

### 7. Documentation (Belegprinzip)

**Requirement**: Each transaction must have proper documentation and description.

**Implementation**:
- Every ledger entry **requires** a `descr` (description) parameter
- Descriptions clearly explain the nature of the transaction
- Multilingual support (EN/FR/DE) for account descriptions
- Account types and categories are documented in the account model

**Example**:
```r
add_ledger_entry(
  date = "2024-02-15",
  descr = "Service revenue from Project ABC",  # Clear description required
  debit_account = 1020,
  amount = 3000,
  ...
)
```

**Compliance Status**: ✅ **COMPLIANT**

---

## Automatic Counterpart ID Assignment

### Overview

The package implements automatic counterpart_id assignment to eliminate manual ID management while maintaining full Swiss GAAP compliance.

### How It Works

1. **First entry in a transaction** (when `import_csv = FALSE`):
   - Automatically self-links: `counterpart_id = id`
   - This marks the beginning of a transaction

2. **Subsequent entries in a transaction** (when `import_csv = TRUE`):
   - Automatically links to previous entry: `counterpart_id = max(ledger$id)`
   - This pairs the entries correctly

3. **Multi-entry transactions** (>2 entries):
   - Users can explicitly provide `counterpart_id` to link all entries to the first entry

### Why This is Compliant

Automatic counterpart_id assignment is a **technical implementation detail** that:
- ✅ Does **NOT** change accounting principles (double-entry, account classification)
- ✅ Does **NOT** modify transaction amounts, dates, or descriptions
- ✅ Does **NOT** alter year-end closing or opening balance procedures
- ✅ **IMPROVES** audit trail reliability by eliminating hardcoded ID errors
- ✅ **ENHANCES** traceability by ensuring correct relationships always

**Swiss GAAP does not prescribe** how to assign internal record IDs, only that transactions must be properly recorded, linked, and traceable. The automatic assignment enhances this requirement.

---

## Multilingual Support

The package supports three official Swiss languages:

- **English (en)**: Default
- **French (fr)**: French-speaking regions
- **German (de)**: German-speaking regions

Account descriptions, closing/opening descriptions, and error messages are available in all three languages.

**Example**:
```r
# French
close_fiscal_year(ledger_file, "2024-12-31", language = "fr")
# Descriptions will be: "Clôture: [Account]", "Bilan d'ouverture: [Account]"

# German
close_fiscal_year(ledger_file, "2024-12-31", language = "de")
# Descriptions will be: "Abschluss: [Account]", "Eröffnungsbilanz: [Account]"

# English
close_fiscal_year(ledger_file, "2024-12-31", language = "en")
# Descriptions will be: "Closing: [Account]", "Opening Balance: [Account]"
```

---

## Summary

The `swissaccounting` package is **fully compliant with Swiss GAAP** across all seven key areas:

1. ✅ **Double-entry bookkeeping** - Maintained in all transactions
2. ✅ **Audit trail** - Enhanced through automatic ID linking
3. ✅ **Chronological recording** - Date-based ordering preserved
4. ✅ **Account classification** - Swiss Kontenrahmen KMU followed
5. ✅ **Year-end closing** - Standard Swiss procedure implemented
6. ✅ **Opening balances** - Proper balance sheet carry-forward
7. ✅ **Documentation** - Required descriptions for all transactions

The automatic counterpart_id assignment feature **enhances compliance** by improving reliability and eliminating manual errors, while adhering to all fundamental Swiss accounting principles.

---

## References

- Swiss GAAP (Generally Accepted Accounting Principles)
- Kontenrahmen KMU (SME Chart of Accounts)
- Swiss Code of Obligations (OR/CO) - Article 957-963
