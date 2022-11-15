
--- Query 1
SELECT * FROM "my_demo_db"."cleaned_data" limit 10;

--- Query 2
SELECT 
    region, 
    segment, 
    SUM(forecasted_monthly_revenue) as forcast_monthly_revenue 
FROM "my_demo_db"."cleaned_data" 
GROUP BY segment, region;

