# prism/lib/features/apps/finance_sub_screen.dart

## Unit Scenarios
- Totals compute income, expenses, and balance correctly.
- Category mapping returns correct icon.
- Inline actions update category and delete transactions.

## Widget Scenarios
- Summary cards show totals and colors.
- Transaction expands to show actions panel.
- Budget tab shows progress bars with colors.

## Integration Scenarios
- Add transaction -> totals update immediately.
- Change category -> UI updates and persists.
- Delete transaction -> removed from list and totals recalc.
