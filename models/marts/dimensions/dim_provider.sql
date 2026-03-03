{{ config(materialized='table') }}

with inpatient_providers as (

    select distinct
        provider_id,
        provider_name,
        provider_city,
        provider_state,
        provider_zipcode,
        provider_street_address
    from {{ ref('stg_inpatient_charges') }}

),

outpatient_providers as (

    select distinct
        provider_id,
        provider_name,
        provider_city,
        provider_state,
        provider_zipcode,
        provider_street_address
    from {{ ref('stg_outpatient_charges') }}

),

combined as (

    select * from inpatient_providers
    union
    select * from outpatient_providers

)

select
    {{ dbt_utils.generate_surrogate_key(['provider_id']) }} as provider_key,
    provider_id,
    provider_name,
    provider_city,
    provider_state,
    provider_zipcode,
    provider_street_address
from combined