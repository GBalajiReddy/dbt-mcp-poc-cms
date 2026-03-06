{{ config(materialized='table') }}

with apc_source as (

    select distinct
        apc
    from {{ ref('stg_outpatient_charges') }}
    where apc is not null

),

parsed as (

    select
        apc,

        split_part(apc, ' - ', 1) as apc_code,

        case
            when position(' - ' in apc) > 0
            then split_part(apc, ' - ', 2)
            else apc
        end as apc_description

    from apc_source

)

select
    {{ dbt_utils.generate_surrogate_key(['apc']) }} as apc_key,
    apc_code,
    apc_description,
    apc as apc_full_definition
from parsed