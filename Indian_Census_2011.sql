SELECT * from Test_Project..Data1

SELECT * from Test_Project..Data2

--Number of rows in our dataset

SELECT count(*) from Test_Project..Data1

SELECT count(*) from Test_Project..Data2

--Dataset for Jharkandh and Bihar
SELECT * from Test_Project..Data1 WHERE State in ('Jharkhand', 'Bihar');

--Population of India

select sum(Population) 'Total Population of india' from Test_Project..Data2 

--Average Growth

--for india
select avg(growth)*100 avg_growth from Test_Project..data1
--for state wise

select state, avg(growth)*100 avg_growth from Test_Project..data1 group by state;

--Average Sex Ratio

SELECT State, round(avg(Sex_Ratio),0) avg_sex_ratio from Test_Project..Data1 group by state order by avg_sex_ratio desc;

--Average literacy rate

SELECT state, round(avg(Literacy),0) avg_literacy from Test_Project..Data1 
group by state having round(avg(Literacy),0)>90 order by avg_literacy desc;

--top 3 states which are having high growth rate

select top 3 state, avg(growth)*100 avg_growth from Test_Project..data1 group by state order by avg_growth desc;

--bottom 3 states which are having lowest growth rate

select top 3 state, avg(growth)*100 avg_growth from Test_Project..data1 group by state;

--Top and bottom 3 states in literacy rate

drop table if exists #topstates
create table #topstates
( state nvarchar(255),
topstate float)

insert into #topstates
select state,round(avg(Literacy),0) avg_literacy_ratio from Test_Project..Data1 group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;


drop table if exists #bottomstates
create table #bottomstates
( state nvarchar(255),
bottomstate float)

insert into #bottomstates
select state,round(avg(Literacy),0) avg_literacy_ratio from Test_Project..Data1 group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;
select top 3 * from #topstates order by #topstates.topstate desc;
--Union of two tables
select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a
union
select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b

--States starting with the letter A

select distinct state from Test_Project..Data1 where lower(state) like 'a%';

--states starting with the letter A and ending with letter M

select distinct state from Test_Project..Data1 where lower(state) like 'a%m';

--To determine the number of male and females we should join both the tables, we are using inner join to do that

--This is giving us the district level results
select c.District, c.state,round(c.Population/(c.Sex_Ratio+1),0) Males, round((c.Sex_Ratio*Population)/(c.Sex_Ratio+1),0) Females from 
(select a.District, a.state, a.Sex_Ratio/1000 Sex_Ratio, b.Population from Test_Project..Data1 a inner join Test_Project..Data2 b  on a.District= b.District) c;


--To get the state level results we can use group by function
select  d.state, sum(d.Males) 'Total Number Of Male Population',sum(d.Females) 'Total Number Of Female Population' from 
(select c.District, c.state,round(c.Population/(c.Sex_Ratio+1),0) Males, round((c.Sex_Ratio*Population)/(c.Sex_Ratio+1),0) Females from 
(select a.District, a.state, a.Sex_Ratio/1000 Sex_Ratio, b.Population from Test_Project..Data1 a inner join Test_Project..Data2 b  on a.District= b.District) c) d
group by d.state;

--Total Literacy Rate
select d.state, sum(d.Literate_People) 'Total Number Of Literate People',sum(d.Illiterate_People) 'Total Number Of Illiterate People' from
(select c.district, c.state,round((c.Literacy_Ratio*c.Population),0) 'Literate_People', round((1-c.Literacy_Ratio)*c.Population,0)'Illiterate_People' from
(select a.District, a.state, a.Literacy/100 Literacy_Ratio, b.Population from Test_Project..Data1 a inner join Test_Project..Data2 b  on a.District= b.District) c) d
group by d.state;

--Population In Previous Census In India
select sum(e.Total_Previous_Census) Total_Previous_Census_Of_India, sum(e.Total_Current_Census) Total_Current_Census_Of_India from
(Select d.state, sum(d.Previous_Census) 'Total_Previous_Census', sum(d.Current_census) 'Total_Current_Census' from 
(Select c.district, c.state, round(c.population/(1+c.growth_rate),0) 'Previous_Census', c.population 'Current_Census' from
(select a.District, a.state, a.Growth Growth_Rate, b.Population from Test_Project..Data1 a inner join Test_Project..Data2 b  on a.District= b.District) c) d
group by d.state) e;

--Population VS Area(Creating a key value as 1 to join both the tables as key value will become common and we can join them)
select g.total_area/g.Previous_Census Previous_Census_VS_Total_Area, g.total_area/g.Current_census Current_census_VS_Total_Area from
(select q.*,r.Total_Area from (
select '1' as keyy,n.* from
(select sum(e.Previous_Census) 'Previous_Census', sum(e.Current_census) 'Current_census' from
(Select d.state, sum(d.Previous_Census) 'Previous_Census', sum(d.Current_census) 'Current_census' from 
(Select c.district, c.state, round(c.population/(1+c.growth_rate),0) 'Previous_Census', c.population 'Current_Census' from
(select a.District, a.state, a.Growth Growth_Rate, b.Population from Test_Project..Data1 a inner join Test_Project..Data2 b  on a.District= b.District) c) d
group by d.state) e) n) q inner join(

select '1' as keyy,m.* from 
(select sum(area_km2) 'Total_Area' from Test_Project..Data2) m)r on q.keyy=r.keyy) g

--Using window function(rank) finding out the top three districs from each state which has the highest literacy rate

select a.* from 
(select district, state,Literacy,rank() over (partition by state order by literacy desc) Rnk from Test_Project..Data1) a
where a.Rnk in (1,2,3) order by state
