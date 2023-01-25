with sold_tickets as (
   select event_id, count(qty_sold) as tickets_sold
   from {{ ref('stg_tickit_sales') }}
   group by event_id
),

venues as (
   select venues_id, venue_seats
   from {{ ref('stg_tickit_venues') }}
),

events as (
   select event_id, venue_id
   from {{ ref('stg_tickit_events') }}
),

final as (
   select event_id
   from events as e
   join venues as v on v.venue_id=e.venue_id
   join sold_tickets as s on s.event_id=e.event_id
   where s.tickets_sold <= v.venue_seats
)

select * from final