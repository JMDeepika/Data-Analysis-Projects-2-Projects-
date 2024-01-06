/* Skills Used : Aggregate Functions, JOINs, Subqueries, Sorting Functions, Managing DataBases(Create and Merge Table), View and Basic SQL queries */

/*   A)   MARKETING TEAM        */

/* MARKETING TEAM  - ##1## Rewarding most loyal Users - the users who have been using the platform for the longest time */
SELECT * FROM users ORDER BY created_at LIMIT 5;

/* MARKETING TEAM - ##2## Inactive users - the users who have not posted a single photo */
SELECT username, id FROM users WHERE id NOT IN(SELECT DISTINCT user_id FROM photos);

/* MARKETING TEAM  - ##3## Contest Winner - The user with most likes on a single photo */
SELECT users.id as user_id, username, image_url, photos.id as photo_id  FROM users LEFT JOIN photos ON photos.user_id = users.id
WHERE photos.id = (SELECT photo_id FROM likes GROUP BY photo_id ORDER BY COUNT(photo_id) DESC LIMIT 1);

# created view to find the most liked photo since it is complex

CREATE VIEW Most_Liked_Photo_ID AS
SELECT photo_id FROM likes GROUP BY photo_id ORDER BY COUNT(photo_id) DESC LIMIT 1;

/* MARKETING TEAM - ## 4 ## Hashtag Researching */
SELECT id, tag_name, COUNT(tag_id) FROM tags join photo_tags
on tag_id = tags.id GROUP BY tag_id ORDER BY count(tag_id) DESC LIMIT 5;

/* MARKETING TEAM   -  ##5## Launch AD Campaign  */
SELECT DAYNAME(created_at) day_name, Count(created_at) FRE, weekday(created_at) sort FROM users 
group by day_name, sort ORDER BY sort;
/* THURSDAY & SUNDAY */

/*    B)  INVESTOR METRICS     */
/*     ##1## User Engagement    */
SELECT count(distinct image_url)/ count(distinct user_id) FROM photos;
SELECT count(distinct photos.id) As total_photos, count(distinct users.id) AS total_users FROM photos inner JOIN Users;

/*      ##2##  Bots & Fake Accounts     */
SELECT * FROM USERS WHERE id IN (SELECT user_id FROM Likes GROUP BY user_id HAVING count(user_id) = (SELECT Count(id) from PHOTOS));

