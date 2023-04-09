
select * 
from PortfolioProjects..CovidDeaths where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths where continent is not null
order by 1,2

--looking at total cases vs total deaths
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2


--loking at total casese vs total populations
--show percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as got_covid
from PortfolioProjects..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to populations
select location, population, MAX(total_cases) as highestinfectioncountry, 
Max((total_cases/population))*100 as got_covid
from PortfolioProjects..CovidDeaths
where continent is not null
group by location, population
order by 4 desc

--showing countries with highest desath count per populations
 select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..CovidDeaths
where continent is not null
group by location
order by 2 desc


--let's break things down by continent
--showing contintents with the highest death count per population
 select continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Global Numers
 select date, sum(new_cases) as total_cases,sum(CAST(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null
group by date
order by 1,2

--count total deaths worldwide over total_cases
 select sum(population)as total_population,sum(new_cases) as total_cases,sum(CAST(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2


--covidVaccinations
select * 
from PortfolioProjects..CovidVaccinations
order by 3,4

--join both the table
select * 
from PortfolioProjects..CovidDeaths as dea 
join PortfolioProjects..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date


--looking at total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollinPeopleVaccinated
from PortfolioProjects..CovidDeaths as dea 
join PortfolioProjects..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date

--USE CTE
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollinPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProjects..CovidDeaths as dea 
join PortfolioProjects..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
)


--temp table

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(continent nvarchar (255),location nvarchar (255),date datetime,
population numeric,new_vaccinations numeric ,RollingPeopleVaccinated numeric)

--insert
insert into #percentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollinPeopleVaccinated
from PortfolioProjects..CovidDeaths as dea 
join PortfolioProjects..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated 



--creating views to store data for visualizations
drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollinPeopleVaccinated
from PortfolioProjects..CovidDeaths as dea 
join PortfolioProjects..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null





 











