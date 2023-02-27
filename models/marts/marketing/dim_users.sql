{{ config(materialized='table', sort='user_id', dist='user_id') }}

with users as (

    select * from {{ ref('stg_tickit__users') }}

),

count_non_buyers as (

        select user_id, count(*) as count
        from {{ ref('dim_non_buyers') }}
        group by user_id

),

traveler as (

    select user_id, count(*) as is_traveler
    from {{ ref('dim_users_travelling') }}
    group by user_id

),

final as (


    select distinct
        u.user_id,
        u.username,
        cast((u.last_name||', '||u.first_name) as varchar(100)) as full_name,
        u.city,
        u.state,
        u.email,
        u.phone,
        u.like_broadway,
        u.like_classical,
        u.like_concerts,
        u.like_jazz,
        u.like_musicals,
        u.like_opera,
        u.like_rock,
        u.like_sports,
        u.like_theatre,
        u.like_vegas,
        case when count>0 then true else false end as is_buyer,
        case when is_traveler>0 then true else false end as is_traveler
    from 
        users as u
        left join count_non_buyers as c on u.user_id = c.user_id 
        left join traveler as t on u.user_id = t.user_id
)

select * from final




