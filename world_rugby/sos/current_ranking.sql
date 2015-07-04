begin;

create temporary table r (
       rk	 serial,
       team 	 text,
       team_id	 text,
       str	 float,
       ofs	 float,
       dfs	 float,
       sos	 float
);

insert into r
(team,team_id,str,ofs,dfs,sos)
(
select
coalesce(t.country_name,sf.team_id),
sf.team_id::text,
ln(sf.strength) as str,
ln(sf.offensive) as ofs,
ln(sf.defensive) as dfs,
ln(sf.schedule_strength) as sos
from wr._schedule_factors sf
left join wr.countries t
  on (t.country_id::text)=(sf.team_id)
order by str desc);

select
rk,
team,
str::numeric(4,2),
ofs::numeric(4,2),
dfs::numeric(4,2),
sos::numeric(4,2)
from r
order by rk asc;

select
row_number() over (order by str desc nulls last) as rk,
team,
str::numeric(4,2),
ofs::numeric(4,2),
dfs::numeric(4,2),
sos::numeric(4,2)
from r
order by rk asc;

copy (
select
rk,
team,
str::numeric(4,2),
ofs::numeric(4,2),
dfs::numeric(4,2),
sos::numeric(4,2)
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;

commit;
