USE operation_invest;
SELECT * FROM case_study_one;
SELECT * FROM case_study_one order BY 1;
# CASE STUDY 1

# -- A -- NUMBER OF JOBS REVIEWED : CALCULATE NUMBER OF JOBS REVIEWED PER HOUR PER DAY FOR NOVEMBER, 2020 ?
SELECT 
    COUNT(DISTINCT job_id) / (24 * 30)
FROM
    case_study_one;
SELECT 
    COUNT(job_id) / (24 * 30)
FROM
    case_study_one;

# -- B -- THROUGHPUT :  Calculate 7 day rolling average of throughput?
SELECT ds as Date, AVG(events_per_second) OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS 7_day_rolling_avg_throughput
FROM (
    SELECT ds, COUNT(1) AS events_per_second
    FROM case_study_one
    GROUP BY ds
) subquery
ORDER BY ds;

# -- C -- Calculate the PERCENTAGE SHARE OF EACH LANGUAGE in the last 30 days?
SELECT language, (COUNT(*)/(SELECT COUNT(*) from case_study_one))*100 AS percent_share_of_each_language
FROM case_study_one GROUP BY language;

# -- D -- Duplicate rows
SELECT  actor_id, COUNT(*)
FROM case_study_one
GROUP BY  actor_id
HAVING COUNT(*) > 1;

SELECT *  FROM 
( SELECT *, ROW_NUMBER()OVER(PARTITION BY actor_id) AS row_num
FROM case_study_one ) a WHERE row_num>1;
