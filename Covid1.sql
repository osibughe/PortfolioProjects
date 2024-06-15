SELECT *
FROM portfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4


----SELECT *
----FROM portfolioProject.dbo.CovidVaccinations
--where continent is not null
----order by 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProject.dbo.CovidDeaths
where continent is not null
order by 1, 2

--looking at the total cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths *100.0/total_cases) as DeathPercent
FROM portfolioProject.dbo.CovidDeaths
where location like '%Nigeria%'
And continent is not null
order by 1,2


--looking at total cases vs population

SELECT Location, date, population, total_cases, (total_cases *100.0/population) as PopulationPercent
FROM portfolioProject.dbo.CovidDeaths
where location like '%Nigeria%'
order by 1,2

--looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases *100.0/population)) as PopulationInfectedPercent
FROM portfolioProject.dbo.CovidDeaths
where continent is not null
Group by Location, Population
order by PopulationInfectedPercent desc

--showing the countries with highest death count per population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM portfolioProject.dbo.CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's break things down by continent


--showing the continents with the highest death count

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM portfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths
FROM portfolioProject.dbo.CovidDeaths
Where continent is not null
Group by date
order by 1,2


--looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)as RollingPeopleVaccinated
FROM portfolioProject.dbo.CovidDeaths as dea
join portfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by dea.location, dea.date

	--Use CTE

	with PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
	as
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)as RollingPeopleVaccinated
FROM portfolioProject.dbo.CovidDeaths as dea
join portfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by dea.location, dea.date
	)
	Select *, (RollingPeopleVaccinated*100.0/Population)
	FROM PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
	insert into #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)as RollingPeopleVaccinated
FROM portfolioProject.dbo.CovidDeaths as dea
join portfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by dea.location, dea.date
	
	Select *, (RollingPeopleVaccinated*100.0/Population)
	FROM #PercentPopulationVaccinated



	--creating view to store data for later

Create View PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)as RollingPeopleVaccinated
FROM portfolioProject.dbo.CovidDeaths as dea
join portfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by dea.location, dea.date

SELECT *
FROM PercentpopulationVaccinated