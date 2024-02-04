
--SELECT *
--FROM Port..Covid_Vaccinations
--ORDER BY 3,4

--- DATA TO USE:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Port..Covid_Deaths
ORDER BY 1, 2
--- Changing Data type as they are both in nvarchar
ALTER TABLE Port..Covid_Deaths
ALTER COLUMN total_cases FLOAT

ALTER TABLE Port..Covid_Deaths
ALTER COLUMN total_deaths FLOAT


--- Exploring total_cases vs Total_deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Port..Covid_Deaths
WHERE Location = 'Algeria'
ORDER BY 1, 2


--- Exploring total_cases vs population
--- Gives us the percentage of the population that got Covid
SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 AS TransmissionPercentage
FROM Port..Covid_Deaths
WHERE Location = 'Algeria' 
ORDER BY 1, 2

--- Exploring locations with the highest infection rate
SELECT Location, population, MAX(total_cases) HighestTransmissionCount, 
MAX((total_cases/population))*100 AS TransmissionPercentage
FROM Port..Covid_Deaths 
GROUP BY Location, population
ORDER bY TransmissionPercentage DESC


--- Highest death count per population
SELECT Location, Population, MAX(total_deaths) HighestDeathCount --, MAX((total_deaths/population))*100 DeathPercentagePerPop
FROM Port..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY HighestDeathCount DESC


--- Highest death count per continent
SELECT location, MAX(total_deaths) HighestDeathCount
FROM Port..Covid_Deaths
WHERE continent IS  NULL AND location NOT LIKE '%income%' 
GROUP BY location
ORDER BY HighestDeathCount DESC


--- 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, --SUM(new_deaths)/sum(new_cases)*100 AS DeathPercentage,
CASE 
       WHEN new_cases = 0 THEN NULL
	   ELSE SUM(new_deaths)/sum(new_cases)*100
END AS DeathPercentage
FROM Port..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY new_cases
ORDER BY 1


--- Exploring population vs vaccination in the entire world
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(convert(bigint,new_vaccinations)) OVER (PARTITION BY Population ORDER BY dea.location, dea.date) RollingVaccinatedCount
FROM Port..Covid_Deaths Dea
JOIN Port..Covid_Vaccinations Vac
     ON Dea.location = Vac.location and Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--- Calculating rolling sum of new vaccinations by location and continent 
--- Using CTE
WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingVaccinatedCount)
AS 
(
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(convert(bigint,new_vaccinations)) OVER (PARTITION BY Population ORDER BY dea.location, dea.date) RollingVaccinatedCount
FROM Port..Covid_Deaths Dea
JOIN Port..Covid_Vaccinations Vac
     ON Dea.location = Vac.location and Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingVaccinatedCount/population)*100 AS RPpercentage
FROM POPvsVAC
WHERE Location = 'Algeria'


--- Using Temporary Table
DROP TABLE IF EXISTS #POPvsVAC
CREATE TABLE #POPvsVAC
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #POPvsVAC 
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(convert(bigint,new_vaccinations)) OVER (PARTITION BY Population ORDER BY dea.location, dea.date) RollingVaccinatedCount
FROM Port..Covid_Deaths Dea
JOIN Port..Covid_Vaccinations Vac
     ON Dea.location = Vac.location and Dea.date = Vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/POPULATION)*100
FROM #POPvsVAC


--- Creating view to store data for later visualizations

CREATE VIEW PercentageOfVaccinatedPopulation 
AS
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(convert(bigint,new_vaccinations)) OVER (PARTITION BY Population ORDER BY dea.location, dea.date) RollingVaccinatedCount
FROM Port..Covid_Deaths Dea
JOIN Port..Covid_Vaccinations Vac
     ON Dea.location = Vac.location and Dea.date = Vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentageOfVaccinatedPopulation