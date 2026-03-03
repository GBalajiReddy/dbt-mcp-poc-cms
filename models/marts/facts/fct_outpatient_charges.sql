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

final as (

    select
        -- Surrogate Fact Key (stable, based only on grain columns)
        {{ dbt_utils.generate_surrogate_key([
            's.data_year',
            's.provider_id',
            's.apc',
            's.source_file'
        ]) }} as outpatient_fact_key,

        -- Grain columns
        s.data_year,

        -- Dimension Keys
        p.provider_key,
        a.apc_key,

        -- Measures
        s.outpatient_services,
        s.average_estimated_submitted_charges,
        s.average_total_payments,
        s.average_medicare_payments,

        -- Lineage / Audit
        s.source_file,
        s.batch_id

    from src s
    left join {{ ref('dim_provider') }} p
      on s.provider_id = p.provider_id
    left join {{ ref('dim_apc') }} a
      on s.apc = a.apc_full_definition

)

select * from final