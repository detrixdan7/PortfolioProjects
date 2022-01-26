select * 
from [PortfolioProject]..CovidDeaths
ORDER BY 3,4

--select * from [PortfolioProject]..CovidVaccinations
--ORDER BY 3,4

-- Here We Select The Data That We Will be Using

Select location, date, total_cases, new_cases,total_deaths,population
from [PortfolioProject]..CovidDeaths
ORDER BY 3,4

/*Total Cases VS Total Deaths
How many cases there are in each country and how many deaths have been attributed, Therefore looking at 
percentage of how likely we are to catch corona and die
The likelihood of dying if you contract covid in your country with verified real datat*/

Select location, date, total_cases, (total_deaths/total_cases)*100 as PercentageOfDeaths
from [PortfolioProject]..CovidDeaths
-- where location ='Jamaica'
ORDER BY 1,2

-- Shows what percentage of the population has covid

Select location, date, population, (total_cases/population)*100 as PercentagePopulationInfected
from [PortfolioProject]..CovidDeaths
where location ='Jamaica'
ORDER BY 1,2

-- Looking at countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 
as PercentagePopulationInfected
from [PortfolioProject]..CovidDeaths
-- where location ='Jamaica'
Group By location, population
ORDER BY PercentagePopulationInfected desc

-- Showing countries with highest death count per population

Select location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX ((total_cases/population))*100 
as TotalDeathCount
from [PortfolioProject]..CovidDeaths
-- where location ='Jamaica'
Group By location, population
ORDER BY TotalDeathCount desc

-- BREAKING DOWN INTO CONTINENTS

-- Showing continents with highest death count per population

Select continent, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX ((total_cases/population))*100 
as TotalDeathCount
from [PortfolioProject]..CovidDeaths
where continent is not null
Group By continent
ORDER BY TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from [PortfolioProject]..CovidDeaths
-- where location ='Jamaica'
Where continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccination
-- The Total Amount of People In The World That Has Been Vaccinated

Select Dea.continent, Dea.location, Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location Order By Dea.location, Dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
ON Dea.location= Vac.location
and Dea.date=Vac.date
Where Dea.continent IS NOT NULL
Order By 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location Order By Dea.location, Dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
ON Dea.location= Vac.location
and Dea.date=Vac.date
Where Dea.continent IS NOT NULL
-- Order By 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinattions numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location Order By Dea.location, Dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
ON Dea.location= Vac.location
and Dea.date=Vac.date
Where Dea.continent IS NOT NULL
-- Order By 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View To Store Data For Visualizations

CREATE View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER(PARTITION BY Dea.location Order By Dea.location, Dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccinations as Vac
ON Dea.location= Vac.location
and Dea.date=Vac.date
Where Dea.continent IS NOT NULL
-- Order By 2,3

Select * FROM PercentPopulationVaccinated





