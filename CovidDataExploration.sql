
Select * from PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

Select * from PortfolioProject..CovidVaccinations$
order by 3,4

select location, date,total_cases,total_deaths,new_cases, population
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
from PortfolioProject..CovidDeaths$
where location like'%states%'
and continent is not null
order by 1,2


select location, date, total_cases, population, (total_cases/population)*100 As CasePercentage
from PortfolioProject..CovidDeaths$
where location like'%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) As HighestInfectionCount, MAX(total_cases/population)*100 As CasePercentage
from PortfolioProject..CovidDeaths$
Group by location, population
order by CasePercentage desc


-- Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) As TotalDeathCount 
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by location 
order by TotalDeathCount desc


select continent, MAX(cast(total_deaths as int)) As TotalDeathCount 
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
order by 1,2

--Total people vs vaccinated ones 

With PopVsVacc(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select de.continent, de.location, de.date, de.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by de.Location order by de.location, de.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as de
join PortfolioProject..CovidVaccinations$ as vac
on de.location =vac.location
and de.date = vac.date
where de.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) from PopVsVacc



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select de.continent, de.location, de.date, de.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ de
Join PortfolioProject..CovidVaccinations$ vac
	On de.location = vac.location
	and de.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select de.continent, de.location, de.date, de.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ de
Join PortfolioProject..CovidVaccinations$ vac
	On de.location = vac.location
	and de.date = vac.date
where de.continent is not null 


select * from PercentPopulationVaccinated