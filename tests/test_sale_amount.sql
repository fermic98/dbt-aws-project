 select *
 from {{ ref('fct_sales')}} as s
 where s.ticket_price * s.qty_sold != s.price_paid