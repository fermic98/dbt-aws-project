with sales as (

    select * from {{ ref('stg_tickit__sales') }}

),

events as (
     select * from {{ ref('dim_events') }}
)

select 
    e.event_id,
    s.qty_sold,
    e.venue_name,
    e.venue_seats,
    {{ compute_percentage( 's.qty_sold', 'e.venue_seats')}} as filled_seats_percentage

from 
    sales as s
    join events as e on s.event_id = e.event_id

