-- Test  For CovidDeaths
SELECT * 
FROM Test..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4



--SELECT * 
--FROM Test..CovidVaccinations
--ORDER BY 3,4

-- Selecting data that we are going to use.

SELECT
	location, date, total_cases, new_cases, total_deaths, population
FROM Test..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- How many cases in the country and how many deaths for entire 
-- populations with the percentage
-- Shows Likelihood of dying if you contract COVID in your country

SELECT
	location, date, total_cases, total_deaths,
	(total_deaths/total_cases) * 100 AS DeathPercentange
FROM Test..CovidDeaths
WHERE location = 'India'
--AND location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- What Percentage of Population got COVID.


SELECT
	location, date, total_cases, population,
	(total_cases/population) * 100 AS PercentPopulationInfected
FROM Test..CovidDeaths
--WHERE location = 'India'
--AND location LIKE '%states%'
ORDER BY 1,2

-- Country with highest Infection Rate Compared to Population

SELECT
	location, MAX(total_cases) AS HishestInfectionCount,
	population,MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM Test..CovidDeaths
WHERE location in( 'China', 'India','United States', 'New Zealand','Italy','United Kingdom') 
--AND location LIKE '%states%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Countries with the highest death count per popultion

SELECT
	location, MAX(Convert(INT,total_deaths)) AS TotalDeathCount
	--MAX((total_deaths/population)) * 100 AS PercentPopulationDeath
FROM Test..CovidDeaths
-- WHERE continent IS NOT NULL
WHERE location in( 'China', 'India','United States', 'New Zealand','Italy','United Kingdom') 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continent with the highest Death Count

SELECT
	continent, MAX(Convert(INT,total_deaths)) AS TotalDeathCount
	--,MAX((total_deaths/population)) * 100 AS PercentPopulationDeath
FROM Test..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers  

SELECT
	  SUM(new_cases) AS TotalCase, SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
	 SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS PercentDeath
FROM Test..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- Test  For CovidVaccinations

SELECT * 
FROM Test..CovidVaccinations
ORDER BY 3,4

-- Joining both the tables together CovidVaccinations And CovidDeaths

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Test..CovidDeaths dea
Join Test..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- Rolling Count using Over Clause and PARTITION By

SELECT dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER
	(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCount
FROM Test..CovidDeaths dea
Join Test..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- Creating CTE (Common Table Expressions)

 WITH PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
	AS (
SELECT 
	dea.continent,dea.location, dea.date , dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) 
	OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM Test..CovidDeaths dea
JOIN Test..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/ population) * 100 
FROM PopvsVac


--CTE for Total population VS Vaccinations

 WITH PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
	AS (
SELECT 
	dea.continent,dea.location, dea.date , dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) 
	OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM Test..CovidDeaths dea
JOIN Test..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/ population) * 100 AS PercentVaccinated
FROM PopvsVac


-- Creating Temp Table
--Total population VS Vaccinations


DROP TABLE if exists #PercentPopulationVaccinated
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
SELECT 
	dea.continent,dea.location, dea.date , dea.population, 
	vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
	OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM Test..CovidDeaths dea
JOIN Test..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT * , (RollingPeopleVaccinated/ population) * 100
FROM #PercentPopulationVaccinated
