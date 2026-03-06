{{ config(materialized='table') }}

with recursive dates as (

    select to_date('2011-01-01') as date_day

    union all

    select dateadd(day, 1, date_day)
    from dates
    where date_day < to_date('2015-12-31')

)

select
    date_day
from dates