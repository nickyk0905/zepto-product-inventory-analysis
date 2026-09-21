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

