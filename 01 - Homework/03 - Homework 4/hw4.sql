--Kyle Look Fong
--Homework 4
--MIS 325
------------------------------------------------
------------------------------------------------


--1.
------------------------------------------------
--Write a select statement that returns a single row
--with these columns: the count of distinct users
--with a column alias of user_count,
--the minimum of video_length column in the video table
--with alias min_video_length
--the highest video views in the video table with the alias
--max views : NOTE Instructions did not have underscore

SELECT 
    DISTINCT (COUNT(title)) AS title_count, 
    MIN(video_length) AS min_video_length,
    MAX(views) AS "max views"

FROM VIDEO;




--2.
------------------------------------------------
--Select that returns one row for following:
--title column for the video table -- table aliases
--the count of the comments in the comments table with user_comments alias
--comment time date that is most recent, alias: recent_comment
--Sort from oldest to newest
SELECT 
    title,
    COUNT(comment_body) AS user_comments, 
    MAX(time_date) AS recent_comment
FROM (
    SELECT 
        title, 
        comment_body, 
        time_date  
    FROM Video
    JOIN Comments 
        USING(video_id)
    )
GROUP BY title
ORDER BY recent_comment
;


--3.
------------------------------------------------
--Select info about users and their video info. 
--If user has no video, ignore them. For each city, show 
--The city column from the ContentCreator table,
--the count of users from that city alias: user_count,
--the average video likes for users from that city, round to nearest whole
--alias: average_video_likes
--sort DESC average_video_likes and asc user_count

SELECT 
    city, 
    count(city) AS user_count, 
    avg(likes) AS average_video_likes
FROM Video
JOIN ContentCreator USING (cc_id)
GROUP BY city
ORDER BY average_video_likes DESC, user_count
;



--4.
------------------------------------------------
--Join the video and topic tables and return 
--the topic_id column
--the topic_name column
--the average video_size with alias avg_topic_video_size
--total number of likes for each topic with alias topic_like_count
SELECT 
    topic_id, 
    topic_name, 
    avg(video_size) AS avg_topic_video_size,
    sum(likes) AS topic_like_count
FROM video_topic_linking
JOIN video USING (video_id)
JOIN topic USING (topic_id)
GROUP BY topic_id, topic_name
ORDER BY 3 DESC
;


--5.
------------------------------------------------
--Return one row for each user that has a CC account and videos 
--attached. Columns:
--First name column from browser user
--last name from browser user
--awards_earned -> (views - 100 baseline)/5000 whole number that does no
--round up

SELECT 
    first_name,
    last_name,
    TRUNC((sum(views)-100)/5000, 0) AS awards_earned
FROM browser_user
JOIN ContentCreator USING(user_id)
JOIN Video USING(cc_id)
WHERE user_id IN 
    (
    SELECT 
        user_id 
    FROM Video
    JOIN ContentCreator USING(cc_id)
    )
GROUP BY first_name, last_name
HAVING TRUNC((sum(views)-100)/5000, 0) >= 10
ORDER BY awards_earned DESC, last_name
;




--6.
------------------------------------------------
--Modify #5 to only include videos that have a video longer than 8 minutes
--Add it to a WHERE clause so it removes any user rows before grouping
SELECT 
    first_name,
    last_name,
    TRUNC((sum(views)-100)/5000, 0) AS awards_earned
FROM browser_user
JOIN ContentCreator USING(user_id)
JOIN Video USING(cc_id)
WHERE user_id IN 
    (
    SELECT 
        user_id 
    FROM Video
    JOIN ContentCreator USING(cc_id)
    WHERE video_length >= 480
    )
GROUP BY first_name, last_name
HAVING TRUNC((sum(views)-100)/5000, 0) >= 10
ORDER BY awards_earned DESC, last_name
;




--7. ***************  REVISE  ***************
------------------------------------------------
--PART A - Show the count of credit cards broken
--out by first_name, city, billing, and state billing
--first name from browser_user,
--city_billing from creditcard, state from credit card
--count of credit card_id with appropriate alias
--filter so only in Texas and NY
--sort by city
--ROLLUP operator to include a row that gives the subtotal city_billing and
--state_billing

SELECT 
    first_name, 
    last_name, 
    city_billing, 
    state_billing, 
    count(card_id) AS card_count,
    count(city_billing) +
    count(state_billing) AS subtotal
    
FROM CreditCard
JOIN ContentCreator ON CreditCard.ContentCreator_id = ContentCreator.cc_id
JOIN Browser_User USING (user_id)
GROUP BY ROLLUP(city_billing, 
    state_billing, first_name, last_name)
HAVING state_billing IN ('TX', 'NY')
ORDER BY city_billing;

--PART B: explain in a commented sentence how the CUBE is dfferent from ROLLUP
--and why it's useful
--CUBE allows a SELECT statement to calculate subtotals for all possible combinations 
--of a group of dimensions, also creating a grand total; this is useful because
--it allows us to create even more subtotals than ROLLUP


