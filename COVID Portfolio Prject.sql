select *
from Portfolio_Project..CovidDeaths
where continent is not null
order by 3, 4

select *
from Portfolio_Project..CovidVaccinations
order by 3, 4

--Data I will be using

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Total Deaths
--shows likelihood of dying with covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Total Cases vs Population
--Shows percentage of population with covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
order by 1,2


-- -- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--BY CONTINENT

--Continent with the Highest Death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--Location with higest Death count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

-- Creating View to store data for later visualizations

Create View PercentPopulationVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
From  PercentPopulationVac

--view Table on location with higest death count per population; TotalDeathCount

Create View covidlocationdeath as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by location

select *
From covidlocationdeath

