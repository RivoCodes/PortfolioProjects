select * from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from PortofolioProject..CovidVaccinations
--order by 3,4

--select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--country with highest infection rate compared to population
select location, population,MAX (total_cases) as HighestInfectionCount,max ((total_cases/population))*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--break things down by continent
--showing continents with the highest death per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select  sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking total population vs vacctinations
SET ANSI_WARNINGS OFF
GO
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	from PortofolioProject..CovidDeaths dea
	join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
) select *, (RollingPeopleVaccinated/population)*100 from PopvsVac


--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	from PortofolioProject..CovidDeaths dea
	join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated

--creating view to store data for later visualization

use PortofolioProject
drop view if exists PercentPopulationVaccinated
create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	from PortofolioProject..CovidDeaths dea
	join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	GO
	--order by 2,3

	select * from PercentPopulationVaccinated