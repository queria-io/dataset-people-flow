-- 1 行が 1 市区町村・1 か月・平休日・時間帯・居住地区分
select city_code, date, day_type, time_of_day, origin, count(*) as n
from {{ ref('city_population_by_origin') }}
group by all
having count(*) > 1
