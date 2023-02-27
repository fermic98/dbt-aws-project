{{ config(materialized='view', bind=False) }}

with source as (

    select * from {{ source('tickit_external', 'interest') }}

),

renamed as (

    select
        interestid as interest_id,
        interestname as interest_name
    from
        source
    where
        interest_id IS NOT NULL
    order by
        interest_id

)

select * from renamed