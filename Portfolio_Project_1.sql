SELECT total_cases, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Cyprus'
ORDER BY total_cases DESC

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--Order BY 3,4;


-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Change data type for column
ALTER TABLE PortfolioProject..CovidDeaths ALTER COLUMN total_deaths nvarchar(255)

-- Looking at Total Cases vs Population
-- Shows wtah percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulation
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND population IS NOT NULL
ORDER BY 1, 2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 
AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE population IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death Count per Population
-- Change data type for column total_deaths using CAST

SELECT location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's Break Things Down by Continent
SELECT continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases <> 0
GROUP BY date
ORDER BY 1, 2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases <> 0
ORDER BY 1, 2;

-- Skoñczy³em na 51:00 min

-- Looking on Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2, 3


-- USE CTE

WITH
PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL AND dea.location = 'Albania'
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PopvsVacs
FROM PopvsVac

-- USE TempTable

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL AND dea.location = 'Albania'

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PopvsVacs
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
-- Order by 1, 2

SELECT *
FROM PercentPopulationVaccinated