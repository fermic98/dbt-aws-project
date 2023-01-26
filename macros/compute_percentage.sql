{% macro compute_percentage(sub_part, total, precision=2) %}
    round(({{ sub_part }} / {{ total }} * 100), {{ precision }})
{% endmacro %}