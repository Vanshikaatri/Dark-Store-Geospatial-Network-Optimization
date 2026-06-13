-- QUERY 1: City-Level KPI Dashboard
-- What it shows: Core delivery performance per city

SELECT
    city,
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value_inr), 0) AS total_revenue_inr,
    ROUND(AVG(order_value_inr), 2) AS avg_order_value,
    ROUND(AVG(distance_to_store_km), 3) AS avg_delivery_dist_km,
    ROUND(AVG(est_delivery_min), 2) AS avg_delivery_min,
    ROUND(100.0 * SUM(CASE WHEN est_delivery_min <= 10 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_under_10min,
    ROUND(100.0 * SUM(CASE WHEN est_delivery_min > 10 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_over_10min,
    ROUND(100.0 * SUM(CASE WHEN distance_to_store_km <= 2.0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_within_2km
FROM orders_with_distances
GROUP BY city
ORDER BY total_orders DESC;

-- QUERY 2: Brand Performance Comparison
-- What it shows: Which brand covers its customers best

SELECT
    brand,
    city,
    COUNT(*) AS total_orders,
    ROUND(AVG(distance_to_store_km), 3) AS avg_dist_km,
    ROUND(AVG(est_delivery_min), 2) AS avg_delivery_min,
    ROUND(MIN(distance_to_store_km), 3) AS min_dist_km,
    ROUND(MAX(distance_to_store_km), 3) AS max_dist_km,
    ROUND(100.0 * SUM(CASE WHEN est_delivery_min <= 10 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_10min_sla,
    ROUND(SUM(order_value_inr), 0) AS total_revenue
FROM orders_with_distances
GROUP BY brand, city
ORDER BY city, pct_10min_sla DESC;

-- QUERY 3: Store-Level Load Analysis
-- What it shows: Which stores are handling the most orders
--               (high load = potential capacity bottleneck)

SELECT
    o.nearest_store_id AS store_id,
    s.brand,
    s.area,
    s.city,
    COUNT(*) AS orders_handled,
    ROUND(AVG(o.distance_to_store_km), 3) AS avg_dist_km,
    ROUND(AVG(o.est_delivery_min), 2) AS avg_delivery_min,
    ROUND(AVG(o.order_value_inr), 2) AS avg_order_value,
    ROUND(SUM(o.order_value_inr), 0) AS total_revenue,
    ROUND(100.0 * SUM(CASE WHEN o.est_delivery_min <= 10 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_10min_sla,
    CASE
        WHEN COUNT(*) > 12000 THEN 'HIGH LOAD — monitor'
        WHEN COUNT(*) > 8000  THEN 'Medium load'
        ELSE 'Normal'
    END AS load_status
FROM orders_with_distances o
JOIN dark_stores s ON o.nearest_store_id = s.store_id
GROUP BY o.nearest_store_id, s.brand, s.area, s.city
ORDER BY orders_handled DESC;

-- QUERY 4: Peak Hour Demand Analysis
-- What it shows: Order volumes and revenue by hour of day

SELECT
    hour_of_day,
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value_inr), 0) AS total_revenue,
    ROUND(AVG(order_value_inr), 2) AS avg_order_value,
    ROUND(AVG(est_delivery_min), 2) AS avg_delivery_min,
    CASE
        WHEN hour_of_day BETWEEN 7  AND 10 THEN 'Morning Peak'
        WHEN hour_of_day BETWEEN 12 AND 14 THEN 'Lunch Peak'
        WHEN hour_of_day BETWEEN 19 AND 22 THEN 'Evening Peak'
        WHEN hour_of_day BETWEEN 0  AND 5  THEN 'Dead Hours'
        ELSE 'Off-Peak'
    END AS demand_window
FROM orders_with_distances
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- QUERY 5: Day-of-Week Revenue Pattern
-- What it shows: Which days drive the most revenue

SELECT
    day_of_week,
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value_inr), 0) AS total_revenue,
    ROUND(AVG(order_value_inr), 2) AS avg_order_value,
    ROUND(AVG(est_delivery_min), 2) AS avg_delivery_min,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_weekly_orders
FROM orders_with_distances
GROUP BY day_of_week
ORDER BY total_orders DESC;

-- QUERY 6: Coverage Overlap Detection (Cannibalization Risk)
-- What it shows: Stores sharing the same high-demand zones

-- Step 1: For each store, count how many other stores are within 3km
SELECT
    s1.store_id,
    s1.brand,
    s1.area,
    s1.city,
    COUNT(s2.store_id) AS nearby_competitors,
    GROUP_CONCAT(s2.brand || ' (' || s2.area || ')', ' | ') AS competitor_detail,
    CASE
        WHEN COUNT(s2.store_id) >= 3 THEN 'HIGH overlap — cannibalization risk'
        WHEN COUNT(s2.store_id) >= 1 THEN 'Moderate overlap'
        ELSE 'Isolated — no direct competition nearby'
    END AS overlap_status
FROM dark_stores s1
LEFT JOIN dark_stores s2
    ON  s1.store_id != s2.store_id
    AND s1.city = s2.city
    -- Approximate 3km filter using degree differences
    -- (exact version: use Haversine or PostGIS)
    AND ABS(s1.lat - s2.lat) < 0.027
    AND ABS(s1.lng - s2.lng) < 0.027
GROUP BY s1.store_id, s1.brand, s1.area, s1.city
ORDER BY nearby_competitors DESC;

-- QUERY 7: Zone Opportunity Matrix
-- What it shows: Ranks zones by order volume + delivery distance

SELECT
    city,
    area,
    total_orders,
    ROUND(avg_delivery_dist, 3) AS avg_dist_km,
    ROUND(total_revenue_inr, 0) AS total_revenue,
    ROUND(pct_within_10min, 1) AS pct_10min,
    ROUND(opportunity_score, 2) AS opportunity_score,
    CASE
        WHEN avg_delivery_dist > 1.5 AND total_orders > 10000
            THEN 'PRIORITY — Open store here'
        WHEN avg_delivery_dist > 1.0 AND total_orders > 8000
            THEN 'HIGH — Monitor for expansion'
        WHEN avg_delivery_dist < 0.5 AND total_orders > 12000
            THEN 'SATURATED — Cannibalization risk'
        ELSE 'Normal coverage'
    END AS expansion_recommendation
FROM zone_stats
ORDER BY opportunity_score DESC;

-- QUERY 8: Monthly Revenue Trend
-- What it shows: Revenue growth across the year

SELECT
    city,
    month,
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value_inr), 0) AS monthly_revenue,
    ROUND(AVG(order_value_inr), 2) AS avg_order_value,
    ROUND(100.0 * SUM(order_value_inr) /
        SUM(SUM(order_value_inr)) OVER (PARTITION BY city), 1) AS pct_of_annual_revenue
FROM orders_with_distances
GROUP BY city, month
ORDER BY city, month;

-- QUERY 9: SLA Breach Risk Analysis
-- What it shows: Orders at risk of missing 10-min promise

SELECT
    o.nearest_store_id,
    s.brand,
    s.city,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.est_delivery_min > 10 THEN 1 ELSE 0 END) AS orders_breaching_sla,
    ROUND(100.0 * SUM(CASE WHEN o.est_delivery_min > 10 THEN 1 ELSE 0 END) / COUNT(*), 2) AS sla_breach_rate_pct,
    ROUND(AVG(CASE WHEN o.est_delivery_min > 10 THEN o.est_delivery_min END), 2) AS avg_breach_delay_min,
    ROUND(SUM(CASE WHEN o.est_delivery_min > 10 THEN o.order_value_inr ELSE 0 END), 0) AS revenue_at_risk_inr
FROM orders_with_distances o
JOIN dark_stores s ON o.nearest_store_id = s.store_id
GROUP BY o.nearest_store_id, s.brand, s.city
HAVING orders_breaching_sla > 0
ORDER BY sla_breach_rate_pct DESC;

-- QUERY 10: Executive Summary View
-- What it shows: Single row of headline KPIs for the whole network

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT nearest_store_id) AS active_stores,
    COUNT(DISTINCT city) AS cities_covered,
    ROUND(SUM(order_value_inr) / 1e7, 2) AS total_revenue_cr,
    ROUND(AVG(order_value_inr), 2) AS avg_order_value_inr,
    ROUND(AVG(distance_to_store_km), 3) AS network_avg_dist_km,
    ROUND(AVG(est_delivery_min), 2) AS network_avg_delivery_min,
    ROUND(100.0 * SUM(CASE WHEN est_delivery_min <= 10 THEN 1 ELSE 0 END) / COUNT(*), 2) AS network_sla_pct,
    ROUND(MIN(distance_to_store_km), 3) AS min_dist_km,
    ROUND(MAX(distance_to_store_km), 3) AS max_dist_km
FROM orders;