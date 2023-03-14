select *
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 3,4


--Needed data sets
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 3,4

--Total cases vs total deaths
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 1,2

--Total cases vs population
Select location, date,population, total_cases,(total_cases/population)*100 as DeathPopulationPercentage
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 1,2

--Countries with highest infection rate vs population
Select location,population, max(total_cases) as HighestInfectedCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Countries with highest death count vs population
Select location,max(cast(total_deaths as int)) as TotalDeathCountPerCountry
from PortfolioProjects..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCountPerCountry desc

--Location with highest death count vs population
Select location,max(cast(total_deaths as int)) as TotalDeathCountPerLocation
from PortfolioProjects..CovidDeaths$
where continent is null
group by location
order by TotalDeathCountPerLocation desc

--Continent with highest death count vs population
Select continent,max(cast(total_deaths as int)) as TotalDeathCountPerContinent
from PortfolioProjects..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCountPerContinent desc

--Global numbers
Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as TotalDeathCountPerGlobal
from PortfolioProjects..CovidDeaths$
where continent is not null
--group by date
order by 1,2


--Joined tables 
select *
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Total population vs vaccinations
with PopVsVac (continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select* , (RollingPeopleVaccinated/population) * 100
from PopVsVac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select* , (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated

--View to store data for visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated