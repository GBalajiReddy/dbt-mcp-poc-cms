{{ 
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='outpatient_fact_key',
    on_schema_change='sync_all_columns'
  ) 
}}

with src as (

    select *
    from {{ ref('stg_outpatient_charges') }} s

    {% if is_incremental() %}
      -- Reprocess only the latest years (safe window) on incremental runs
      where s.data_year >= (
        select coalesce(max(t.data_year), 0) - 1
        from {{ this }} t
      )
    {% endif %}

),

provider_dedup as (

    select
        provider_id,
        provider_key
    from (
        select
            provider_id,
            provider_key,
            row_number() over (
                partition by provider_id, provider_source
                order by provider_name
            ) as rn
        from {{ ref('dim_provider') }}
        where provider_source = 'HOSPITAL_OUTPATIENT'
    )
    where rn = 1

),

apc_dedup as (

    select
        apc_full_definition,
        apc_key
    from (
        select
            apc_full_definition,
            apc_key,
            row_number() over (
                partition by apc_full_definition
                order by apc_code
            ) as rn
        from {{ ref('dim_apc') }}
    )
    where rn = 1

),

final as (

    select distinct
        {{ dbt_utils.generate_surrogate_key([
            's.data_year',
            's.provider_id',
            's.apc',
            's.source_file'
        ]) }} as outpatient_fact_key,

        -- Grain
        s.data_year,
        to_date(cast(s.data_year as varchar) || '-01-01') as metric_year,

        -- Dimension Keys
        p.provider_key,
        a.apc_key,

        -- Measures
        s.outpatient_services,
        s.average_estimated_submitted_charges,
        s.average_total_payments,
        s.average_medicare_payments,

        -- Audit
        s.source_file,
        s.batch_id

    from src s

    left join provider_dedup p
      on s.provider_id = p.provider_id

    left join apc_dedup a
      on s.apc = a.apc_full_definition

)

select * from final