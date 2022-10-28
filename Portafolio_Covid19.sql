
SELECT*
FROM Portafolio_Project..Covid_Death

ORDER BY 3,4

--PART 1: SELECT COLUMNS TO ANALYZE

SELECT Portafolio_Project..Covid_Death.location as 'Location'
,Portafolio_Project..Covid_Death.date as 'Date'
,ISNULL(Portafolio_Project..Covid_Death.total_cases,0) as 'Total Cases'
,ISNULL(Portafolio_Project..Covid_Death.new_cases,0) as 'New Cases'
,ISNULL(Portafolio_Project..Covid_Death.total_deaths,0) as 'Total Deaths'
,ISNULL(Portafolio_Project..Covid_Death.population,0) as 'Population'

FROM Portafolio_Project..Covid_Death

ORDER BY 3,4

--PART 2: COMPARE TOTAL CASES VS TOTAL DEATHS
		   --Shows likelihood of dying if you contract covid in your country

SELECT Portafolio_Project..Covid_Death.location as 'Location'
,CONVERT(DATE,Portafolio_Project..Covid_Death.date) as 'Date'
,Portafolio_Project..Covid_Death.population as 'Population'
,ISNULL(Portafolio_Project..Covid_Death.total_cases,0) as 'Total Cases'
,ISNULL(Portafolio_Project..Covid_Death.total_deaths,0) as 'Total Deaths'
,CONCAT(ROUND(total_deaths/total_cases*100,5),'%') as 'Death %'  

FROM Portafolio_Project..Covid_Death

WHERE Portafolio_Project..Covid_Death.location LIKE '%States%'

ORDER BY 1,5 DESC

--PART 3: COMPARE TOTAL CASES VS TOTAL DEATHS
		   --Shows likelihood of dying if you contract covid in your country

SELECT Portafolio_Project..Covid_Death.location as 'Location'
,CONVERT(DATE,Portafolio_Project..Covid_Death.date) as 'Date'
,Portafolio_Project..Covid_Death.population as 'Population'
,ISNULL(Portafolio_Project..Covid_Death.total_cases,0) as 'Total Cases'
,ISNULL(Portafolio_Project..Covid_Death.total_deaths,0) as 'Total Deaths'
,CONCAT(ROUND(Portafolio_Project..Covid_Death.total_deaths/Portafolio_Project..Covid_Death.total_cases*100,5),'%') as 'Death %'  

FROM Portafolio_Project..Covid_Death

WHERE Portafolio_Project..Covid_Death.location LIKE '%States%'

ORDER BY 1,5 DESC

--PART 4: COMPARE TOTAL CASES VS POPULATION
		   --Shows what percentage of population got covid-19

SELECT Portafolio_Project..Covid_Death.location as 'Location'
,CONVERT(DATE,Portafolio_Project..Covid_Death.date) as 'Date'
,Portafolio_Project..Covid_Death.population as 'Population'
,ISNULL(Portafolio_Project..Covid_Death.total_cases,0) as 'Total Cases'
,ISNULL(Portafolio_Project..Covid_Death.total_deaths,0) as 'Total Deaths'
,CONCAT(ROUND(Portafolio_Project..Covid_Death.total_cases/Portafolio_Project..Covid_Death.population*100,5),'%') as 'Death %'  

FROM Portafolio_Project..Covid_Death

ORDER BY 1,5 DESC

--PART 5: LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Portafolio_Project..Covid_Death.location as 'Location'
,Portafolio_Project..Covid_Death.population as 'Population'
,MAX(ISNULL(Portafolio_Project..Covid_Death.total_cases,0)) as 'Highest Infection'
,MAX(Portafolio_Project..Covid_Death.total_cases/Portafolio_Project..Covid_Death.population)*100 as '% Population Infected'  

FROM Portafolio_Project..Covid_Death

--PART 6: SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT Portafolio_Project..Covid_Death.location as 'Location'
,MAX(cast(Portafolio_Project..Covid_Death.total_deaths as int)) as 'Total Death Counts'

FROM Portafolio_Project..Covid_Death

GROUP BY Portafolio_Project..Covid_Death.location
,Portafolio_Project..Covid_Death.population
,Portafolio_Project..Covid_Death.total_cases

ORDER BY MAX(cast(Portafolio_Project..Covid_Death.total_deaths as int)) DESC


--PART 7: BREAKING DOWN BY CONTINENT

SELECT 
continent as 'Continent'
,MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM Portafolio_Project..Covid_Death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC


--PART 8: GLOBAL NUMBERS

SELECT CONVERT(DATE,Portafolio_Project..Covid_Death.date) as 'Date'
,SUM(Portafolio_Project..Covid_Death.new_cases)  as 'New Cases'
,SUM(cast(Portafolio_Project..Covid_Death.new_deaths as int)) as 'New Death'
,SUM(cast(Portafolio_Project..Covid_Death.new_deaths as int))/SUM(Portafolio_Project..Covid_Death.new_cases)*100
as DeathPercentage

FROM Portafolio_Project..Covid_Death

WHERE continent IS NOT NULL 

GROUP BY Portafolio_Project..Covid_Death.date

ORDER BY 1,2 DESC

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT death.continent,
death.location,
death.date,
death.population,
CAST(vaccinations.new_vaccinations as bigint) as 'New Vaccinations',
SUM(CAST(vaccinations.new_vaccinations as bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated

FROM Portafolio_Project..Covid_Death death
JOIN Portafolio_Project..Covid_Vaccination vaccinations on death.location = vaccinations.location and death.date = vaccinations.date

WHERE death.continent IS NOT NULL

ORDER BY 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT death.continent,
death.location,
CONVERT(DATE,death.date) as 'Date',
death.population,
CAST(vaccinations.new_vaccinations as bigint) as 'New Vaccinations',
SUM(CAST(vaccinations.new_vaccinations as bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated

FROM Portafolio_Project..Covid_Death death
JOIN Portafolio_Project..Covid_Vaccination vaccinations on death.location = vaccinations.location and death.date = vaccinations.date

WHERE death.continent IS NOT NULL

)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM popvsvac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
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
SELECT death.continent,
death.location,
CONVERT(DATE,death.date) as 'Date',
death.population,
CAST(vaccinations.new_vaccinations as bigint) as 'New Vaccinations',
SUM(CAST(vaccinations.new_vaccinations as bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated

FROM Portafolio_Project..Covid_Death death
JOIN Portafolio_Project..Covid_Vaccination vaccinations on death.location = vaccinations.location and death.date = vaccinations.date

WHERE death.continent IS NOT NULL

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS

SELECT death.continent,
death.location,
CONVERT(DATE,death.date) as 'Date',
death.population,
CAST(vaccinations.new_vaccinations as bigint) as 'New Vaccinations',
SUM(CAST(vaccinations.new_vaccinations as bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated

FROM Portafolio_Project..Covid_Death death
JOIN Portafolio_Project..Covid_Vaccination vaccinations on death.location = vaccinations.location and death.date = vaccinations.date

WHERE death.continent IS NOT NULL
