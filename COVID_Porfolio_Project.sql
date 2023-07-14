Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Popultaion

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathsCount desc

-- Showing the Continent with the higest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathsCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths
, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by date
order by 1,2

-- TOTAL CASES ACROSS THE WORLD 

Select  SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths
, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3	

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccionations, RollinPeopleVaccinated)
as
(
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3	
)
Select *, (RollinPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric,
New_vaccinations numeric,
RollinPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3	

Select *, (RollinPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3	

Select *
From PercentPopulationVaccinated