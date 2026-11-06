{# 1km メッシュ別の滞在人口。1 行が 1 メッシュ・1 か月・平休日・時間帯の 1 組。
   pipelines/people_flow.py が都道府県ごとの全年月の CSV を data/people_flow/mesh_1km/<都道府県>.parquet にする（値は文字列のまま）。
   地図にしやすいようにメッシュの中心を付ける。中心はメッシュコードから計算する（stay.mesh と同じ） #}

select
    mesh1kmid as mesh_code,
    make_date(cast(year as integer), cast(month as integer), 1) as date,
    cast(year as integer) as year,
    cast(month as integer) as month,
    {{ day_type('dayflag') }} as day_type,
    {{ time_of_day('timezone') }} as time_of_day,
    cast(population as integer) as population,
    prefcode as prefecture_code,
    citycode as city_code,
    {{ local_government_code('citycode') }} as lg_code,
    {{ mesh_center_lng('mesh1kmid') }} as lng,
    {{ mesh_center_lat('mesh1kmid') }} as lat
from read_parquet('data/people_flow/mesh_1km/*.parquet')
order by date, mesh_code, dayflag, timezone
