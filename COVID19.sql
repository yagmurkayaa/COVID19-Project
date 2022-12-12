select * from COVID19..CovidDeaths
order by 3,4


-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from COVID19..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVID19..CovidDeaths
order by 1,2


 -- Looking at Countries with highest Infection Rate compared to Population

 
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from COVID19..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select location, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDeath
from COVID19..CovidDeaths
Group by location, population
order by TotalDeathCount desc

--Showing continent with Highest Death Count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from COVID19..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from COVID19..CovidDeaths
where continent is not null
group by date
order by 1,2


--Total Cases and Total Deaths in the World
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from COVID19..CovidDeaths
where continent is not null
order by 1,2


--Showing the total population vs vaccinations
With PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from COVID19..CovidDeaths dea 
join COVID19..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)

select *, (RollingPeopleVaccinated/population)*100 from PopvsVac


--TEMP TABLE

create table  #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated  numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from COVID19..CovidDeaths dea 
join COVID19..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from COVID19..CovidDeaths dea 
join COVID19..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2

select * from PercentPopulationVaccinated



 