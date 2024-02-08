--- Exploring and Cleaning Data
--- Changing date format
SELECT date, cast(date AS date)
FROM Sales


ALTER TABLE Sales
ALTER COLUMN Date  date



--- Country with the highest revenue
SELECT TOP 1 Country, SUM(revenue) HighestRev
FROM Sales
GROUP BY Country
ORDER BY HighestRev DESC



--- TotalRevenue of US
SELECT SUM(Revenue) TotalRevenue
FROM Sales
WHERE Country = 'United States'



--- Finding the most profitable product
SELECT  Product, SUM(Profit) MostProfitableProduct
FROM Sales
GROUP BY Product
ORDER BY MostProfitableProduct DESC


--- Customer demographics to which products are most sought after
WITH RankedProduct
AS (
SELECT Age_Group, Product, SUM(Order_Quantity) TotalItemsBought, SUM(Profit) ProfitPerProduct, 
ROW_NUMBER() OVER (PARTITION BY Age_Group ORDER BY SUM(Profit) DESC) RowNumber
FROM Sales
GROUP BY Age_Group, Product
)
SELECT Age_Group, Product, TotalItemsBought, ProfitPerProduct
FROM RankedProduct
WHERE RowNumber = 1  



--- Changing Customer_Gender display from M to Male and from F to Female
UPDATE Sales
SET Customer_Gender =
   CASE 
        WHEN Customer_Gender = 'F' THEN 'Female'
		WHEN Customer_Gender = 'M' THEN 'Male'
		ELSE Customer_Gender
   END



--- Distribution of gender with products bought 
SELECT Customer_Gender, Product, SUM(Order_Quantity) TotalQuantityBought
FROM Sales
GROUP BY Customer_Gender, Product
ORDER BY TotalQuantityBought DESC



--- TOP 3 countries with the highest revenue
SELECT TOP 3 Country, SUM(Revenue) TOPRevenue
FROM Sales
GROUP BY Country
ORDER BY TOPRevenue DESC



--- Distribution of state sales in US
DROP TABLE IF EXISTS #SalesPerState
CREATE TABLE #SalesPerState
(State varchar(50),
TotalSalesPerState bigint,
ProfitabilityState varchar(50)
)

INSERT INTO #SalesPerState
SELECT State, SUM(Revenue) TotalSalesPerState,  
   CASE
       WHEN SUM(Revenue) > 100000 THEN 'LUCRATIVE'
	   WHEN SUM(Revenue) < 10000 THEN 'UNDERPERFORMING'
	   ELSE 'PROFITABLE'
   END ProfitabilityState
FROM Sales
WHERE Country = 'United States'
GROUP BY State
ORDER BY TotalSalesPerState DESC

SELECT *
FROM #SalesPerState
ORDER BY TotalSalesPerState DESC



--- 3 Most sold products based on quantities
SELECT TOP 3 Product, SUM(Order_Quantity) QuantityBasedOnProduct
FROM Sales
GROUP BY Product
ORDER BY 2 DESC



--- Calculating Product margin (profit/revenue) X 100, and then most profitable sub categories
SELECT Product, (SUM(Profit)/SUM(Revenue))*100 Margin
FROM Port..Sales
GROUP BY Product

SELECT Sub_Category, SUM(Profit)
FROM Port..Sales
GROUP BY Sub_Category

SELECT DISTINCT(Age_Group)
from PORT..Sales



--- Adjusting Table
sp_rename 'Sales.Age_Group', 'AgeRange', 'COLUMN'

SELECT A.Date, AgeRange, Age_Group
FROM PORT..Sales A
JOIN PORT..Sales2 B
     ON A.date = B.Date


UPDATE A
SET A.AgeRange = B.Age_Group
FROM PORT..Sales A
JOIN PORT..Sales2 B
     ON A.date = B.Date


--- Yearly Trends and seasonal patterns
WITH YearlyRankedProducts AS 
(
SELECT Year, Product, SUM(Profit) AS TOtalProfit, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY SUM(Profit) DESC) AS Ranking
FROM Port..Sales
GROUP BY Year, Product
)

SELECT  Year, Product, TOtalProfit
FROM YearlyRankedProducts
WHERE Ranking = 1


WITH SeasonalRankedProducts AS 
(
SELECT Month, Product, SUM(Profit) AS TOtalProfit,
ROW_NUMBER() OVER (PARTITION BY Month ORDER BY SUM(Profit) DESC) AS Ranking
FROM Port..Sales
GROUP BY Month, Product
)

SELECT Month, Product, TotalProfit
FROM SeasonalRankedProducts
WHERE Ranking = 1
ORDER BY MONTH(CONVERT(DATE, '01 ' + Month + ' 2000'))



--- Average quantity per customer agerange and customer behavior
SELECT AgeRange, AVG(CAST(Order_Quantity as int)) AvgQuantPerCustomerRange
FROM Port..Sales
GROUP BY AgeRange


SELECT AgeRange, Product, SUM(Order_Quantity) TotalOrdersByAgeR, SUM(Revenue) TotalRevPeryAgeR
FROM Port..Sales
GROUP BY 1, 2
ORDER BY 4 DESC


--- Avg cost and price for a unit
SELECT Product, AVG(Unit_Price) AvgPrice, AVG(Unit_Cost) AvgCost
FROM Port..Sales
GROUP BY Product
ORDER BY 2 DESC



--- Exploring the distribution of order quantities for different products, avg revenue per product, avg revenue for 1 order
SELECT Product, SUM(Order_Quantity)
FROM Port..Sales
GROUP BY Product
ORDER BY 2 DESC


SELECT Product, SUM(Order_Quantity) TOQPerProduct, AVG(CAST(Revenue as int)) RevenuePerProduct
FROM Port..Sales
GROUP BY Product
ORDER BY 3


SELECT Product, SUM(CAST(Revenue as int))/SUM(CAST(Order_Quantity as int)) AvgRevPerOrder
FROM Port..Sales
GROUP BY Product
ORDER BY 2 DESC













