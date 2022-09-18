Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths,population
From portfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs Total Deaths
-- Show the Likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From portfolioProject..CovidDeaths
Where Location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total cases Vs Population
--Shows what percentage of population got Covid

Select Location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From portfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
order by 1,2


--Looking at countries with highest Infection Rate compared to Population

Select Location, population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From portfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group By Location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group By Location
order by TotalDeathCount desc

--Let's Break it down by Continent

--Showing continent with the highest death count per population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is  not null
Group By continent
order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From portfolioProject..CovidDeaths
Where continent is not null
Group By date
order by 1,2


--Lookin at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
order By 2,3

--USE CTE

with PopvsVac(Continent,Location,Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as 
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order By 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table

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
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as 
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order By 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later Visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as 
RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated
