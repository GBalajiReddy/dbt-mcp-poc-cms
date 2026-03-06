{{ config(materialized='view') }}

with inpatient_providers as (

    select distinct
        data_year as data_year,
        record:provider_id::string as provider_id,
        record:provider_name::string as provider_name,
        record:provider_city::string as provider_city,
        record:provider_state::string as provider_state,
        record:provider_zipcode::string as provider_zipcode,
        record:provider_street_address::string as provider_street_address,
        cast(null as string) as provider_type,
        'HOSPITAL_INPATIENT' as provider_source,
        source_file,
        batch_id,
        load_ts,
        record as raw_record
    from {{ source('cms_raw', 'inpatient_charges_raw') }}

),

outpatient_providers as (

    select distinct
        data_year as data_year,
        record:provider_id::string as provider_id,
        record:provider_name::string as provider_name,
        record:provider_city::string as provider_city,
        record:provider_state::string as provider_state,
        record:provider_zipcode::string as provider_zipcode,
        record:provider_street_address::string as provider_street_address,
        cast(null as string) as provider_type,
        'HOSPITAL_OUTPATIENT' as provider_source,
        source_file,
        batch_id,
        load_ts,
        record as raw_record
    from {{ source('cms_raw', 'outpatient_charges_raw') }}

),

physician_suppliers as (

    select distinct
        data_year as data_year,
        record:npi::string as provider_id,
        trim(
            concat(
                coalesce(record:nppes_provider_first_name::string, ''),
                case
                    when record:nppes_provider_first_name::string is not null
                     and record:nppes_provider_last_org_name::string is not null
                    then ' '
                    else ''
                end,
                coalesce(record:nppes_provider_last_org_name::string, '')
            )
        ) as provider_name,
        record:nppes_provider_city::string as provider_city,
        record:nppes_provider_state::string as provider_state,
        record:nppes_provider_zip::string as provider_zipcode,
        record:nppes_provider_street1::string as provider_street_address,
        record:provider_type::string as provider_type,
        'PHYSICIAN_SUPPLIER' as provider_source,
        source_file,
        batch_id,
        load_ts,
        record as raw_record
    from {{ source('cms_raw', 'physicians_and_other_supplier_raw') }}

),

nursing_facilities as (

    select distinct
        data_year as data_year,
        record:provider_id::string as provider_id,
        record:facility_name::string as provider_name,
        record:city::string as provider_city,
        record:state::string as provider_state,
        record:zip_code::string as provider_zipcode,
        record:street_address::string as provider_street_address,
        'NURSING_FACILITY' as provider_type,
        'NURSING_FACILITY' as provider_source,
        source_file,
        batch_id,
        load_ts,
        record as raw_record
    from {{ source('cms_raw', 'nursing_facilities_raw') }}

)

select * from inpatient_providers
union all
select * from outpatient_providers
union all
select * from physician_suppliers
union all
select * from nursing_facilities