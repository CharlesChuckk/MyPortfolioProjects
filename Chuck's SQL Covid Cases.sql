select *
from [CovidDeathspart2modified]
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from [CovidDeathspart2modified]
order by 1,2
	
--Ratio of deaths to covid cases in Nigeria
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/ NULLIF (CONVERT(float, total_cases),0))*100
as Deathpercentage
from [Ekoyo's Portfolio Projects].dbo.[CovidDeathspart2modified]
where location = 'nigeria'
order by 1,2

--Percentage of population with COVID in the USA
SELECT location, date,  population, total_cases, (CONVERT(float,total_cases)/ NULLIF (CONVERT(float,population ),0))*100
as PopulationPercentage
from [Ekoyo's Portfolio Projects].dbo.[CovidDeathspart2modified]
where location like '%states%'

--Countries with highest infection rate
SELECT location, population, max (total_cases) as HighestInfectionCount,  max ((CONVERT(float,total_cases)/ NULLIF (CONVERT(float,population ),0)))*100
as InfectionPercentage
from [Ekoyo's Portfolio Projects].dbo.[CovidDeathspart2modified]
group by location, population
order by  InfectionPercentage desc

--Countries with highest death rate
SELECT location, max (total_deaths) as TotalDeathCount
from [Ekoyo's Portfolio Projects].dbo.[CovidDeathspart2modified]
where continent <> ' '
group by location
order by  TotalDeathCount desc 

--by continents
SELECT continent, max (total_deaths) as TotalDeathCount
from [Ekoyo's Portfolio Projects].dbo.[CovidDeathspart2modified]
where continent <> ' '
group by continent
order by  TotalDeathCount desc 


--Global numbers
SELECT date, sum(cast(new_cases as int)) as totalcases, sum(cast(new_deaths as int)) as totaldeaths,  sum(CONVERT(float,new_deaths ))/ sum (NULLIF (CONVERT(float,new_cases),0))*100 as DeathPercentage
from [Ekoyo's Portfolio Projects].dbo.[CovidDeathspart2modified]
where continent <> ' '
group by date
order by 1,2

SELECT  sum(cast(new_cases as int)) as totalcases, sum(cast(new_deaths as int)) as totaldeaths,  sum(CONVERT(float,new_deaths ))/ sum (NULLIF (CONVERT(float,new_cases),0))*100 as DeathPercentage
from [Ekoyo's Portfolio Projects].dbo.[CovidDeathspart2modified]
where continent <> ' '
--group by date
order by 1,2

--Total population vs vaccinations
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over(partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
--, (SumofVaccinations/population)*100
from CovidDeathspart2modified deaths
join CovidVaccinationss vac
on deaths.location= vac.location
and deaths.date= vac.date
where deaths.continent<> ' ' and deaths.location= 'nigeria'
order by 2,3

--Total population vs vaccinations with CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over(partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
--, (SumofVaccinations/population)*100
from CovidDeathspart2modified deaths
join CovidVaccinationss vac
on deaths.location= vac.location
and deaths.date= vac.date
where deaths.continent<> ' ' and deaths.location= 'nigeria'
--order by 2,3
)
select *, (CONVERT(float,RollingPeopleVaccinated/ NULLIF (CONVERT(float, population),0))*100)
from PopvsVac

--with Temptables
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int, 
RollingPeopleVaccinated int)

insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over(partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
--, (SumofVaccinations/population)*100
from CovidDeathspart2modified deaths
join CovidVaccinationss vac
on deaths.location= vac.location
and deaths.date= vac.date
where deaths.continent<> ' ' and deaths.location= 'nigeria'
--order by 2,3
select *, (CONVERT(float,RollingPeopleVaccinated/ NULLIF (CONVERT(float, population),0))*100) as PercentVaccinated
from #PercentPopulationVaccinated

--create view for visualization
create view PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over(partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
from CovidDeathspart2modified deaths
join CovidVaccinationss vac
on deaths.location= vac.location
and deaths.date= vac.date
where deaths.continent<> ' ' and deaths.location= 'nigeria'

--create view for visualization 2
create view 
TotalDeathsbyContinent as
SELECT continent, max (total_deaths) as TotalDeathCount
from [Ekoyo's Portfolio Projects].dbo.[CovidDeathspart2modified]
where continent <> ' '
group by continent
--order by  TotalDeathCount desc
