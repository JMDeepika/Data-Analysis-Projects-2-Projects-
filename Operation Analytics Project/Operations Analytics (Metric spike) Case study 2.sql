USE operation_invest;

###############
#		CASE STUDY 2  - Investigating Metric Spike
###############

SHOW FIELDS FROM events FROM operation_invest;
SHOW FIELDS FROM users FROM operation_invest;
SHOW FIELDS FROM email_events FROM operation_invest;
###############

# --- A ---  Weekly User Engagement

SELECT 
    EXTRACT(WEEK FROM occurred_at) AS week_number,
    COUNT(DISTINCT user_id) AS weekly_user_engagement
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY EXTRACT(WEEK FROM occurred_at);

#   --- B ---  USER GROWTH for Product
SELECT Year, week_number, no_of_active_users, SUM(no_of_active_users) OVER(ORDER BY Year, week_number) as cum_sum
FROM (SELECT year(created_at) as Year,week(created_at) AS week_number, count(user_id) AS no_of_active_users FROM users 
WHERE state = 'active' GROUP BY year(created_at), week(created_at) ORDER BY Year, week_number) as SUB;

SELECT extract(year from created_at) as Year,extract(week from created_at) AS week_number, count(distinct user_id) AS number_of_active_users FROM users 
WHERE state = 'active' GROUP BY Year, week_number;


# --- C --- Weekly Retention of Users-Sign Up Cohort
# Weekly Retention using CTE'S 
WITH Cohort_items AS (SELECT distinct user_id, extract(week from occurred_at) as signup_week FROM events
WHERE event_type = 'signup_flow' and event_name = 'complete_signup'),

Engage_history AS (SELECT DISTINCT user_id, extract(week from occurred_at) as engagement_week FROM events
where event_type = 'engagement' ORDER BY user_id),

Cohort_size AS (SELECT signup_week, COUNT(1) as num_of_users FROM Cohort_items GROUP BY 1),

Retention_tab AS (SELECT signup_week, engagement_week, COUNT(Cohort_items.user_id) AS returned_users FROM Cohort_items INNER JOIN Engage_history
ON Cohort_items.user_id = Engage_history.user_id GROUP BY 1, 2 ORDER BY 1,2)

SELECT DISTINCT Retention_tab.signup_week, num_of_users, engagement_week, returned_users, (returned_users*100/num_of_users) AS retention_rate
FROM Retention_tab INNER JOIN Cohort_size ON Retention_tab.signup_week = Cohort_size.signup_week;

#  Weekly Retention  using Subqueries
SELECT DISTINCT table_1.signup_week, num_of_users, engagement_week, returned_users, (returned_users*100/num_of_users) AS retention_rate
FROM 
	(SELECT signup_week, engagement_week, COUNT(Cohort.user_id) AS returned_users FROM (SELECT distinct user_id, extract(week from occurred_at) as signup_week from events
	WHERE event_type = 'signup_flow'
	and event_name = 'complete_signup') AS Cohort
	INNER JOIN (SELECT DISTINCT user_id, extract(week from occurred_at) as engagement_week FROM events
	where event_type = 'engagement' ORDER BY user_id) AS engagement_history ON Cohort.user_id = engagement_history.user_id
	GROUP BY 1, 2 ORDER BY 1,2) AS table_1
JOIN 
	(SELECT signup_week, COUNT(1) as num_of_users
	FROM (SELECT distinct user_id, extract(week from occurred_at) as signup_week from events
	WHERE event_type = 'signup_flow'
	and event_name = 'complete_signup') AS Cohort GROUP BY 1 ORDER BY 1) AS table_2
ON table_1.signup_week = table_2.signup_week;

# --- D --- Weekly Engagement per Device

SELECT 
    EXTRACT(YEAR FROM occurred_at) AS Year,
    EXTRACT(WEEK FROM occurred_at) AS week_number,
    device,
    COUNT(user_id) AS weekly_device_engagement
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY 1 , 2 , 3
ORDER BY 1 , 2 , 3;

#  --- E ---  Email Engagement metrics

SELECT 
    click / sent * 100 AS mail_click_rate,
    opened / sent * 100 AS mail_open_rate
FROM
    (SELECT 
        SUM(action = 'sent_weekly_digest'
                OR action = 'sent_reengagement_email') AS sent,
            SUM(action = 'email_open') AS opened,
            SUM(action = 'email_clickthrough') AS click
    FROM
        email_events) AS sub;
