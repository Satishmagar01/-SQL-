use [Portfolio project]
select * from coviddeaths
order by 3,4;

--select * from covidvaccination
--order by 3,4

select location,total_cases,total_deaths,new_cases,population from coviddeaths
order by 1,2;

--looking at total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from coviddeaths
order by 1,2
--above code not working cause change of col type so i type another code
--this is new code
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS death_percentage
FROM 
    coviddeaths
ORDER BY 
    location,
    date;
 sp_help coviddeaths;
 --i change col type so that i dont need to type exta code again an again
 ALTER TABLE coviddeaths
ALTER COLUMN total_deaths float;

 ALTER TABLE coviddeaths
ALTER COLUMN total_cases float;
--now this code will run easily
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from coviddeaths
where location like 'India'
order by 1,2

--it shows what percentage of population got corona
select location,date,population,total_cases , (total_cases/population)*100 as infected_percentage
from coviddeaths
where location like '%india%'
order by 1,2

--highest innfection as per population
select location,population,max(total_cases) as highestCase , max((total_cases/population)*100) as infected_percentage
from coviddeaths
group by location,population
order by infected_percentage desc

--highest deaths per location
select location , max(total_deaths) as highestDeath
from coviddeaths
where continent is not null
group by location,population
order by highestDeath desc

--highest deaths count by continent
select continent , max(total_deaths) as highestDeath
from coviddeaths
where continent is not null
group by continent
order by highestDeath desc

--global numbers
select sum(new_cases) as cases,sum(new_deaths) as Deaths
, sum(new_deaths)/ sum(new_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
--group by date 
order by 1 ,2

--number of perople vaccinations over world
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from coviddeaths dea
join covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3




Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

--DROP Table #PercentPopulationVaccinated 

Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

