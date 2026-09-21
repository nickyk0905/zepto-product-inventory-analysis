-- *DATA EXPLORATION*

-- 1.1 Count of Rows
SELECT COUNT(*) AS [Rows Count]
FROM zepto;


-- 1.2 Sample Data - 10 Records
SELECT TOP 10 *
FROM zepto;


-- 1.3 Null Values
SELECT *
FROM zepto
WHERE Category IS NULL
OR name IS NULL
OR mrp IS NULL 
OR discountPercent IS NULL 
OR availableQuantity IS NULL 
OR discountedSellingPrice IS NULL 
OR weightInGms IS NULL 
OR outOfStock IS NULL
OR quantity IS NULL;


-- 1.4 Different Product Categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;


-- 1.5 Products in Stock vs Out of Stock
SELECT
outOfStock, Count(sku_id)
FROM zepto
GROUP BY outOfStock;


-- 1.6 Products present multiple times
SELECT
Replace(name, '"', '') AS [Products],
Count(sku_id) AS [Product Count]
FROM zepto
GROUP BY name
HAVING Count(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;


-- *DATA CLEANING*

-- 2.1 Products with Price 0
SELECT 
name,
mrp
FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 100;

DELETE FROM zepto
WHERE mrp = 0;

-- 2.2 Conversion from Paise to Rupees
UPDATE zepto
SET mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

SELECT *
FROM zepto;


-- *Uncovering Valuable Insights*

-- 3.1 TOP 10 Best-value Products based on Discount Percentage
SELECT
DISTINCT TOP 10
name, 
mrp,
discountPercent
FROM zepto
ORDER BY discountPercent DESC;


-- 3.2 Products with High MRP (Top 25%) but Out of Stock
SELECT
DISTINCT REPLACE(name, '"', '') AS [Product], 
mrp, 
outOfStock
FROM (
	SELECT 
	*, NTILE(4) OVER (ORDER BY mrp DESC) AS price_percentile
	FROM zepto
) t
WHERE price_percentile = 1
ORDER BY mrp DESC;

EXEC sp_help 'zepto';


-- 3.3 Estimated Revenue for each category
SELECT
category,
SUM(availableQuantity * discountedSellingPrice) AS [Total Inventory Value]
FROM zepto
GROUP BY category
ORDER BY SUM(availableQuantity * discountedSellingPrice);


-- 3.4 Products with MRP > 500 and discount < 10%
SELECT
DISTINCT name AS [Products],
mrp, 
discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;


-- 3.5 Top 5 Categories, with highest average discount percentage
SELECT
TOP 5 category,
ROUND(AVG(discountPercent), 2) AS [Average Discount Percentage]
FROM zepto
GROUP BY category
ORDER BY AVG(discountPercent) DESC;


-- 3.6 Price per gram for Products above 100g, sort by best values
SELECT
    DISTINCT name,
	mrp,
	weightInGms,
    ROUND(discountedSellingPrice / weightInGms, 2) AS [Price per gram]
FROM zepto
WHERE weightInGms > 100
ORDER BY [Price per gram] DESC;


-- 3.7 Group Products in categories of Low, Medium, Bulk
SELECT
CASE 
	WHEN weightInGms > 0 AND weightInGms <= 114
	THEN 'Low'
	WHEN weightInGms > 114 AND weightInGms <= 375
	THEN 'Medium'
	WHEN weightInGms > 375 AND weightInGms <= 1000
	THEN 'Bulk'
END AS [Product Weight Category]
FROM zepto;


-- 3.8 Total Inventory Weight per category
SELECT
category,
SUM(weightInGms * availableQuantity) AS [Total Category Weight]
FROM zepto
GROUP BY category
ORDER BY SUM(weightInGms * availableQuantity) DESC;


-- *ADVANCED SQL TECHNIQUES*

-- 4.1 Category-level summary, filtered to high-value categories
WITH CategorySummary AS (
    SELECT
        category,
        COUNT(sku_id) AS product_count,
        SUM(availableQuantity * discountedSellingPrice) AS total_inventory_value,
        ROUND(AVG(discountPercent), 2) AS avg_discount
    FROM zepto
    GROUP BY category
)
SELECT *
FROM CategorySummary
WHERE total_inventory_value > 100000
ORDER BY total_inventory_value DESC;


-- 4.2 Most-discounted product within each category
WITH RankedDiscounts AS (
    SELECT
        category,
        name,
        discountPercent,
        RANK() OVER (PARTITION BY category ORDER BY discountPercent DESC) AS discount_rank
    FROM zepto
)
SELECT category, name, discountPercent
FROM RankedDiscounts
WHERE discount_rank = 1
ORDER BY category;


-- 4.3 Compare each product's price to the next most expensive product in its category
SELECT
    category,
    name,
    mrp,
    LAG(mrp) OVER (PARTITION BY category ORDER BY mrp DESC) AS next_higher_price,
    ROUND(mrp - LAG(mrp) OVER (PARTITION BY category ORDER BY mrp DESC), 2) AS price_gap
FROM zepto
ORDER BY category, mrp DESC;


-- 4.4 Running total of inventory value per category
SELECT
    category,
    name,
    availableQuantity * discountedSellingPrice AS product_value,
    SUM(availableQuantity * discountedSellingPrice)
        OVER (PARTITION BY category ORDER BY name
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM zepto
ORDER BY category, name;


-- 4.5 Pre-aggregated category summary, saved for reuse in reports/dashboards
CREATE VIEW vw_category_summary AS
SELECT
    category,
    COUNT(sku_id) AS product_count,
    SUM(CASE WHEN outOfStock = 1 THEN 1 ELSE 0 END) AS out_of_stock_count,
    ROUND(AVG(discountPercent), 2) AS avg_discount_percent,
    SUM(availableQuantity * discountedSellingPrice) AS total_inventory_value
FROM zepto
GROUP BY category;

-- Example usage, also comment the line 'CREATE VIEW...':
SELECT * FROM vw_category_summary
ORDER BY total_inventory_value DESC;