SELECT *
FROM PortfolioProject..CovidDeaths
WHERE LOCATION = 'Ukraine'
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- DATA that I am going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2



-- Total Cases vs Total Deaths
--- Shows the percentage of dying of in case of getting COVID in Algeria

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS MortalityPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Algeria%'
ORDER BY 1, 2

-- Total_cases vs Population
--- Shows the percentage of getting covid in Algeria

SELECT location, date, total_cases, population, (CONVERT(float, total_cases) / population) * 100 AS InfectedPct
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Algeria%'
ORDER BY 1, 2


-- Looking at the countries with the highest infection percentage by population
--- 
SELECT location, MAX(total_cases) HighestCases, population, (CONVERT(float, MAX(total_cases)/population))*100 AS HighestInfcByPop
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY HighestInfcByPop DESC


-- Listing countries with the highest death percentage and death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, (MAX(cast (total_deaths as int))/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING   MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC


-- Listing continents by highest death count

SELECT continent, MAX(cast(total_deaths as int)) AS CTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continenT
HAVING   MAX(total_deaths) IS NOT NULL
ORDER BY CTotalDeathCount DESC


-- Listing larger populations by the highest death count

SELECT location, MAX(cast(total_deaths as int)) AS CTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
HAVING   MAX(total_deaths) IS NOT NULL
ORDER BY CTotalDeathCount DESC



-- Global death percentage periodically

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date, population
HAVING SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 IS NOT NULL
ORDER BY 1

-- Total global death percentage

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 

-- Counting new vaccinations per location over time

WITH GlobalVac as
(SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations))  OVER (PARTITION BY dea.LOCATION ORDER BY dea.location, dea.date) AS TotalPopVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL  
GROUP BY dea.continent, dea.location, dea.date, population, vac.new_vaccinations
)

SELECT *
FROM GlobalVac
WHERE TotalPopVac IS NOT NULL
ORDER BY continent, location, date



-- Percentage of vaccinated people per country over time


DROP TABLE IF EXISTS #PercentPopVac
CREATE TABLE #POP
(continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
PercentPopVac numeric)


INSERT INTO #POP
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations))  OVER (PARTITION BY dea.LOCATION ORDER BY dea.location, dea.date) AS PercentPopVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL  
GROUP BY dea.continent, dea.location, dea.date, population, vac.new_vaccinations


SELECT *, (PercentPopVac/population)*100 AS percentage
FROM #POP


--- CREATING VIEW

CREATE VIEW DeathCount AS
SELECT continent, MAX(cast(total_deaths as int)) AS CTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continenT
HAVING   MAX(total_deaths) IS NOT NULL
--ORDER BY CTotalDeathCount DESC

