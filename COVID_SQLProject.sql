SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3, 4

--Data used:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

--Total cases vs Total Deaths
--COVID Mortality Rate in my country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as CovidMortalityRate
FROM PortfolioProject..CovidDeaths$
--Filter Location using WHERE
WHERE location like '%Philippines%'
ORDER BY 1, 2

--Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases / population) * 100 as CovidPopulationPercentage
FROM PortfolioProject..CovidDeaths$
--Filter Location using WHERE
WHERE location like '%Philippines%'
ORDER BY 1, 2

--Countries with the highest infection rate vs population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as CovidPopulationPercentage
FROM PortfolioProject..CovidDeaths$
--Filter Location using WHERE
--WHERE location like '%Philippines%'
GROUP BY location, population
ORDER BY CovidPopulationPercentage DESC

--Countries with the highest Mortality Rate
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount desc

--Breakdown by Continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY  location
ORDER BY TotalDeathCount desc

------------------------------------

--Global numbers per day
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%Philippines%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3

--CTE
WITH PopVsVax (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaxedPeoplePercentage
FROM PopVsVax

--Temp Table
--For alterations, uncomment:
--DROP Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaxedPeoplePercentage
FROM #PercentPopulationVaccinated

--View for data storage for vizzes

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3