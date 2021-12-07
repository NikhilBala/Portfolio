--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs. Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2;

-- Looking at Total Cases vs. Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as Case_Rate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 2;

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)*100) as Infection_Rate
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC;


-- Looking at Countries with the Highest Death Rate 

SELECT location, MAX(CAST(total_deaths AS INT)) AS DeathCount, MAX((total_deaths/population)*100) as Death_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 2 DESC;

-- Looking at Continents with Highest Death Rate

SELECT location, MAX(CAST(total_deaths AS INT)) AS DeathCount, MAX((total_deaths/population)*100) as Death_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY 2 DESC;

-- Alternate test

SELECT continent, MAX(CAST(total_deaths AS INT)) AS DeathCount, MAX((total_deaths/population)*100) as Death_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
GROUP BY continent
ORDER BY 2 DESC;

-- Global Numbers

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Lethality_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Joining two tables

SELECT *
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacc
ON Death.location = Vacc.location
AND Death.date = Vacc.date

-- Looking at Total Population vs. Vaccinations

SELECT Death.continent, death.location, death.date, death.population, vacc.new_vaccinations
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacc
ON Death.location = Vacc.location
AND Death.date = Vacc.date
WHERE death.continent IS NOT NULL 
ORDER BY 2,3

-- Summing vaccinations per country

SELECT Death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinations,
--(death.Rolling_Vaccinations/death.population)*100 AS "Vax/Death Ratio"
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacc
ON Death.location = Vacc.location
AND Death.date = Vacc.date
WHERE death.continent IS NOT NULL 
ORDER BY 2,3

-- USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_Vaccinations)
AS
(
SELECT Death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinations
--(Rolling_Vaccinations/death.population)*100 AS "Vax/Death Ratio"
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacc
ON Death.location = Vacc.location
AND Death.date = Vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_Vaccinations/Population)*100 AS "Vax_Death Ratio"
FROM PopVsVac

-- Create a VIEW for later visualization

CREATE VIEW PopVsVac AS
SELECT Death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinations
--(Rolling_Vaccinations/death.population)*100 AS "Vax/Death Ratio"
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacc
ON Death.location = Vacc.location
AND Death.date = Vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3


