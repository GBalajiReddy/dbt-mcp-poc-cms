{{ 
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='inpatient_fact_key',
    on_schema_change='sync_all_columns'
  ) 
}}

with src_base as (

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

src_ranked as (

    select
        s.*,
        row_number() over (
            partition by
                s.provider_id,
                s.drg_definition,
                s.data_year,
                s.source_file
            order by
                s.batch_id desc,
                s.total_discharges desc,
                s.average_medicare_payments desc,
                s.average_total_payments desc,
                s.average_covered_charges desc
        ) as rn
    from src_base s

),

src as (

    select *
    from src_ranked
    where rn = 1

),

provider_dedup as (

    select
        provider_id,
        provider_key
    from (
        select
            provider_id,
            provider_key,
            provider_source,
            row_number() over (
                partition by provider_id
                order by
                    case
                        when upper(provider_source) like '%INPATIENT%' then 0
                        else 1
                    end,
                    provider_source,
                    provider_key
            ) as rn
        from {{ ref('dim_provider') }}
    )
    where rn = 1

),

drg_dedup as (

    select
        drg_definition,
        drg_key
    from (
        select
            drg_definition,
            drg_key,
            row_number() over (
                partition by drg_definition
                order by drg_code, drg_key
            ) as rn
        from {{ ref('dim_drg') }}
    )
    where rn = 1

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

    left join provider_dedup p
        on s.provider_id = p.provider_id

    left join drg_dedup d
        on s.drg_definition = d.drg_definition

)

select * from final