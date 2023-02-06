{% test test_generic_assert_positive_value(model, column_name) %}
select
   {{column_name}}
from {{ model }}
where {{column_name}} < 0
{% endtest %}