-- メッシュコードから計算した中心が、原典の 1km メッシュ属性の中心（単精度）と 1e-5 度以内で一致する
select m.mesh_code, m.lng, m.lat, a.lon_center, a.lat_center
from {{ ref('mesh') }} as m
join read_csv('data/people_flow/attribute_mesh1km_2020.csv', all_varchar = true) as a on a.mesh1kmid = m.mesh_code
where abs(m.lng - cast(a.lon_center as double)) > 1e-5 or abs(m.lat - cast(a.lat_center as double)) > 1e-5
