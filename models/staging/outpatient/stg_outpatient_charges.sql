{{ config(materialized='view') }}

select
    data_year as data_year,
    source_file,
    batch_id,
    load_ts,

    -- Provider info
    record:provider_id::string as provider_id,
    record:provider_name::string as provider_name,
    record:provider_city::string as provider_city,
    record:provider_state::string as provider_state,
    record:provider_zipcode::string as provider_zipcode,
    record:provider_street_address::string as provider_street_address,

    -- APC / service info
    record:apc::string as apc,
    record:hospital_referral_region::string as hospital_referral_region,

    -- Metrics
    record:outpatient_services::number as outpatient_services,
    record:average_estimated_submitted_charges::number(18,2) as average_estimated_submitted_charges,
    record:average_total_payments::number(18,2) as average_total_payments,

    -- Placeholder for schema alignment with downstream models if needed
    cast(null as number(18,2)) as average_medicare_payments,

    -- Business helper
    'OUTPATIENT' as service_type,

    -- Lineage / debug
    record as raw_record

from {{ source('cms_raw', 'outpatient_charges_raw') }}