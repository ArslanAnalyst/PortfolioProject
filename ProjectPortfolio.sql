select * 
from CovidDeaths
order by 3,4

--select * 
--from CovidVaccintion
--order by 3,4

--Select data that we are  going to  using

-- Total deaths vs Total Cases

select location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases) as Deathspercentage 
from CovidDeaths
where location like '%stan%'
order by 1,2

--total cases vs population
-- show what percentage of popualation got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
--where location like '%nia%'
order by 1,2

--show countries with high infection rate compare to population


select location, population, max(total_cases) as HighesInfectedCount, (max(total_cases)/population)*100
as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
--where location like '%nia%'
group by location, population 
order by PercentPopulationInfected desc

--Showing countries with highest death count

select location, max(cast(total_deaths as int)) as TotalDeathCount  
from PortfolioProject..CovidDeaths
--where location like '%nia%'
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S break things down by CONTINENT

select continent, max(cast(total_deaths as int)) as TotalDeathCount  
from PortfolioProject..CovidDeaths
--where location like '%nia%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global  Numbers

select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from CovidDeaths
--where location like '%stan%'
where continent is not null
--group by date
order by 1,2

--Looking Total Population Vs Vaccination

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccintion vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

-- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
newvaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccintion vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--create View to store data for later visualisations

Create View PercentPopulationVaccinated 
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccintion vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated
