{{ config(materialized='table') }}

with apc_source as (

    select distinct
        apc,
        split_part(apc, ' - ', 1) as apc_code,
        split_part(apc, ' - ', 2) as apc_description
    from {{ ref('stg_outpatient_charges') }}
    where apc is not null

)

select
    md5(coalesce(apc, '')) as apc_key,
    apc_code,
    apc_description,
    apc as apc_full_definition
from apc_source