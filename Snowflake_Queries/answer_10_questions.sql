-- 1. Find the number of businesses in each category

WITH categorical_business AS (
    SELECT
        business_id,
        TRIM(A.VALUE) AS category
    FROM
        yelp_business_update,
        LATERAL SPLIT_TO_TABLE(categories, ',') AS A
)

SELECT
    category,
    COUNT(*) AS number_of_business
FROM
    categorical_business
GROUP BY
    category
ORDER BY
    number_of_business DESC;



-- 2. Find the top 10 users who have reviewed the most businesses in the "Restaurant" category

SELECT
    user_id,
    COUNT(DISTINCT b.business_id) AS reviewed_business_count
FROM
    yelp_business_update AS b
JOIN
    yelp_review_update AS r
ON 
    b.business_id = r.business_id
WHERE
    b.categories ILIKE '%restaurant%'
GROUP BY
    user_id
ORDER BY
    reviewed_business_count DESC
LIMIT 10;



-- 3. Find the most popular categories of businesses based on the number of reviews

WITH categorical_business AS (
    SELECT
        business_id,
        review_count,
        TRIM(A.VALUE) AS category
    FROM
        yelp_business_update,
        LATERAL SPLIT_TO_TABLE(categories, ',') AS A
) 

SELECT
    category,
    COUNT(*) AS total_reviews
FROM
    categorical_business AS c
JOIN
    yelp_review_update AS r
ON 
    c.business_id = r.business_id
GROUP BY
    category
ORDER BY
    total_reviews DESC;



-- 4. Find the top 3 most recent reviews for each business

WITH recent_review AS (
    SELECT
        r.*,
        b.name,
        ROW_NUMBER() OVER (PARTITION BY r.business_id ORDER BY r.review_date DESC) AS row_num
    FROM
        yelp_business_update AS b
    JOIN
        yelp_review_update AS r
    ON
        b.business_id = r.business_id
)

SELECT
    *
FROM
    recent_review
WHERE
    row_num <= 3;



-- 5. Find the month with the highest number of reviews

SELECT
    EXTRACT(MONTH FROM review_date) AS month,
    COUNT(*) AS num_reviews
FROM
    yelp_review_update
GROUP BY
    month
ORDER BY
    num_reviews DESC;



-- 6. Find the percentage of 5-star reviews for each business

SELECT
    r.business_id,
    b.name,
    ROUND(SUM(CASE WHEN r.review_stars = 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS five_star_percent
FROM
    yelp_business_update AS b
JOIN
    yelp_review_update AS r
ON
    b.business_id = r.business_id
GROUP BY
    r.business_id, b.name
ORDER BY 
    five_star_percent DESC;



-- 7. Find the top 5 most reviewed businesses in each city

WITH most_reviewed_business AS (
    SELECT
        b.city,
        b.business_id,
        b.name,
        COUNT(*) AS review_count
    FROM
        yelp_business_update AS b
    JOIN
        yelp_review_update AS r
    ON
        b.business_id = r.business_id
    GROUP BY
        b.city, b.business_id, b.name
)

SELECT
    *
FROM
    most_reviewed_business
QUALIFY 
    RANK() OVER (PARTITION BY city ORDER BY review_count DESC) <= 5;



-- 8. Find the average rating of businesses that have at least 100 reviews

SELECT
    b.business_id,
    b.name,
    ROUND(AVG(r.review_stars), 2) AS avg_rating
FROM
    yelp_business_update AS b
JOIN
    yelp_review_update AS r
ON
    b.business_id = r.business_id
GROUP BY
    b.business_id, b.name
HAVING
    COUNT(*) >= 100;



-- 9. List the top 10 users who have written the most reviews along with the businesses they reviewed

SELECT DISTINCT
    u.user_id,
    b.business_id,
    b.name
FROM
    yelp_business_update AS b
JOIN
    yelp_review_update AS r
ON 
    b.business_id = r.business_id
JOIN (
    SELECT
        user_id,
        COUNT(*) AS num_reviews
    FROM
        yelp_review_update
    GROUP BY
        user_id
    ORDER BY
        num_reviews DESC
    LIMIT 10
) AS u
ON 
    r.user_id = u.user_id;



-- 10. Find the top 10 businesses with the highest positive sentiment reviews

SELECT
    r.business_id,
    b.name,
    SUM(CASE WHEN r.analyze_sentiment = 'Positive' THEN 1 ELSE 0 END) AS positive_sentiment
FROM
    yelp_review_update AS r
JOIN
    yelp_business_update AS b
ON 
    b.business_id = r.business_id
GROUP BY
    r.business_id, b.name
ORDER BY
    positive_sentiment DESC
LIMIT 10;
