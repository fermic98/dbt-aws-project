{{ config(materialized='table') }}

with sales as (
    
    select * from {{ ref('stg_tickit__sales') }}

),

events as (
     select * from {{ ref('dim_events') }}
)

{% set categories = dbt_utils.get_column_values(ref('stg_tickit__categories'), column='cat_name') %}

select 
    e.venue_city,
    sum(s.qty_sold) as tickets_sold,
    sum(s.price_paid) as amount_paid,
    {% for category in categories %} 
    sum(case when e.cat_name = '{{ category }}' then s.qty_sold end) as {{category}}_tickets_sold
    {% if not loop.last %},{% endif %}
    {% endfor %}

from 
    sales as s
    join events as e on s.event_id = e.event_id
group by
    e.venue_city

