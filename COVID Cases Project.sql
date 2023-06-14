--SELECT *
--FROM PortfolioProject..CovidDeaths;

--SELECT *
--FROM PortfolioProject..CovidVaccinations;

---Select Data that we will use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

---Total Cases vs Total Deaths

SELECT Location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercetage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%States%'
ORDER BY 1,2;

-- Total Cases vs Population
SELECT Location, date, total_cases , population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%States%'
ORDER by 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT Location, MAX((total_cases/population)*100)
FROM PortfolioProject..CovidDeaths
GROUP BY Location
ORDER BY 2 desc


-- Countries with Highest Death Count per Population

SELECT Location, MAX (CAST(total_deaths AS INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent is NOT NULL
AND total_deaths >0 -- remove NULL
GROUP BY Location
ORDER by 2 desc


-- Showing contintents with the highest death count per population

SELECT Continent, MAX (CAST(total_deaths AS INT)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent is NOT NULL
GROUP BY Continent
ORDER BY 2 desc

--SELECT Location, MAX (CAST(total_deaths AS INT)) TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE Continent is  NULL
--GROUP BY Location
--ORDER by 2 desc

-- GLOBAL NUMBERS

SELECT date, SUM(CAST (total_cases AS INT)) , SUM(CAST (total_deaths AS INT))
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2;

SELECT Date , SUM(new_cases) as TotalCases , SUM( CAST(new_deaths AS INT)) as TotalDeath,SUM( CAST(new_deaths AS INT))/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2;

-----Total Population vs Vaccinations
 
 SELECT *
FROM PortfolioProject..CovidDeaths;

SELECT *
FROM PortfolioProject..CovidVaccinations;

SELECT d.continent, d.Location ,d.date, d.population, v.total_vaccinations
FROM PortfolioProject..CovidDeaths d LEFT JOIN PortfolioProject..CovidVaccinations v
ON d.location =v.location
and d.date = v.date
WHERE d.continent is not null
ORDER BY 1,2,3
-------------------Rolling Count

SELECT d.continent, d.Location ,d.date, d.population, v.new_vaccinations
,SUM(CAST (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) "Rolling Vaccinated Count"
FROM PortfolioProject..CovidDeaths d LEFT JOIN PortfolioProject..CovidVaccinations v
ON d.location =v.location
and d.date = v.date
WHERE d.continent is not null
ORDER BY 1,2,3

---- Vaccination vs Population
With rc AS 
(SELECT d.continent, d.Location "location" ,d.date "date", d.population "population" , v.new_vaccinations
,SUM(CONVERT (int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) "Rolling Vaccinated Count"
FROM PortfolioProject..CovidDeaths d LEFT JOIN PortfolioProject..CovidVaccinations v
ON d.location =v.location
and d.date = v.date
WHERE d.continent is not null
)

SELECT  rc.location, rc.date, (rc."Rolling Vaccinated Count"/rc."population") *100
FROM rc

--- Max % by location
With rc AS 
(SELECT d.continent, d.Location "location" ,d.date "date", d.population "population" , v.new_vaccinations
,SUM(CONVERT (int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) "Rolling Vaccinated Count"
FROM PortfolioProject..CovidDeaths d LEFT JOIN PortfolioProject..CovidVaccinations v
ON d.location =v.location
and d.date = v.date
WHERE d.continent is not null
)

SELECT  rc.location, MAX( (rc."Rolling Vaccinated Count"/rc."population") *100)
FROM rc
GROUP BY rc.location

---- Vaccination vs Population (second way) 
DROP TABLE IF EXISTS
CREATE TABLE #PercentPolpulationVaccinated
( Continent nvarchar(25),
Location nvarchar(25),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


SET ANSI_WARNINGS OFF; -- error due NULL Values
GO

INSERT INTO #PercentPolpulationVaccinated
SELECT d.continent, d.Location ,d.date, d.population, v.new_vaccinations
,SUM(CAST (v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) "Rolling Vaccinated Count"
FROM PortfolioProject..CovidDeaths d LEFT JOIN PortfolioProject..CovidVaccinations v
ON d.location =v.location
and d.date = v.date
WHERE d.continent is not null


SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPolpulationVaccinated

-----------------
DROP TABLE IF EXISTS
CREATE TABLE #PercentPolpulationVaccinated
( Continent nvarchar(25),
Location nvarchar(25),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


SET ANSI_WARNINGS OFF; -- error due NULL Values
GO

INSERT INTO #PercentPolpulationVaccinated
SELECT d.continent, d.Location ,d.date, d.population, v.new_vaccinations
,SUM(CAST (v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) "Rolling Vaccinated Count"
FROM PortfolioProject..CovidDeaths d LEFT JOIN PortfolioProject..CovidVaccinations v
ON d.location =v.location
and d.date = v.date
--WHERE d.continent is not null


SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPolpulationVaccinated


-------Creating view to store data for viz

CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.Location ,d.date, d.population, v.new_vaccinations
,SUM(CAST (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) "Rolling Vaccinated Count"
FROM PortfolioProject..CovidDeaths d LEFT JOIN PortfolioProject..CovidVaccinations v
ON d.location =v.location
and d.date = v.date
WHERE d.continent is not null
---ORDER BY 1,2,3

SELECT *
FROM PercentPopulationVaccinated