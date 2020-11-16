--Kyle Look Fong
--MIS 325
--Homework 3


------------------------------------------------------------
--1. Write a select statement that returns the columns
    --first name, last name, email, and birthdate
--from the user table. Add an order by statenents to last name in asc
SELECT 
    first_name,
    last_name,
    email,
    birthdate
FROM User_table
ORDER BY last_name;

------------------------------------------------------------
--2. Return one column from user table, user_full name combining first/last
--order by first name in descending order
--return only the users whose last names begins with K, L, or M
SELECT first_name || ' ' || last_name AS "Full Name"
FROM User_table
WHERE SUBSTR(last_name, 1, 1) IN ('K','L','M')
ORDER BY first_name DESC;

------------------------------------------------------------
--3. Select title, subtitle, upload_date, views, and likes from videos
--Only rows with an upload date between the beginning of this year and last week
--use the BETWEEN operator, sort in descending order by upload_date
SELECT title,
    subtitle, 
    upload_date,
    views,
    likes
FROM Video
WHERE upload_date BETWEEN DATE '2020-01-01' AND DATE '2020-10-18'
ORDER BY upload_date DESC;



------------------------------------------------------------
--4. Duplicate previous query and update the where clause to
--use <, >, <=, or >=.
SELECT title,
    subtitle, 
    upload_date,
    views,
    likes
FROM Video
WHERE upload_date >= DATE '2020-01-01' AND upload_date <= DATE '2020-10-18'
ORDER BY upload_date DESC;



------------------------------------------------------------
--5. Write a select statement that returns the column names and data from tehe video table
--video_id
--video_size
--likes
--video_length
--video_length_min
--Get only the first three rows from the table
--sort by the Likes_Earned alias
--return a while number for the video_length_min, truncate the decimal
SELECT * FROM (
    SELECT video_id,
        video_size AS "video_size_MB",
        likes AS "Likes_Earned",
        video_length AS "Video_length_sec",
        TRUNC(video_length/60) AS "video_length_min"
    FROM Video
    ORDER BY 5
    )
WHERE ROWNUM <= 3
ORDER BY "Likes_Earned";



------------------------------------------------------------
--6. Select statement that returns these columns
--user id
--video_id
--popularity, the likes column
--awards, the likes column but calculated, truncated*
--post_date, upload_date column with an alias

--*every 5000 likes that are accrued, 
--filter where awards earned is greater than 5
SELECT user_id,
    video_id,
    likes as "popularity",
    TRUNC(likes/5000) AS "awards",
    upload_date AS "post_date" 
FROM (
SELECT * FROM Video
JOIN Content_creators
ON Video.cc_id = Content_creators.cc_id)
WHERE TRUNC(likes/5000) >= 5;


------------------------------------------------------------
--7. Return the first, last, middle name, and email from user_table
--return only rows that have a value in middle name using a NULL operator
--sort by last name
SELECT first_name,
    middle_name,
    last_name,
    email
FROM User_table
WHERE middle_name IS NULL
ORDER BY 3;



------------------------------------------------------------
--8. Write a select statement that uses the SYSDATE to create a new row
--today_unformatted: Sysdate unformatted
--today_formatted, formatted as mm/dd/yyyy
SELECT SYSDATE AS "today_unformatted",
    TO_CHAR(SYSDATE, 'MM/DD/YYYY') AS "today_formatted",
    1000 AS "likes",
    0.0325 AS "pay_per_like",
    10 AS "pay_per_video",
    1000 * 0.0325 AS "pay_per_like",
    10 + (1000 * 0.0325) AS "video_sum"
    FROM Dual
;


------------------------------------------------------------
--9. Write a select statement that 
--pulls video_id, title, video_length, and size columns from Video
--sort by length, largest to smallest,
--only pull top three rows
--sort the data before filtering the three rows
SELECT video_id,
    title, 
    video_length,
    video_size
FROM Video
ORDER BY 3 DESC
FETCH FIRST 3 ROWS ONLY;


------------------------------------------------------------
--10. Write a select statement that joins the user and comments table
--and returns the columns
SELECT cc_flag AS "Status", 
    first_name, 
    last_name, 
    birthdate, 
    comment_body 
FROM (
    SELECT * FROM User_Table
    FULL OUTER JOIN comments
    ON User_Table.user_id = comments.user_id
    )
;


------------------------------------------------------------
--11. Write a select statement that pulls the user and their subscription info
--will require joining three tables
--User_id
--user_name
--topic_id
--topic_name
--Return the subscription details where the user's subscribed to the SQL topic
SELECT user_id, 
    first_name || ' ' || middle_name || ' ' || last_name AS "user_name", 
    topic_id, 
    topic_name
FROM (
    SELECT * From user_topic_subsc
    LEFT OUTER JOIN User_table USING (user_id)
    LEFT OUTER JOIN Topic  USING(topic_id)
    WHERE topic_name = 'SQL'
    )
;


------------------------------------------------------------
--12. Select that joins tables to sohw video title,
--subtitle, user's first name, last name, cc flag, comment body
--ONLY where video_id = 100000 ,
--sort by last_name, first_name
SELECT title,
    subtitle,
    first_name,
    last_name,
    cc_flag,
    comment_body
FROM (
    SELECT * FROM Video
    JOIN content_creators USING (cc_id)
    JOIN User_table USING (user_id)
    JOIN Comments USING(video_id)
    WHERE video_id = 100000 
    )
;



------------------------------------------------------------
--13. Write a select statement that pulls the distinct first,
--last emails for users that have not commented on a video yet
--use a left outer join to accomplish this
--sort by last name
SELECT DISTINCT first_name, last_name, email 
FROM User_table 
WHERE user_id NOT IN (
    SELECT user_id FROM Comments
    LEFT OUTER JOIN User_Table USING (user_id)
    )
;




------------------------------------------------------------
--14. Use the UNION operator to generate a result set 
--consisting of three column
--from the video table:
--video_tier == 1-top tier, 2-mid tier or 3-low tier
--video_id -- video_id
--revenue
--views
SELECT video_id, revenue, views, '1-Top-Tier' video_tier
FROM Video
WHERE views >= 30000

UNION SELECT video_id, revenue, views, '2-Mid-Tier' video_tier
FROM Video
WHERE views BETWEEN 20000 AND 30000

UNION SELECT video_id, revenue, views, '3-Low-Tier' video_tier
FROM Video
WHERE views < 20000

ORDER BY revenue DESC
;





