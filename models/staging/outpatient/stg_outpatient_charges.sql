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

  -- APC info
  record:apc::string as apc,
  record:apc_description::string as apc_description,

  -- Metrics (Outpatient dataset does NOT contain average_medicare_payments key)
  record:outpatient_services::number as outpatient_services,
  record:average_estimated_submitted_charges::number(18,2) as average_estimated_submitted_charges,
  record:average_total_payments::number(18,2) as average_total_payments,

  /* Placeholder for schema alignment with inpatient fact.
     Source does not provide this field (not present in record keys). */
  cast(null as number(18,2)) as average_medicare_payments,

  source_file,
  batch_id
from {{ source('cms_raw', 'outpatient_charges_raw') }}