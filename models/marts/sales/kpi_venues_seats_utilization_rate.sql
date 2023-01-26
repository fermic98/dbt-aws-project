with sales as (

    select * from {{ ref('stg_tickit__sales') }}

),

with events as (
     select * from {{ ref('dim_events') }}
),

select 
    e.event_id,
    e.venue_name,
    e.venue_seats,
    {{ compute_percentage(sum(s.qty_sold)/(count(e.event_id) * e.venue_seats) }}) as filled_seats_percentage,
    {% if not loop.last %},{% endif %}
    {% endfor %}

from 
    sales as s
    join events as e on s.event_id = e.event_id
group by
    e.venue_name, e.venue_seats

