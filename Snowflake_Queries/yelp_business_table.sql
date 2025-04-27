-- =============================================
-- Yelp Business Table
-- 1. Load JSON data from S3 into a raw business table
-- 2. Transform JSON to a structured business table
-- =============================================

-- Step 1: Load raw Yelp business data from S3
CREATE OR REPLACE TABLE yelp_business(text VARIANT);

COPY INTO yelp_business
FROM 's3://mero-naya-bucket/yelp_business/yelp_academic_dataset_business.json'
CREDENTIALS = (
    AWS_KEY_ID = '****************'
    AWS_SECRET_KEY = '********************************'
)
FILE_FORMAT = (TYPE = JSON);

--  Preview raw business data
SELECT * FROM yelp_business LIMIT 100;

-- Step 2: Transform raw JSON to structured business table
CREATE OR REPLACE TABLE yelp_business_update AS
SELECT
    TEXT:business_id::STRING AS business_id,
    TEXT:name::STRING AS name,
    TEXT:city::STRING AS city,
    TEXT:state::STRING AS state,
    TEXT:review_count::NUMBER AS review_count,
    TEXT:stars::NUMBER AS stars,
    TEXT:categories::STRING AS categories
FROM
    yelp_business;

-- Preview transformed business data
SELECT * FROM yelp_business_update LIMIT 100;
