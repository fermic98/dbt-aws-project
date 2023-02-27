{{ config(materialized='view') }}

with users as (
    
    select * from {{ ref('stg_tickit__users') }}

)

select 
   
    sum(likebroadway) as like_broadway,
    sum(likeclassical) as like_classical,
    sum(likeconcerts) as like_concerts,
    sum(likejazz) as like_jazz,
    sum(likemusicals) as like_musicals,
    sum(likeopera) as like_opera,
    sum(likerock) as like_rock,
    sum(likesports) as like_sports,
    sum(liketheatre) as like_theatre,
    sum(likevegas) as like_vegas

from 
   users as u
group by
    e.venue_city

