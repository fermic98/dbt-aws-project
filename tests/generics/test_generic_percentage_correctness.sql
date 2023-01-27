{% test test_generic_percentage_correctness(model, column_percentage) %}
select
   {{column_percentage}}
from {{ model }}
where {{column_percentage}} < 0 || {{column_percentage}} >100
{% endtest %}