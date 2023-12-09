-- Phase 1: General Questions for Exploring Covid-19 Dataset (General SQL queries & cleaning data)

-- Exploring the time it takes for deaths to occur after new cases
SELECT location, date, population, new_cases, total_cases, total_deaths
FROM deaths

-- Calculating the percentage of deaths among total cases for each location
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100)
FROM deaths

-- Calculating the percentage of the population that contracted COVID-19
SELECT location, date, total_cases, population, ((total_cases/population)*100)
FROM deaths

-- Finding the country with the highest infection rate compared to population
SELECT location, population, total_cases, (max(total_cases/population)*100)
FROM deaths

-- Grouping countries by location and population to find the highest infection rates
SELECT location, population, total_cases, (max(total_cases/population)*100)
FROM deaths
GROUP BY location, population
ORDER BY (max(total_cases/population)*100) DESC

-- Finding the country with the highest total deaths
SELECT location, max(total_deaths)
FROM deaths

-- Grouping countries to find the highest total deaths
SELECT location, max(total_deaths)
FROM deaths
GROUP BY location
ORDER BY max(total_deaths) DESC

-- Cleaning the data to exclude entries where continent is reflected as location
SELECT *
FROM deaths
WHERE continent IS NOT NULL

-- Finding the country with the highest total deaths after cleaning the data
SELECT location, max((total_deaths ))
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max(total_deaths) DESC

-- Finding the total deaths for continents
SELECT location, max((total_deaths))
FROM deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY max(total_deaths) DESC

-- Phase 2: Understanding Covid Cases by Continental Impact

-- Finding the countries/regions with the highest total deaths without considering continents
SELECT location, max((total_deaths))
FROM deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY max(total_deaths) DESC

-- Analyzing the growth rate of COVID-19 cases globally
SELECT date, sum(new_cases), sum(new_deaths), sum(new_deaths)/sum(new_cases)*100
FROM deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Phase 3: Joining Deaths and Vaccinations Tables

-- Joining the deaths and vaccinations tables
SELECT *
FROM Vaccinations
JOIN deaths
    ON deaths.location = Vaccinations.location
    AND deaths.date = Vaccinations.date

-- Finding the total vaccinations per continent
SELECT deaths.continent, deaths.location, deaths.population, Vaccinations.new_vaccinations
FROM Vaccinations
JOIN deaths
    ON deaths.location = Vaccinations.location
    AND deaths.date = Vaccinations.date
WHERE deaths.continent IS NOT NULL
ORDER BY 1,2,3

-- Calculating the rolling total of vaccinated people per location
SELECT deaths.continent, deaths.location, deaths.population, Vaccinations.new_vaccinations,
 sum(Vaccinations.new_vaccinations) OVER (PARTITION by deaths.location ORDER by deaths.location,
  deaths.date) as RollingPeopleVaccinnated
FROM Vaccinations
JOIN deaths
    ON deaths.location = Vaccinations.location
    AND deaths.date = Vaccinations.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2, 3

-- Creating a view for the rolling total of vaccinated people
CREATE VIEW RollingPeopleVaccinnated as
SELECT deaths.continent, deaths.location, deaths.population, Vaccinations.new_vaccinations,
 sum(Vaccinations.new_vaccinations) OVER (PARTITION by deaths.location ORDER by deaths.location,
  deaths.date) as RollingPeopleVaccinnated
FROM Vaccinations
JOIN deaths
    ON deaths.location = Vaccinations.location
    AND deaths.date = Vaccinations.date
WHERE deaths.continent IS NOT NULL

-- Conclusions:

-- In Phase 1, we explored COVID-19 data by looking at new cases, total cases, total deaths, and calculated percentages.
-- We also identified countries with the highest infection rates and total deaths.
-- Cleaning the data involved excluding entries where the continent was reflected as the location.

-- Phase 2 focused on understanding COVID cases by continental impact, analyzing growth rates, and calculating global growth rates.

-- Phase 3 involved joining the deaths and vaccinations tables, exploring the total vaccinations per continent, and creating a view for the rolling total of vaccinated people.

-- These queries provide insights into the COVID-19 datasets, helping to identify trends, correlations, and patterns.
