
                --QUIZ 3 REVIEW
-------------------------------------------------

--1. Simple GROUP BY Expression with Aggregate Function
SELECT city, COUNT(city) 
FROM Browser_User
GROUP BY city;


--2. Subquery using WHERE IN
SELECT video_id, subtitle, likes
FROM Video 
WHERE video_id IN(
    SELECT video_id
    FROM Comments
)
;

--2A. Using ALL Keyword
SELECT video_id, avg(likes)
FROM Video
GROUP BY video_id
HAVING avg(likes) < ALL(
    SELECT AVG(likes) FROM Video
    GROUP BY video_id
    HAVING avg(likes) <> 0
)
;


--3. Subquery as column
SELECT 
    title, 
    subtitle, 
    video_size, 
    views, 
    (( --NEED to have the double parenthesis
        SELECT 
            COUNT(video_id)
        FROM Comments
        WHERE comments.video_id = Video.video_id
    )) AS comment_count
FROM VIDEO 
;


--4. Using an Inline View
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


--5. Using CASE
SELECT vendor_name,
    vendor_address1 || ' ' ||
    CASE vendor_address2 
        WHEN 'NULL' 
        THEN '' 
        ELSE vendor_address2 
        END
    AS "Full Address"
FROM VENDORS;