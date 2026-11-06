{# 定義書の区分コードを名前にする。想定外のコードは NULL になり、_schema.yml の not_null が止める #}

{% macro day_type(dayflag) -%}
case {{ dayflag }} when '0' then '休日' when '1' then '平日' when '2' then '全日' end
{%- endmacro %}

{% macro time_of_day(timezone) -%}
case {{ timezone }} when '0' then '昼' when '1' then '深夜' when '2' then '終日' end
{%- endmacro %}
