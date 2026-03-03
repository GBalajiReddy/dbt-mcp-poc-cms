{{ config(materialized='view') }}

select
    data_year::number(4,0) as data_year,

    -- Provider info
    record:provider_id::string as provider_id,
    record:provider_name::string as provider_name,
    record:provider_city::string as provider_city,
    record:provider_state::string as provider_state,
    record:provider_zipcode::string as provider_zipcode,
    record:provider_street_address::string as provider_street_address,

    -- DRG info
    record:drg_definition::string as drg_definition,
    record:hospital_referral_region_description::string 
        as hospital_referral_region_description,

    -- Metrics
    record:total_discharges::number as total_discharges,
    record:average_covered_charges::number(18,2) 
        as average_covered_charges,
    record:average_total_payments::number(18,2) 
        as average_total_payments,
    record:average_medicare_payments::number(18,2) 
        as average_medicare_payments,

    source_file,
    batch_id

from {{ source('cms_raw', 'INPATIENT_CHARGES_RAW') }}