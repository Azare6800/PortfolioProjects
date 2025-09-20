--Select * 
--from PortfolioProject_Covid..CovidDeaths


--select *
--from PortfolioProject_Covid.dbo.CovidVaccinations


-- looking at total cases vs total deaths (total death %)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject_Covid..CovidDeaths
where location like '%states' and continent is not null
order by 1,2

-- Cases vs population, % of population that got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopInfected
from PortfolioProject_Covid..CovidDeaths
where location like '%states' and continent is not null
order by 1,2

-- Country with highest infection rate compared to pop
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopInfected
from PortfolioProject_Covid..CovidDeaths
--where location like '%states'
Where continent is not null
group by location, population
order by PercentPopInfected desc

-- Country with highest death count to pop.
-- cast allows you to change the type of data in a column, for some reason total_deaths was not number format
select location, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PercentPopDead
from PortfolioProject_Covid..CovidDeaths
--where location like '%states'
Where continent is not null
group by location
order by PercentPopDead desc

-- Global numbers
select location, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PercentPopDead
from PortfolioProject_Covid..CovidDeaths
--where location like '%states'
Where continent is null
group by location
order by PercentPopDead desc


Select sum(new_cases) as AllNewCases, sum(cast(new_deaths as int)) as AllNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject_Covid..CovidDeaths
--where location like '%states' 
where continent is not null
--group by date
order by 1,2

-- joins.
-- total pop vs vacinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
	,dea.date) as RollingVaccination
	--^ sum of all new vaccinations by location, partition allows the calculation to take place in each cell
from PortfolioProject_Covid..CovidDeaths dea
join PortfolioProject_Covid..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER by 2,3

--Use CTE
with PopvsVac (continent, location, date, Population, new_vaccinations, RollingVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
	,dea.date) as RollingVaccination
from PortfolioProject_Covid..CovidDeaths dea
join PortfolioProject_Covid..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER by 2,3
)

select *, (RollingVaccination/Population)*100 as [RollingVac/Pop%]
from popvsvac


-- temp table
Drop table if exists PercentPopulationVaccinated 
--(it allows you to make changes without having to delete the whole 
--	table and have to create again.
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccination numeric
)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
	,dea.date) as RollingVaccination
from PortfolioProject_Covid..CovidDeaths dea
join PortfolioProject_Covid..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER by 2,3

select *, (RollingVaccination/Population)*100 as [RollingVac/Pop%]
from PercentPopulationVaccinated


-- create a view
Create view PercentPopulationVac
as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
	,dea.date) as RollingVaccination
from PortfolioProject_Covid..CovidDeaths dea
join PortfolioProject_Covid..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER by 2,3
