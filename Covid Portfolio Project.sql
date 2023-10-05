Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- selecting the data I'm going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at death percentage of covid cases
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
order by 1,2


-- Total cases vs population
-- Shows what percentage of population got covid throughout all the dates im the UK

Select location, date, total_cases,population, 
(total_cases /population ) * 100 as CovidPercentage
from PortfolioProject..covidDeaths
Where Location like 'United Kingdom'
order by 1,2

-- Countries with highest infection rate

Select location, Population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))* 100 AS PercentPopulationInfected
From PortfolioProject..covidDeaths
Group by location, population, date
Order by PercentPopulationInfected DESC

--Countries with Highest DeathCount

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
AND continent <> ''
Group By location
Order By TotalDeathCount DESC

-- Total Death count by Continent

Select continent, SUM(cast(new_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
AND continent <> ''
Group By continent
Order By TotalDeathCount DESC

With BOOK
AS (Select *, 
CASE when continent = '' Then location ELSE continent 
END AS region
From PortfolioProject..CovidDeaths)
Select Region, SUM(cast(new_deaths as int)) AS TotalDeaths
From book
Group BY region
HAVING region IN ('North America', 'Africa', 'Europe', 'Asia', 'South America','Oceania')


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as TotalDeathCount, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

--Total population VS Vaccinations with JOIN Clause

With PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
AND dea.continent <> ''
--ORDER BY 2,3
)




--Creating View for visualisation

Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null