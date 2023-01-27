{% macro compute_percentage(sub_part, total, precision=6) %} 
    ROUND(({{ sub_part }} / CAST(nullif({{ total }}, 0) AS DOUBLE PRECISION)), {{ precision }})
{% endmacro %}