--8.
------------------------------------------------
--Write select statement that displays cc_id and count of video_id of all
--videos a content creator has; in the third column called unique_topics
--display the count of distinct topics for videos created by a certain creators
--only show results if they had at least 2 distinct topics, sort by cc_id desc
SELECT * FROM video_topic_linking;
SELECT cc_id, 
    COUNT(video_id) AS video_count, 
    COUNT(DISTINCT topic_id) AS distinct_topic_count
FROM VIDEO
JOIN video_topic_linking USING (video_id)
GROUP BY cc_id
HAVING COUNT(DISTINCT topic_id) >= 2;



--9.
------------------------------------------------
--Write a SELECt Statement that returns the same set of results as following
--Don't use a join, use a subquery in the where that uses the in
            --NOTE: THIS IS THE QUERY FROM INSTRUCTIONS
--------------------------------------
SELECT DISTINCT topic_name
FROM topic t JOIN video_topic_linking vtl --Changed to fit my tables
ON t.topic_id = vtl.topic_id JOIN video v
ON vtl.video_id = v.video_id
ORDER BY topic_name DESC;
--------------------------------------

SELECT DISTINCT topic_name 
FROM Topic
WHERE topic_id IN
    (
    SELECT 
        topic_id 
    FROM video_topic_linking
    )
ORDER BY topic_name DESC;



--10.
------------------------------------------------
--Write a select statement that answers this question:
--  Which content creators have created a video that has greater than
--  the averge likes for all videos; return the cc_id, video_id and likes for
--  each video that fits the criteria, sort by likes desc
SELECT 
    cc_id, 
    video_id, 
    likes
FROM VIDEO
WHERE likes > (
    SELECT 
        AVG(likes) 
    FROM video
    )
ORDER BY likes DESC
;


--11.
------------------------------------------------
--Pull together a target customer contact list that contains all the 
--users who have signed up for a CC account but have not uploaded a video
--Select the first, last, email, cc_flag, and birthdate from browser_user,
--return one row per person, use a subquery that pulls the cc_id that has no cooresponding
--cc_id in the video table.
SELECT 
    first_name,
    last_name,
    email,
    cc_flag,
    birthdate
FROM Browser_user
JOIN ContentCreator ON Browser_user.user_id = ContentCreator.user_id
WHERE Browser_User.user_id IN
    (
    SELECT user_id 
    FROM ContentCreator
    WHERE cc_id NOT IN
        (
        SELECT 
            cc_id 
        FROM VIDEO
        )
    )
GROUP BY first_name, last_name, email, cc_flag, birthdate, city
ORDER BY city
;




--12.
------------------------------------------------
--Write select statement that returns title, subtitle, size, views, and number
--of comments for videos that have at least two comments on them
--sort by number of comments
SELECT 
    title, 
    subtitle, 
    video_size, 
    views, 
    ((
        SELECT 
            COUNT(video_id)
        FROM Comments
        WHERE comments.video_id = Video.video_id
    )) AS comment_count
FROM VIDEO
WHERE video_id IN
    (
    SELECT 
        video_id
    FROM Comments
    GROUP BY video_id
    HAVING 
        COUNT(comment_body) >= 2
    )
GROUP BY 
    video_id, 
    title, 
    subtitle, 
    video_size, 
    views
ORDER BY comment_count
;



--13.
------------------------------------------------
--Write a select statement that returns the video_id for videos with
--comments
--use ^  as a subquery, with it returning the user_id, last_name, first_name, 
--and count of video_id, aliased as num_videos, use a LEFT join within the subquery
--as an inline view, order by last_name
SELECT 
    browsers.user_id,
    last_name,
    first_name,
    COUNT(video_id) AS numb_video
FROM Browser_user browsers,
    (
    SELECT 
        ContentCreator.user_id, 
        Video.video_id 
    FROM Comments
    LEFT JOIN Video ON Comments.Video_id = Video.Video_id
    LEFT JOIN ContentCreator USING(cc_id)
    ) ids 
WHERE browsers.user_id = ids.user_id 
GROUP BY browsers.user_id, last_name, first_name
;



--14.
------------------------------------------------
--Using an inline view, write a statement that will return one row
--per content creator, representing the most recent video
--the person has made, lowest number of days between upload and sysdate
--each row should have cc_id, first name, last name, username, days since latest
--upload
--Using an inline view: subquery in the main query's FROM clause, that will
--join the Content Creator to and contains the aggregate function,
--DO NOT put an aggregate in the main query
SELECT 
    cc_id, 
    first_name, 
    last_name, 
    cc_username, 
    days_between
FROM Browser_User browser, (
    SELECT 
        cc_id,
        user_id,
        cc_username,
        ROUND(MIN(SYSDATE - upload_date), 1) AS days_between
    FROM Video 
    JOIN ContentCreator USING (cc_id)
    GROUP BY 
        cc_id,
        user_id,
        cc_username
    ORDER BY days_between
    FETCH FIRST 1 ROWS ONLY
    ) days_query
WHERE browser.user_id = days_query.user_id
;

