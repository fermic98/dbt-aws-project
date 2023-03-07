{{ config(materialized='view') }}
-- depends_on: {{ ref('stg_tickit__users') }}
{% set interests = dbt_utils.get_column_values(ref('stg_tickit__interests'), column='interest_name') %}

with interests as (

    select * from {{ ref('stg_tickit__interests') }}

),    

{% for interest in interests %} 

{{ interest }} as (
     select user_id, {{ interest }} as interest_name
     from {{ ref('stg_tickit__users') }}
     where like_{{ interest }} = 1
)
{% if not loop.last %},{% endif %}
{% endfor %}

select
    user_id,
    i.interest_name

from 
   interests as i
   right join broadway as b on b.interest_name = i.interest_name 
   right join classical as cl on cl.interest_name = i.interest_name 
   right join concerts as co on co.interest_name = i.interest_name 
   right join jazz as j on j.interest_name = i.interest_name 
   right join musicals as m on m.interest_name = i.interest_name 
   right join opera as o on o.interest_name = i.interest_name 
   right join rock as r on r.interest_name = i.interest_name 
   right join sports as s on s.interest_name = i.interest_name 
   right join theatre as t on t.interest_name = i.interest_name 
   right join vegas as v on v.interest_name = i.interest_name     

