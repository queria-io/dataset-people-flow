{# 市区町村単位発地別の滞在人口。1 行が 1 市区町村・1 か月・平休日・時間帯・居住地区分の 1 組。
   pipelines/people_flow.py が都道府県ごとの全年月の CSV を data/people_flow/city_from_area/<都道府県>.parquet にする #}

select
    prefcode as prefecture_code,
    citycode as city_code,
    {{ local_government_code('citycode') }} as lg_code,
    make_date(cast(year as integer), cast(month as integer), 1) as date,
    cast(year as integer) as year,
    cast(month as integer) as month,
    {{ day_type('dayflag') }} as day_type,
    {{ time_of_day('timezone') }} as time_of_day,
    case from_area
        when '0' then '同一市区町村'
        when '1' then '同一都道府県'
        when '2' then '同一地方'
        when '3' then '他の地方'
    end as origin,
    cast(population as integer) as population
from read_parquet('data/people_flow/city_from_area/*.parquet')
order by city_code, date, dayflag, timezone, from_area
