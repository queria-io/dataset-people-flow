{# 都道府県・市区町村と地方区分。1 行が 1 市区町村。
   2020 年版のマスタに、2019 年のデータだけに出てくる旧那珂川町（40305、2018 年 10 月に市制施行して 40231）を 2019 年版から足す。
   篠山市（28221）は 2019 年 5 月に丹波篠山市へ改称しており、2020 年版の名前を使う #}

with master as (
    select * from read_csv('data/people_flow/prefcode_citycode_master_2020.csv', all_varchar = true)
    union all by name
    select * from read_csv('data/people_flow/prefcode_citycode_master_2019.csv', all_varchar = true)
    where citycode not in (
        select citycode from read_csv('data/people_flow/prefcode_citycode_master_2020.csv', all_varchar = true)
    )
)

select
    m.prefcode as prefecture_code,
    m.prefname as prefecture,
    m.citycode as city_code,
    {{ local_government_code('m.citycode') }} as lg_code,
    m.cityname as city_name,
    m.address,
    r.regioncode as region_code,
    r.regionname as region
from master as m
join read_csv('data/people_flow/regioncode_master_2020.csv', all_varchar = true) as r using (prefcode)
order by city_code
