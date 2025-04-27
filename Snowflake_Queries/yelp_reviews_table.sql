-- =============================================
-- Yelp Reviews Table
-- 1. Load JSON data from S3 into raw table
-- 2. Transform JSON to structured table with sentiment analysis
-- =============================================

-- Step 1: Load raw Yelp review data from S3
CREATE OR REPLACE TABLE yelp_reviews(review_text VARIANT);

COPY INTO yelp_reviews
FROM 's3://mero-naya-bucket/yelp_review'
CREDENTIALS = (
    AWS_KEY_ID = '***********************'
    AWS_SECRET_KEY = '*********************************'
)
FILE_FORMAT = (TYPE = JSON);

--  Preview raw review data
SELECT * FROM yelp_reviews LIMIT 1000;

-- Step 2: Transform raw JSON to structured table and apply sentiment analysis
CREATE OR REPLACE TABLE yelp_review_update AS
SELECT
    REVIEW_TEXT:business_id::STRING AS business_id,
    REVIEW_TEXT:date::DATE AS review_date,
    REVIEW_TEXT:user_id::STRING AS user_id,
    REVIEW_TEXT:stars::NUMBER AS review_stars,
    REVIEW_TEXT:text::STRING AS review_text,
    analyze_sentiment(review_text) AS analyze_sentiment
FROM
    yelp_reviews;
