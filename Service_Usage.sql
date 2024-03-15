--- checking out the data available

SELECT *
FROM Service_Use


SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Service_Use'


--- changing column names 


EXEC sp_rename '[Service_Use].[Customer Region]', 'Customer_Region', 'column'

EXEC sp_rename '[Service_Use].[Customer Size Revenue]', 'Customer_Size_Revenue', 'column'

EXEC sp_rename '[Service_Use].[Customer Size Employees]', 'Customer_Size_Employees', 'column'

EXEC sp_rename '[Service_Use].[Likelihood to Recommend Score]', 'Likelihood_to_Recommend_Score', 'column'


--- Splitting Customer_Size_Revenue column into two, min and max


SELECT *, 
CASE 
     WHEN Customer_Size_Revenue = 'Less than 14M' THEN '10M'
	 WHEN Customer_Size_Revenue = 'Greater than 111M' THEN '100M'
	 ELSE PARSENAME(REPLACE(Customer_Size_Revenue, '-','.'), 2)
END AS MinRevenue 
FROM Port.dbo.Service_Use

 SELECT *, 
CASE 
      WHEN PARSENAME(REPLACE(Customer_Size_Revenue, '-','.'), 1) = 'Less than 14M' THEN '14M'
	  WHEN PARSENAME(REPLACE(Customer_Size_Revenue, '-','.'), 1) = 'Greater than 111M' THEN '120M'
	  ELSE PARSENAME(REPLACE(Customer_Size_Revenue, '-','.'), 1)
END MaxRevenue
 FROM Port.dbo.Service_Use


 ALTER TABLE Port.dbo.Service_Use
 ADD MaxRevenue nvarchar(255)

 UPDATE Port.dbo.Service_Use
 SET MaxRevenue =
CASE 
      WHEN PARSENAME(REPLACE(Customer_Size_Revenue, '-','.'), 1) = 'Less than 14M' THEN '14M'
	  WHEN PARSENAME(REPLACE(Customer_Size_Revenue, '-','.'), 1) = 'Greater than 111M' THEN '120M'
	  ELSE PARSENAME(REPLACE(Customer_Size_Revenue, '-','.'), 1)
END 


ALTER TABLE Port..Service_Use
ADD MinRevenue nvarchar(255)


UPDATE Port..Service_Use
SET MinRevenue = CASE 
     WHEN Customer_Size_Revenue = 'Less than 14M' THEN '10M'
	 WHEN Customer_Size_Revenue = 'Greater than 111M' THEN '100M'
	 ELSE PARSENAME(REPLACE(Customer_Size_Revenue, '-','.'), 2)
END


--- dropping an empty column


ALTER TABLE Service_Use
DROP COLUMN Customer_Size_Revenue_Temp


--- checking for duplicates and removing them


SELECT *, COUNT(*)
FROM Service_Use
GROUP BY Customer, Service, Domain, Package, Customer_Region, Customer_Size_Revenue, Customer_Size_Employees, 
         Likelihood_to_Recommend_Score


WITH Duplicates AS 
(SELECT Customer, Service, Domain, Package, Customer_Region, Customer_Size_Revenue, Customer_Size_Employees, 
        Likelihood_to_Recommend_Score,
        RN = ROW_NUMBER()OVER(PARTITION BY Customer, Service, Domain, Package, Customer_Region, Customer_Size_Revenue, Customer_Size_Employees, 
        Likelihood_to_Recommend_Score ORDER BY (SELECT NULL))
 FROM Service_Use)

DELETE 
 FROM Duplicates
 WHERE RN > 1


  ---  insights into particularly well-received aspects of our services


SELECT Customer, Domain, Package
FROM Service_Use
WHERE SERVICE IN (
                   SELECT Service
                   FROM Service_Use
                   GROUP BY Service
                   HAVING AVG(Likelihood_to_Recommend_Score) >= 7)


 ---  insights into particularly under-received aspects of our services


SELECT Customer, Domain, Package
FROM Service_Use
WHERE SERVICE IN (
                   SELECT Service
                   FROM Service_Use
                   GROUP BY Service
                   HAVING AVG(Likelihood_to_Recommend_Score) < 7)


 ----Services with the maximum score received


 SELECT Service
 FROM Service_Use
 WHERE Likelihood_to_Recommend_Score =  (SELECT MAX(Likelihood_to_Recommend_Score) FROM Service_Use)
 GROUP BY Service


  ---Number of Custmers, services, domains, packages 


 SELECT COUNT(DISTINCT Customer) UniqueCustomers
 FROM Service_Use
 
 SELECT COUNT(DISTINCT Service)
 FROM Service_Use

  SELECT COUNT(DISTINCT Domain)
 FROM Service_Use

  SELECT COUNT(DISTINCT Package)
 FROM Service_Use


 --- Which services are being used the most


SELECT Service, Domain, Package, COUNT(*) AS ServiceUsageCount
FROM Service_Use
GROUP BY  Service, Domain, Package 
ORDER BY  ServiceUsageCount DESC, Service, Domain, Package


  ---Deleting scores where their total is equal or less than five since the data would be too small to consider 


DELETE 
FROM Port.dbo.Service_Use
WHERE Service IN (
                   SELECT Service
                   FROM (
                          SELECT Service, COUNT(*) AS Record_Count
                          FROM Port.dbo.Service_Use
                          GROUP BY Service) AS Subquery
                    WHERE Record_Count <= 5)


  ---Which of our services are being used the most, along with their avg recommendation scores, and description


WITH Recommend AS (
                   SELECT Service, ROUND(AVG(Likelihood_to_Recommend_Score),2) AS Avg_Recommendation_Score, COUNT(*) AS Times_Used
                   FROM Service_Use
                   GROUP BY Service
                   )

SELECT Service, Avg_Recommendation_Score, Times_Used,
CASE 
    WHEN CEILING(Avg_Recommendation_Score) BETWEEN 1 AND 4 THEN 'Not Recommended'
	WHEN CEILING(Avg_Recommendation_Score) = 5 THEN 'Conditional'
	WHEN CEILING(Avg_Recommendation_Score) BETWEEN 6 AND 7 THEN 'Recommended'
	ELSE 'Highgly Recommended'
END AS Recommendation_Statues
FROM Recommend
ORDER BY Times_Used DESC




