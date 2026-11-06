{# 3 次メッシュコード（8 桁、JIS X 0410）の南西の角と中心。
   1 次メッシュは緯度 40 分・経度 1 度、2 次はその 8 等分、3 次はさらに 10 等分 #}

{% macro mesh_south(code) -%}
(cast(substr({{ code }}, 1, 2) as double) / 1.5
 + cast(substr({{ code }}, 5, 1) as double) / 12
 + cast(substr({{ code }}, 7, 1) as double) / 120)
{%- endmacro %}

{% macro mesh_west(code) -%}
(100 + cast(substr({{ code }}, 3, 2) as double)
 + cast(substr({{ code }}, 6, 1) as double) / 8
 + cast(substr({{ code }}, 8, 1) as double) / 80)
{%- endmacro %}

{% macro mesh_center_lat(code) -%}
({{ mesh_south(code) }} + 1.0 / 240)
{%- endmacro %}

{% macro mesh_center_lng(code) -%}
({{ mesh_west(code) }} + 1.0 / 160)
{%- endmacro %}
