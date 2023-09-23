SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Romania'
ORDER BY 1,2

SELECT location, date, Population,total_cases, (total_cases/population)*100 AS CasesPerPopulation
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Romania'
WHERE location <> continent
ORDER BY 1,2

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS MaxCasesPerPopulation
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Romania'
WHERE location <> continent
GROUP BY location, Population
ORDER BY MaxCasesPerPopulation DESC


SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Romania'
WHERE location <> continent
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE location <> continent
ORDER BY 3,4

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Romania'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT cd.continent ,cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths cd
INNER JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3



--USE CTE


WITH PopVsVac (continent, location, date, population, new_vaccinations ,RollingPeopleVaccinated)
as
(
SELECT cd.continent ,cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths cd
INNER JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageOfPopVaccinated
FROM PopVsVac 


--TEMP table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent ,cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths cd
INNER JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageOfPopVaccinated
FROM #PercentPopulationVaccinated 
order by 2,3


-- Create view to store data later for visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent ,cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths cd
INNER JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated