Select *
From CovidDeaths
Where location like '%paki%'  
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%pakis%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases,population, (total_deaths/population)*100 as infection_percentage
From CovidDeaths
Where location like '%pakis%'
and continent is not null 
order by 1,2


-- highest infections per populations

Select location,population,MAX(total_cases) as highest_cases,max((total_cases/population)*100) as percentages_infected
From CovidDeaths
group by location,population
order by percentages_infected desc


-- show countries with highest death count

Select location,MAX(cast(total_deaths as int)) as total_death
From CovidDeaths
where CovidDeaths.continent is not null
group by location
order by total_death desc

-- deaths by continents --

Select continent,MAX(cast(total_deaths as int)) as total_death
From CovidDeaths
where CovidDeaths.continent is not null
group by continent
order by total_death desc

--    GLOBAL DATA  --

--deaths an cases with percentage on with dates
select date,sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentages from CovidDeaths
where continent is not null
group by date 
order by death_percentages desc



-- global total cases deaths and cases/deaths percentage

select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentages from CovidDeaths
where continent is not null
order by death_percentages desc



-- COVID VACCINATIONS --


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(vac.new_vaccinations) over(partition by dea.location) from CovidVaccinations vac
join CovidDeaths as dea
on vac.location = dea.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- how many peoples in each country is vaccinated.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 