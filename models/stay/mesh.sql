{# 1km メッシュの形と所属。1 行が 1 メッシュ。
   所属の都道府県・市区町村は 2020 年版の 1km メッシュ属性による（2019 年版とは那珂川市など 70 メッシュが違う）。
   原典の座標は単精度の丸めを含むので、形と中心はメッシュコードから計算する #}

select
    mesh1kmid as mesh_code,
    prefcode as prefecture_code,
    citycode as city_code,
    {{ local_government_code('citycode') }} as lg_code,
    {{ mesh_center_lng('mesh_code') }} as lng,
    {{ mesh_center_lat('mesh_code') }} as lat,
    st_makeenvelope(
        {{ mesh_west('mesh_code') }},
        {{ mesh_south('mesh_code') }},
        {{ mesh_west('mesh_code') }} + 1.0 / 80,
        {{ mesh_south('mesh_code') }} + 1.0 / 120
    ) as geometry
from read_csv('data/people_flow/attribute_mesh1km_2020.csv', all_varchar = true)
order by mesh_code
