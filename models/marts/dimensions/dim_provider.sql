{{ config(materialized='table') }}

with provider_base as (

    select
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
      and provider_source is not null

),

provider_ranked as (

    select
        provider_id,
        provider_name,
        provider_city,
        provider_state,
        provider_zipcode,
        provider_street_address,
        provider_type,
        provider_source,
        row_number() over (
            partition by provider_id, provider_source
            order by
                case when provider_name is not null then 0 else 1 end,
                case when provider_state is not null then 0 else 1 end,
                case when provider_city is not null then 0 else 1 end,
                case when provider_street_address is not null then 0 else 1 end,
                case when provider_zipcode is not null then 0 else 1 end,
                provider_name,
                provider_city,
                provider_state,
                provider_zipcode,
                provider_street_address,
                provider_type
        ) as rn
    from provider_base

),

provider_dedup as (

    select
        provider_id,
        provider_name,
        provider_city,
        provider_state,
        provider_zipcode,
        provider_street_address,
        provider_type,
        provider_source
    from provider_ranked
    where rn = 1

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
from provider_dedup