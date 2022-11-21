Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccination
--order by 3,4

--Selecting data that we are going to be using

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at the total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population,(total_cases/population)*100 as PresentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
--and continent is not null
order by 1,2

-- looking at countries with highest infection rate compares to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PresentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
Group by location, population
order by PresentPopulationInfected desc

-- showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as PresentPopulationDeaths
From PortfolioProject..CovidDeaths
--where location like '%sri lanka%'
where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THIS DOWN BY CONTINENT
select location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as PresentPopulationDeaths
From PortfolioProject..CovidDeaths
--where location like '%sri lanka%'
where continent is null
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, (SUM(cast(new_deaths as int)) /  SUM(new_cases))*100 as Deathpersentage
From PortfolioProject..CovidDeaths
--where location like '%sri lanka%'
where continent is not null
Group by date
order by TotalNewCases desc

-- joining two tables
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at total population vs vaccinations

with Popvs(continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.locati	on
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccination)*100
from Popvs

--TEMP TABLE
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccination)*100
from #PercentagePopulationVaccinated

Create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentagePopulationVaccinated