{% test test_generic_percentage_correctness(model, column_name) %}
select
   {{column_name}}
from {{ model }}
where {{column_name}} < 0 OR {{column_name}} >100
{% endtest %}