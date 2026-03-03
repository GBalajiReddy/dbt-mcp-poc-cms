{{ config(materialized='table') }}

with drg_source as (

    select distinct
        drg_definition,
        split_part(drg_definition, ' - ', 1) as drg_code,
        split_part(drg_definition, ' - ', 2) as drg_description
    from {{ ref('stg_inpatient_charges') }}

)

select
    md5(coalesce(drg_definition, '')) as drg_key,
    drg_code,
    drg_description,
    drg_definition
from drg_source