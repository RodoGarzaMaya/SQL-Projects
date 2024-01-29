select * 
from CovidDeaths
order by 3,4

--select * 
--from CovidVaccinations 
--order by 3, 4

select location, date, total_cases,new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Percentage of people getting infected by covid 19 in United States

select Location, Date, Total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' 
order by 1,2

-- Percentage of population that got covid

select Location, Date, Population, Total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select Location, Population, MAX(Total_cases) as HighestInfectionCount , Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by Population, Location
order by PercentPopulationInfected desc

-- Countries with Highest Death Count

select Location, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

-- Continents with highest DeathCount 

select Location, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount desc

-- Global Numbers

Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null

-- Total Population vs Vaccinations

-- With CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location 
	and dea.date = vacc.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac

 
 --With Temp Table

 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar (255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric,
 )


Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location 
	and dea.date = vacc.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location 
	and dea.date = vacc.date
where dea.continent is not null
)