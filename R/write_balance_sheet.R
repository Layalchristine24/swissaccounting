write_balance_sheet <- function(
    ledger_file = file.path(
        here::here(),
        "documents",
        "ledger",
        "sample-ledger.csv"
    ),
    language = "en",
    min_date = lubridate::floor_date(
        Sys.Date() - lubridate::years(1),
        "year"
    ),
    max_date = lubridate::floor_date(Sys.Date(), "year") -
        lubridate::days(1)
) {
    requireNamespace("gt", quietly = TRUE)
    requireNamespace("knitr", quietly = TRUE)

    stopifnot(is.Date(min_date))
    stopifnot(is.Date(max_date))
    stopifnot(file.exists(ledger_file))
    stopifnot(language %in% c("en", "fr", "de"))

    accounts_tmpl <-
        switch(
            language,
            "en" = accounts_model_en,
            "fr" = accounts_model_fr,
            "de" = accounts_model_de
        )

    translations <- list(
        en = list(
            assets = "Assets",
            liabilities = "Liabilities",
            foreign_funds = "Foreign Funds",
            fixed_assets = "Fixed Assets",
            total = "TOTAL",
            balance_sheet = "Balance Sheet as of"
        ),
        fr = list(
            assets = "Actif",
            liabilities = "Passif",
            foreign_funds = "Fonds étrangers",
            fixed_assets = "Actifs immobilisés",
            total = "TOTAL",
            balance_sheet = "Bilan au"
        ),
        de = list(
            assets = "Aktiva",
            liabilities = "Passiva",
            foreign_funds = "Fremdkapital",
            fixed_assets = "Anlagevermögen",
            total = "TOTAL",
            balance_sheet = "Bilanz per"
        )
    )

    trans <- translations[[language]]

    balance_accounts <-
        get_balance_accounts(
            ledger_file = ledger_file,
            min_date = min_date,
            max_date = max_date,
            language = language
        )

    balance_sheet_data_base <-
        balance_accounts$balance_accounts |>
        left_join(
            accounts_tmpl |>
                select(
                    account_base_category = account_number,
                    account_base_category_description = account_description
                ),
            by = join_by(account_base_category)
        ) |>
        select(c(
            "account_base_category",
            "account_base_category_description",
            "sum_amounts"
        )) |>
        reframe(
            total = sum(sum_amounts, na.rm = TRUE),
            .by = c(
                "account_base_category",
                "account_base_category_description"
            )
        ) |>
        rename(account_number = account_base_category)

    balance_sheet_data_high <-
        balance_accounts$balance_accounts |>
        select(c("high_category", "sum_amounts")) |>
        reframe(
            total = sum(sum_amounts, na.rm = TRUE),
            .by = "high_category"
        ) |>
        left_join(
            accounts_tmpl |>
                select(
                    high_category = account_number,
                    high_category_description = account_description
                ),
            by = join_by(high_category)
        ) |>
        rename(account_number = high_category)

    balance_sheet_data <-
        balance_accounts$balance_accounts |>
        select(c("account_number", "sum_amounts", "account_description")) |>
        reframe(
            total = sum(sum_amounts, na.rm = TRUE),
            .by = c("account_number", "account_description")
        )

    balance_sheet_data_intermediate <-
        balance_accounts$balance_accounts |>
        select(c("intermediate_category", "sum_amounts")) |>
        reframe(
            total = sum(sum_amounts, na.rm = TRUE),
            .by = "intermediate_category"
        ) |>
        left_join(
            accounts_tmpl |>
                select(
                    intermediate_category = account_number,
                    intermediate_category_description = account_description
                ),
            by = join_by(intermediate_category)
        ) |>
        rename(account_number = intermediate_category)

    balance_sheet_table <- bind_rows(
        tibble(
            Actif = pull(select(
                filter(balance_sheet_data_high, account_number == 10L),
                high_category_description
            )),
            Montant_Actif = "",
            Passif = trans$foreign_funds,
            Montant_Passif = ""
        ),
        balance_sheet_data |>
            mutate(cash_accounts = account_number %/% 1e2 == 10L) |>
            filter(cash_accounts) |>
            transmute(
                Actif = account_description,
                Montant_Actif = format(
                    total,
                    big.mark = "'",
                    decimal.mark = ".",
                    nsmall = 2
                ),
                Passif = "",
                Montant_Passif = ""
            ),
        tibble(
            Actif = "",
            Montant_Actif = "",
            Passif = "",
            Montant_Passif = ""
        ),
        tibble(
            Actif = trans$fixed_assets,
            Montant_Actif = "",
            Passif = pull(select(
                filter(balance_sheet_data_high, account_number == 28L),
                high_category_description
            )),
            Montant_Passif = ""
        ),
        balance_sheet_data |>
            mutate(liabilities_accounts = account_number %/% 1e2 == 20L) |>
            filter(liabilities_accounts) |>
            transmute(
                Actif = account_description,
                Montant_Actif = format(
                    total,
                    big.mark = "'",
                    decimal.mark = ".",
                    nsmall = 2
                ),
                Passif = "",
                Montant_Passif = ""
            ),
        balance_sheet_data |>
            mutate(capital_accounts = account_number %/% 1e2 == 28L) |>
            filter(capital_accounts) |>
            transmute(
                Actif = "",
                Montant_Actif = "",
                Passif = account_description,
                Montant_Passif = format(
                    total,
                    big.mark = "'",
                    decimal.mark = ".",
                    nsmall = 2
                )
            ),
        tibble(
            Actif = trans$total,
            Montant_Actif = format(
                sum(
                    balance_sheet_data_base |>
                        filter(account_number == 1L) |>
                        select(total)
                ),
                big.mark = "'",
                decimal.mark = ".",
                nsmall = 2
            ),
            Passif = trans$total,
            Montant_Passif = format(
                sum(
                    balance_sheet_data_base |>
                        filter(account_number == 2L) |>
                        select(total)
                ),
                big.mark = "'",
                decimal.mark = ".",
                nsmall = 2
            )
        )
    )

    # Function to make all translation elements bold and also bold elements from specific tibbles
    make_translations_bold <- function(gt_table, translations_list) {
        # Get all values from the translations list
        trans_values <- unlist(translations_list)

        # Get all column names from the table
        table_cols <- names(balance_sheet_table)

        # For each column in the table
        for (col in table_cols) {
            # Skip amount columns as they don't contain text to bold
            if (grepl("Montant", col)) {
                next
            }

            # 1. Make all translation values bold
            for (trans_val in trans_values) {
                gt_table <- gt_table |>
                    gt::tab_style(
                        style = gt::cell_text(weight = "bold"),
                        locations = gt::cells_body(
                            columns = col,
                            rows = balance_sheet_table[[col]] == trans_val
                        )
                    )
            }

            # 2. Make all elements from balance_sheet_data_high bold
            high_values <- balance_sheet_data_high$high_category_description
            for (high_val in high_values) {
                gt_table <- gt_table |>
                    gt::tab_style(
                        style = gt::cell_text(weight = "bold"),
                        locations = gt::cells_body(
                            columns = col,
                            rows = balance_sheet_table[[col]] == high_val
                        )
                    )
            }

            # 3. Make all elements from balance_sheet_data_base bold
            base_values <- balance_sheet_data_base$account_base_category_description
            for (base_val in base_values) {
                gt_table <- gt_table |>
                    gt::tab_style(
                        style = gt::cell_text(weight = "bold"),
                        locations = gt::cells_body(
                            columns = col,
                            rows = balance_sheet_table[[col]] == base_val
                        )
                    )
            }
        }

        return(gt_table)
    }

    balance_sheet_table |>
        gt::gt() |>
        gt::tab_header(
            title = paste(trans$balance_sheet, max_date)
        ) |>
        gt::cols_label(
            Actif = trans$assets,
            Montant_Actif = "",
            Passif = trans$liabilities,
            Montant_Passif = ""
        ) |>
        gt::tab_style(
            style = gt::cell_text(weight = "bold"),
            locations = gt::cells_body(
                columns = c(Actif, Passif),
                rows = c(1, 4, 7)
            )
        ) |>
        gt::tab_style(
            style = gt::cell_text(weight = "bold"),
            locations = gt::cells_column_labels()
        ) |>
        # Make translations bold
        make_translations_bold(trans) |>
        # Add other styling
        gt::tab_options(
            table.width = "125%",
            table.align = "left"
        ) |>
        gt::cols_width(
            Actif ~ gt::px(200),
            Montant_Actif ~ gt::px(100),
            Passif ~ gt::px(200),
            Montant_Passif ~ gt::px(100)
        )
}
