--Looking at the Data
SELECT [location]
	,[continent]
	,[date]
	,[total_cases]
	,[new_cases]
	,[total_deaths]
	,[population]
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2
--note: continent is null when location is continent


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT [location]
	,[date]
	,[total_cases]
	,[total_deaths]
	,([total_deaths]/[total_cases])*100 As DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE [location] like '%states%'
ORDER BY 1, 2


--Looking at Total Cases vs Population
--Show what percentage of the population has gotten covid
SELECT [location]
	,[date]
	,[total_cases]
	,[population]
	,([total_cases]/[population])*100 As InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE [location] like '%states%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population
SELECT [location]
	,MAX([total_cases]) as HighestInfectionCount
	,[population]
	,MAX(([total_cases]/[population]))*100 As InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE [continent] is not null
GROUP BY [location], [population]
ORDER BY InfectionPercentage DESC

--Looking at countries with the highest death count per population
SELECT [location]
	,MAX([total_deaths]) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE [continent] is not null
GROUP BY [location]
ORDER BY TotalDeathCount DESC


--LETS BREAK THINGS DOWN BY CONTINENT


--showing continents with the highest death count
SELECT [location]
	,MAX([total_deaths]) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE [continent] is null
GROUP BY [location]
ORDER BY TotalDeathCount DESC

--Shows likelihood of dying if you contract covid in your continent
SELECT [location]
	,[date]
	,[total_cases]
	,[total_deaths]
	,([total_deaths]/[total_cases])*100 As DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE [continent] is null and [total_deaths] is not null
ORDER BY 1, 2


--Looking at Total Cases vs Population
--Shows what percentage of the continental population has gotten covid
SELECT [location]
	,[date]
	,[total_cases]
	,[population]
	,([total_cases]/[population])*100 As InfectionPercentage
FROM PortfolioProject.CovidDeaths
WHERE [continent] is null and [total_cases] is not null
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population
SELECT [location]
	,MAX([total_cases]) as HighestInfectionCount
	,[population]
	,MAX(([total_cases]/[population]))*100 As InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE [continent] is  null
GROUP BY [population], [location]
ORDER BY InfectionPercentage DESC

--Looking at countries with the highest death count per population
SELECT [location]
	,MAX([total_deaths]) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE [continent] is null
GROUP BY [location]
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT [date]
	,SUM(new_cases) as TotalCases
	,SUM(CAST (new_deaths as int)) as TotalDeaths
	,SUM(CAST (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE [continent] is not null and new_cases != 0
GROUP BY [date]
ORDER BY 1, 2
--why are there negative deaths??

--looking at Total Population vs Vaccinations
SELECT dea.continent
	,dea.[location]
	,dea.[date]
	,vac.new_vaccinations
	,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.[location] ORDER BY dea.[location], dea.[date]) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location and dea.[date] =vac.[date]
WHERE dea.continent is not null
ORDER BY 2, 3

--USE CTE to see percentage
WITH PopvsVac (continent 
	,[location]
	,[date]
	,[population]
	,new_vaccinations
	,RollingPeopleVaccinated)
AS
(SELECT dea.continent
	,dea.[location]
	,dea.[date]
	,dea.[population]
	,vac.new_vaccinations
	,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.[location] ORDER BY dea.[location], dea.[date]) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location and dea.[date] =vac.[date]
WHERE dea.continent is not null)

SELECT * 
	,(RollingPeopleVaccinated/[population])*100
FROM PopvsVac


--creating view to store data for viz


CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent
	,dea.location
	,dea.[date]
	,dea.population
	,vac.new_vaccinations
	,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.[location], dea.[date]) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location and dea.[date] =vac.[date]
WHERE dea.continent is not null
