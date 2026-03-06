{{ config(materialized='table') }}

with drg_source as (

    select distinct
        drg_definition
    from {{ ref('stg_inpatient_charges') }}
    where drg_definition is not null

),

parsed as (

    select
        drg_definition,

        split_part(drg_definition, ' - ', 1) as drg_code,

        case
            when position(' - ' in drg_definition) > 0
            then split_part(drg_definition, ' - ', 2)
            else drg_definition
        end as drg_description

    from drg_source

)

select
    {{ dbt_utils.generate_surrogate_key(['drg_definition']) }} as drg_key,
    drg_code,
    drg_description,
    drg_definition
from parsed