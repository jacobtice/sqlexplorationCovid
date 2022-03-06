 /*

This script containes queries on COVID data for https://ourworldindata.org/coronavirus taken from the graph showing daily confirmed cases of COVID. 
This data was imported into a database on SMSS to run these queries. 
The numbered queries are used for the tableau dashboard

 */

--1

 SELECT	SUM(new_cases) AS total_cases,
		SUM(new_deaths) AS total_deaths,
		(SUM(new_deaths)*1.0 / SUM(new_cases)*1.0) * 100 AS death_rate
  FROM portfolio_project.dbo.covid_deaths
 WHERE continent IS NOT NULL
 ORDER BY 1,2
-- Google search as of 2/27/22 confirms these numbers for total cases and total deaths worldwide

--2

SELECT location,
	   SUM(new_deaths) AS total_death_count
  FROM portfolio_project.dbo.covid_deaths
 WHERE continent IS NULL
   AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income') -- Filtering out some locations that are aggregates of existing locations
 GROUP BY location
 ORDER BY total_death_count DESC
-- Google search 2/27/22 total deaths in US: 947k

--3

SELECT location,
	   population,
	   MAX(total_cases) AS highest_infection_count,
	   MAX(total_cases*1.0 / population*1.0) * 100 AS percent_infected
  FROM portfolio_project.dbo.covid_deaths
 WHERE continent IS NOT NULL
   AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income') -- Filtering out some locations that are aggregates of existing locations
 GROUP BY location, population
 ORDER BY 3 DESC

--4


SELECT location, 
	   population,
	   date, 
	   MAX(total_cases) as highest_infection_count,  
	   MAX((total_cases*1.0 / population*1.0)*100) as percent_population_inected
  FROM portfolio_project.dbo.covid_deaths
 WHERE continent IS NOT NULL
   AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income') -- Filtering out some locations that are aggregates of existing locations
 GROUP BY location, population, date
 ORDER BY 4 desc


-- EXPLORING DATA BELOW

SELECT location,
	   date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
 FROM portfolio_project.dbo.covid_deaths
ORDER BY 1,2

-- total cases vs total deaths

SELECT location,
	   date,
	   total_cases,
	   total_deaths,
	   (total_deaths*1.0 / total_cases*1.0) * 100 AS death_prob
 FROM portfolio_project.dbo.covid_deaths
ORDER BY 1,2

-- total cases vs population

SELECT location,
	   date,
	   total_cases,
	   population,
	   (total_cases*1.0 / population*1.0) * 100 AS case_proportion
 FROM portfolio_project.dbo.covid_deaths
WHERE location LIKE '%states%' 
ORDER BY 1,2

-- Looking at countries with the highest infection rate

SELECT location,
	   population,
	   MAX(total_cases) AS highest_case_count,
	   MAX((total_cases*1.0 / population*1.0) * 100) AS case_proportion
 FROM portfolio_project.dbo.covid_deaths 
GROUP BY location, population
ORDER BY 4 DESC

-- Looking at countries with the highest deaths per population

SELECT location,
	   population,
	   MAX(total_deaths) AS highest_deaths,
	   MAX((total_deaths*1.0 / population*1.0) * 100) AS death_rate
 FROM portfolio_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Now with continents

SELECT continent,
	   MAX(total_deaths) AS highest_deaths,
	   MAX((total_deaths*1.0 / population*1.0) * 100) AS death_rate
 FROM portfolio_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 3 DESC


-- GLOBAL NUMBERS

SELECT date,
	   SUM(new_cases) AS total_cases_world,
	   SUM(new_deaths) AS total_deaths_world,
	   (SUM(new_deaths)*1.0 / SUM(new_cases)*1.0) * 100 AS death_rate_world
 FROM portfolio_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total population vs Vaccinated

SELECT death.continent,
	   death.location,
	   death.date,
	   death.population,
	   vax.new_vaccinations,
	   SUM(vax.new_vaccinations) 
		OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_vaccinated,
	   ((SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date))*1.0 / death.population*1.0)*100 AS percent_vaccinated
 FROM portfolio_project.dbo.covid_deaths death
 JOIN portfolio_project.dbo.covid_vaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date
 WHERE death.continent IS NOT NULL
 ORDER BY 2,3

 -- Creating view for visualizations

 CREATE VIEW percent_pop_vaccinated AS
 SELECT death.continent,
	   death.location,
	   death.date,
	   death.population,
	   vax.new_vaccinations,
	   SUM(vax.new_vaccinations) 
		OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_vaccinated,
	   ((SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date))*1.0 / death.population*1.0)*100 AS percent_vaccinated
 FROM portfolio_project.dbo.covid_deaths death
 JOIN portfolio_project.dbo.covid_vaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date
 WHERE death.continent IS NOT NULL
 --ORDER BY 2,3


 