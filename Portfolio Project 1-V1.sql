
-- Looking at CovidDeaths Table

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Selecting data that we are going to be using

SELECT 
	Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total cases Vs Total Deaths(Calculation Percentage of people died)
-- Shows likelihood of dying if you contract COVID in your country

SELECT 
	Location, date, total_cases, total_deaths, ((total_deaths / total_cases) * 100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%' 
ORDER BY 1,2


-- Looking at Total Cases VS Population
-- Shows what percentage of population got COVID

SELECT 
	Location, date, total_cases, total_deaths,population, ((total_cases / population)*100) AS PercentPopluationInfected
FROM PortfolioProject..CovidDeaths
WHERE location =  'India' 
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT 
	Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopluationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%' 
GROUP BY Location, Population
ORDER BY PercentPopluationInfected DESC

-- Showing countries with the Highest Death Count per Population
SELECT 
	Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%' 
WHERE continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Showing the continents with highest death count
SELECT 
	continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%' 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS With date

SELECT 
	  date,SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- GLOBAL NUMBERS Without date

SELECT 
	  SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2  


-- Looking at Total Population vs Vaccinations

SELECT 
	dea.continent,dea.location, dea.date , dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) 
	OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USING CTE
 WITH PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
	AS (
SELECT 
	dea.continent,dea.location, dea.date , dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) 
	OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/ population) * 100 
FROM PopvsVac
	

-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
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
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) 
	OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/ population) * 100 
FROM #PercentPopulationVaccinated
	



-- Creating View to store data for later
 
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,dea.location, dea.date , dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) 
	OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated


CREATE VIEW TotalDeathCount AS
SELECT 
	continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%' 
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC

SELECT *
FROM TotalDeathCount
