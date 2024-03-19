--- Checking available data

SELECT *
FROM activity_data

SELECT *
FROM activity_data_heartrate

SELECT *
FROM heartrate

SELECT *
FROM sleep_data


--- Changing table names


EXEC sp_rename 'activity_data$', 'activity_data'
EXEC sp_rename 'activity_data_heartrate$', 'activity_data_heartrate'
EXEC sp_rename 'heartrate$', 'heartrate'
EXEC sp_rename 'sleep_data$', 'sleep_data'


--- Changing column name


EXEC sp_rename 'activity_data.Id', 'ID'
EXEC sp_rename 'activity_data_heartrate.Id', 'ID'
EXEC sp_rename 'heartrate.Id', 'ID'
EXEC sp_rename 'sleep_data.Id', 'ID'


--- Converting Date to date to remove the extra zeros 


ALTER TABLE activity_data
ALTER COLUMN Date date

ALTER TABLE activity_data_heartrate
ALTER COLUMN Date date

ALTER TABLE heartrate
ALTER COLUMN Date date

ALTER TABLE sleep_data
ALTER COLUMN Date date

----- 

SELECT *
FROM activity_data ad
JOIN activity_data_heartrate adh
     ON ad.ID = adh.ID AND ad.Date = adh.Date
JOIN heartrate h
     ON adh.ID = h.ID AND adh.Date = h.Date
JOIN sleep_data sd
     ON h.ID = sd.ID AND h.Date = sd.Date


---- Calculating the total number of steps taken each day across all users


SELECT Date, SUM(TotalSteps) AS StepTakenDaily
FROM activity_data
GROUP BY Date
ORDER BY Date 

--- Computing the total distance covered each day


SELECT Date, CONCAT(CEILING(SUM(TotalDistance)), ' KM') AS DistanceCovered
FROM activity_data
GROUP BY Date
ORDER BY Date 


---- Finding the total sedentary minutes per day


SELECT Date, SUM(SedentaryMinutes) AS TotalMinutesSeated
FROM activity_data
GROUP BY Date
ORDER BY Date 


--- The total active minutes per day


SELECT Date, SUM(TotalActiveMinutes) AS CumulativeActiveMinutes
FROM activity_data
GROUP BY Date
ORDER BY Date 


--- Calculating the total calories burned per day

SELECT Date, SUM(Calories) AS BurnedCalories
FROM activity_data
GROUP BY Date
ORDER BY Date 


--- Investigating heart rates recorded across different dates


SELECT Date, ROUND(AVG(Heart_rate), 2) AS AverageHeartRate, ROUND(MIN(Heart_rate), 2) AS LowestHearRate, ROUND(MAX(Heart_rate), 2) AS HighestHeartRate
FROM activity_data_heartrate
GROUP BY Date
ORDER BY AverageHeartRate DESC, LowestHearRate DESC, HighestHeartRate DESC


--- The correlation between heart rate and total active minutes

WITH Coefficient1 AS ( SELECT
      (
        (SUM(Heart_rate * TotalActiveMinutes) - (SUM(Heart_rate) * SUM(TotalActiveMinutes)) / COUNT(*))
        / SQRT(
                (SUM(Heart_rate * Heart_rate) - (SUM(Heart_rate) * SUM(Heart_rate)) / COUNT(*))
              * (SUM(TotalActiveMinutes * TotalActiveMinutes) - (SUM(TotalActiveMinutes) * SUM(TotalActiveMinutes)) / COUNT(*))
        )
       ) AS CorrHR_Active
FROM activity_data_heartrate)


SELECT 
CASE
    WHEN CorrHR_Active < 0 THEN 'Negative linear correlation'
    WHEN CorrHR_Active > 0 THEN 'Positive linear correlation'
	ELSE 'No linear correlation'
END AS Correlation1
FROM Coefficient1


--- Correlation between heart rate and calories burned

WITH Coefficient2 AS ( SELECT
      (
        (SUM(Heart_rate * Calories) - (SUM(Heart_rate) * SUM(Calories)) / COUNT(*))
        / SQRT(
                (SUM(Heart_rate * Heart_rate) - (SUM(Heart_rate) * SUM(Heart_rate)) / COUNT(*))
              * (SUM(Calories * Calories) - (SUM(Calories) * SUM(Calories)) / COUNT(*))
        )
       ) AS CorrHR_Cal
FROM activity_data_heartrate)


SELECT 
CASE
    WHEN CorrHR_Cal < 0 THEN 'Negative linear correlation'
    WHEN CorrHR_Cal > 0 THEN 'Positive linear correlation'
	ELSE 'No linear correlation'
END AS Correlation2
FROM Coefficient2


--- Total minutes asleep each day


SELECT Date, SUM(TotalMinutesAsleep) AS SleepMinutes
FROM sleep_data
GROUP BY Date


--- Time spent in bed per user


SELECT ID, SUM(TotalTimeInBed) AS MinutesInBed
FROM sleep_data
GROUP BY ID
ORDER BY MinutesInBed DESC

--- Average time spent in bed per day 


SELECT Date, CEILING(AVG(TotalTimeInBed)) AS AvgSpentInBed
FROM sleep_data
GROUP BY Date


--- Relationship between sleep duration and heart rate


WITH Coefficient3 AS (
SELECT (SUM(TotalMinutesAsleep * Heart_rate) - (SUM(TotalMinutesAsleep) * SUM(Heart_rate)) / COUNT(*))
        / SQRT(
                (SUM(TotalMinutesAsleep * TotalMinutesAsleep) - (SUM(TotalMinutesAsleep) * SUM(TotalMinutesAsleep)) / COUNT(*))
              * (SUM(Heart_rate * Heart_rate) - (SUM(Heart_rate) * SUM(Heart_rate)) / COUNT(*))
        ) AS CorrMinsAsleep_HR
FROM sleep_data
JOIN activity_data_heartrate
     ON sleep_data.ID = activity_data_heartrate.ID)

SELECT 
CASE
    WHEN CorrMinsAsleep_HR < 0 THEN 'Negative linear correlation'
    WHEN CorrMinsAsleep_HR > 0 THEN 'Positive linear correlation'
	ELSE 'No linear correlation'
END AS Correlation3
FROM Coefficient3


---- Outliers and anomalies 
---- Only 58 minutes slept in a day
SELECT TOP 1 TotalMinutesAsleep
FROM sleep_data
ORDER BY TotalTimeInBed
---- Slept over 13 hours in a day
SELECT  TOP 1 TotalMinutesAsleep, ROUND((TotalMinutesAsleep/60),2) AS TotalAsleepInHours
FROM sleep_data
ORDER BY TotalMinutesAsleep DESC


---- Total percentage of activity vs sedentary state 


SELECT CONCAT(CEILING((SUM(TotalActiveMinutes) * 100)/ SUM(SedentaryMinutes)), ' percent') AS PercentageOfActivity
FROM activity_data a
WHERE SedentaryMinutes <> 0 AND  TotalActiveMinutes <> 0
