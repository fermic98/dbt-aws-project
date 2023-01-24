with sold_tickets as (
   select eventid, count(qtysold) as tickets_sold
   from {{ ref('stg_tickit_sales') }}
   group by eventid
),

venues as (
   select venuesid, venueseats
   from {{ ref('stg_tickit_venues') }}
),

events as (
   select eventid, venuesid
   from {{ ref('stg_tickit_events') }}
),

final as (
   select eventid
   from events as e
   join venues as v on v.venuesid=e.venuesid
   join sold_tickets as s on s.eventid=e.eventid
   where s.tickets_sold <= v.venueseats
)

select * from final