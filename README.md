# Zepto Inventory & Pricing — SQL EDA

Exploratory data analysis on Zepto's product catalog using Microsoft SQL Server (T-SQL) — cleaning raw pricing/stock data and uncovering insights on discounts, inventory value, and pricing strategy.

## Dataset

`zepto_data.csv` — ~3,732 products across 14 categories, with pricing (`mrp`, `discountedSellingPrice`, `discountPercent`), stock status (`availableQuantity`, `outOfStock`), and `weightInGms`.

## Approach

- **Cleaned** the data — removed invalid (`mrp = 0`) rows, converted prices from paise to rupees
- **Analyzed** discounts, out-of-stock high-value products, category-wise inventory value, and price-per-gram value
- **Extended** the analysis using CTEs, window functions (`RANK()`, `LAG()`, `NTILE()`), and a SQL View for reusable, category-level reporting

## Key Insights

- Several high-MRP products are out of stock — potential lost revenue on premium items
- Discount depth varies sharply by category
- Category-wise inventory value highlights where stock-value risk is concentrated
- Price-per-gram comparisons reveal which products are genuinely good value vs. just marketed as discounted

Full write-up with methodology and detailed findings: [`docs/Zepto_SQL_EDA_Report.docx`](docs/Zepto_SQL_EDA_Report.docx)

## How to Run

1. Import `data/zepto_data.csv` into a SQL Server table named `zepto`
2. Open `sql/zepto_SQL_project.sql` in SSMS and run section by section (Exploration → Cleaning → Insights → Advanced SQL Techniques)

> Run the cleaning section only once — re-running the price conversion will divide values by 100 again.

## Tools

Microsoft SQL Server (T-SQL), SSMS
