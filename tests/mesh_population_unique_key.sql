-- 1 行が 1 メッシュ・1 か月・平休日・時間帯
select mesh_code, date, day_type, time_of_day, count(*) as n
from {{ ref('mesh_population') }}
group by all
having count(*) > 1
