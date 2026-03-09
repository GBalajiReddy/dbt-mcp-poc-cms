{{ 
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='inpatient_fact_key',
    on_schema_change='sync_all_columns'
  ) 
}}

with src as (

    select *
    from {{ ref('stg_inpatient_charges') }} s

    {% if is_incremental() %}
      where not exists (
        select 1
        from {{ this }} t
        where t.source_file = s.source_file
      )
    {% endif %}

),

final as (

    select

        {{ dbt_utils.generate_surrogate_key([
            's.provider_id',
            's.drg_definition',
            's.data_year',
            's.source_file'
        ]) }} as inpatient_fact_key,

        -- Grain
        s.data_year,
        to_date(cast(s.data_year as varchar) || '-01-01') as metric_year,

        -- Dimension Keys
        p.provider_key,
        d.drg_key,

        -- Measures
        s.total_discharges,
        s.average_covered_charges,
        s.average_total_payments,
        s.average_medicare_payments,

        -- Audit
        s.source_file,
        s.batch_id

    from src s

    left join {{ ref('dim_provider') }} p
        on s.provider_id = p.provider_id

    left join {{ ref('dim_drg') }} d
        on s.drg_definition = d.drg_definition

)

select * from final