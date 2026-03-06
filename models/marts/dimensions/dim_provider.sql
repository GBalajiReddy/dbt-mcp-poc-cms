{{ config(materialized='table') }}

with provider_source as (

    select distinct
        provider_id,
        provider_name,
        provider_city,
        provider_state,
        provider_zipcode,
        provider_street_address,
        provider_type,
        provider_source
    from {{ ref('stg_provider_data') }}
    where provider_id is not null

)

select
    {{ dbt_utils.generate_surrogate_key(['provider_id', 'provider_source']) }} as provider_key,
    provider_id,
    provider_name,
    provider_city,
    provider_state,
    provider_zipcode,
    provider_street_address,
    provider_type,
    provider_source
from provider_source