/*

Portfolio Project 1

(video notes: 1. save the excel file as a workbook and not as a csv to make it importable into sql
2. destination for the excel file should be sql server native client 11.0(might be a different one if the future))

*/
 
--selected everything from excel sheet to make sure it was correct and showing the right tables

select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are gonna be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at the Total Cases vs Total Deaths
-- gives percentage of deaths to cases and looks at the United states percentages
-- shows likelihood of dying from getting covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- looking at the Total Cases vs Poplulation
-- shows what percentage of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- looking at Countries with highest infection rate compared to population 

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location,population
order by PercentPopulationInfected desc


-- showing countries with highest death count per population 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Lets break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- correct numbers 

select location, MAX(cast(total_deaths as int) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

-- showing the continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers 
-- by day

select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int)
)/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2

--gives total
select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int)
)/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2


-- covid vaccination portion

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date

-- look at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
--sum(convert(int,vac.new_vaccinations)) same as cast 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where continent is not null
order by 1,2,3


-- use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
--sum(convert(int,vac.new_vaccinations)) same as cast 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where continent is not null
--order by 1,2,3 cant be in CTE
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table
Drop table if exists #PercentPopulationVaccinated -- needed
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
--sum(convert(int,vac.new_vaccinations)) same as cast 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where continent is not null
--order by 1,2,3 cant be in CTE

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
--sum(convert(int,vac.new_vaccinations)) same as cast 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where continent is not null
--order by 1,2,3