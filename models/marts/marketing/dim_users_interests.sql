{{ config(materialized='table') }}
-- depends_on: {{ ref('stg_tickit__users') }}
{% set interests = dbt_utils.get_column_values(ref('stg_tickit__interests'), column='interest_name') %}

{% for interest in interests %} 
    select user_id, '{{ interest }}' as interest_name
    from {{ ref('stg_tickit__users') }}
    where like_{{ interest }} = 1
{% if not loop.last %} UNION ALL {% endif %}
{% endfor %}