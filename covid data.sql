select * from portfolio.dbo.CovidVaccination;

select Location , Date, total_cases, new_cases, total_deaths, population 
from portfolio.dbo.CovidDeaths
order by 1,2;

-- Sum of total cases vs total death in each location

select Location, sum(total_cases)as total_cases, sum(total_deaths)as total_deaths
from portfolio.dbo.CovidDeaths
group by Location 
order by 1
;

-- Total covid affected percentage

SELECT 
    Location, 
    Date, 
    total_cases, 
    population, 
    CAST((CAST(total_cases AS FLOAT) / population) * 100 AS FLOAT) AS covid_affected_perc
FROM 
    portfolio.dbo.CovidDeaths
ORDER BY 
    1;

-- Max covid affected percentage

SELECT 
    Location, 
    max(total_cases) max_cases, 
    population, 
    max((CAST(total_cases AS FLOAT) / population) * 100) AS max_covid_affected_perc
FROM 
    portfolio.dbo.CovidDeaths
	GROUP BY Location , population
	order by max_covid_affected_perc Desc;

-- Death percentage in location
	SELECT 
    Location,
    max(total_deaths) max_death 
from
    portfolio.dbo.CovidDeaths
	where continent is not null
	GROUP BY Location
	order by 1 ;

-- Death percentage in continent
	SELECT 
    continent,
    max(total_deaths) max_death 
from
    portfolio.dbo.CovidDeaths
	where continent is not null
	GROUP BY continent
	order by 1 ;

-- Total death , cases ,death perc date wise

select date, sum(new_deaths) as totaldeath, sum(new_cases) as totalcases ,
  CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE(sum(cast(new_deaths as float)) / sum(new_cases))* 100 
  End as death_perc
from Portfolio..CovidDeaths
group by date
order by 1;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.population,dea.date ) as rollingvacination
from Portfolio..CovidVaccination as vac
join Portfolio..CovidDeaths as dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3;

with cte (continent, location,date, population,new_vaccinations, rollingvacination ) as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.population,dea.date ) as rollingvacination
from Portfolio..CovidVaccination as vac
join Portfolio..CovidDeaths as dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null)
select * , (rollingvacination/convert(float,population)) *100
from cte;

-- Total vaccinated vs total death

select dea.continent, dea.location, vac.total_vaccinations, dea.total_deaths
from Portfolio..CovidVaccination as vac
join Portfolio..CovidDeaths as dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2
;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingvacination numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.population,dea.date ) as rollingvacination
from Portfolio..CovidVaccination as vac
join Portfolio..CovidDeaths as dea
on dea.location = vac.location and
dea.date = vac.date

Select *, (rollingvacination/Population)*100 as vaccinated population
From #PercentPopulationVaccinated




-- Creating View

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.population,dea.date ) as rollingvacination
from Portfolio..CovidVaccination as vac
join Portfolio..CovidDeaths as dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null 
