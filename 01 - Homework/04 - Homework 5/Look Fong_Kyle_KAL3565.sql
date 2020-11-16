--Kyle Look Fong
--Homework 5
-----------------------------




--1. Pull 6 columns from DUAL. Use TRIM to reduce unwanted whitespace
--1.1 System date without formatting and no alias
--1.2 System date with year written out in all caps
--1.3 System date with day of week and month spelled out in all caps
--1.4 System date with time rounded to the nearest hour
--1.5 System date with formatting that creates an output of the day as a 
--      number of days until the end of the year
--1.6 System date with abreviated month and abbreviated spelled out day of 
--      week in lowercase with number year

SELECT 
    SYSDATE unformatted,
    TRIM(TO_CHAR(SYSDATE, 'DD-MON-YEAR')) upp_year,
    TRIM(TO_CHAR(SYSDATE, 'DAY-MONTH-YYYY')) upp_day_month,
    TRIM(TO_CHAR(ROUND(SYSDATE, 'HH'), 'DD-MON-YYYY HH:MI:SS')) rounded_hours,
    TRIM(ROUND(TO_DATE('31-DEC-2020') - SYSDATE, 3)) days_left,
    TRIM(TO_CHAR(SYSDATE, 'MON-day-YYYY')) abbreviated
FROM DUAL;


--2. Select a row for each video that contains the following columns
--2.1 Video ID
--2.2 Upload Date, but with a literal string with Posted on as prefix
--2.2 Get rid of excess white spaces that may occur
--2.3 Revenue formatted to include a $, if it doesn't have revenue
--2.3 Use the NVL2 and display "None generated" if no revenue
--2.4 Sort by Upload Date DESC

SELECT 
    video_id,
    TRIM('Posted on ' || CAST(upload_date AS VARCHAR(9))) up_date,
    NVL2(revenue, '$'|| revenue, 'None generated') revenue
FROM Video
ORDER BY 1 DESC;


--3. Pull a list of usernames formatted with the first initial
--in lowercase and the last initial in all caps (e.g. c.TUTTLE)
--Add A (ONE) column that shows ALL titles for the videos they made
--If there is NULL show none creased
--Sort by title
SELECT * FROM Browser_User;
SELECT * FROM ContentCreator;
SELECT * FROM VIDEO;

SELECT 
    substr(first_name, 1, 1) || '.' || UPPER(last_name) username,
    title all_videos
    
FROM (
    SELECT first_name, 
        last_name, 
        LISTAGG(NVL2(title, title, 'None Generated'), ', ') WITHIN GROUP(ORDER BY first_name) title
    FROM Browser_User
    LEFT JOIN ContentCreator USING(user_id)
    LEFT JOIN Video USING(ContentCreator_id)
    GROUP BY first_name, last_name
    
);


--4. Select the video_id all lowercase, alias Vid_ID
--formatted likes columns Points (100 likes = 1 point) named video_points
--format to a whole number
--Video Award Percentage, if you get 500 points, you are needed a full
--reward, format as whole numnber with a % symnol, trimmed space
--Order by video_award_percent Descending

SELECT 
    video_id Vid_ID,
    NVL2(likes, ROUND(likes/100, 0), 0) video_points,
    NVL2(likes, TRIM(ROUND(likes/100/5, 0) || '%'), 0) video_award_percent      
FROM VIDEO
ORDER BY 
    CAST(REPLACE(video_award_percent, '%', '') AS NUMBER) --Did not 
                                                --recognize % as number
    DESC;
    
    
--5. Select from creditcards
--Content Creator id
--billing address length, length of street billing
--days until card expiration, days between expiration date and today
--rounded to nearest day
--use a WHERE to pull cards only 120 days away from expiring or earlier
--order by expiration date old->new

SELECT 
    ContentCreator_id,
    LENGTH(street_billing) length_billing,
    ROUND(exp_date - SYSDATE, 0) exp_days
FROM CreditCard
WHERE ROUND(exp_date - SYSDATE, 0) <= 120
ORDER BY 3 ASC --Negative numbers = have already expired
;


--6. Select the last name from users,
--column called street_num that returns the street number from 
--street_billing, street_name = name after first space orrurance
--middle name, if null = not listed else does list
--city, state, zip, no formatting

SELECT DISTINCT
    last_name, 
    SUBSTR(street_billing, 0, INSTR(street_billing, ' ')) street_num,
    SUBSTR(street_billing, INSTR(street_billing, ' ')) street_name,
    NVL2(middle_name,'Does List', 'None Listed') mid_name_listed,
    city_billing,
    state_billing,
    zip_code_bill
FROM CreditCard cards,
    (
        SELECT middle_name, last_name, contentcreator_id
        FROM Browser_User
        JOIN ContentCreator USING(user_id)
    ) creators
WHERE cards.ContentCreator_id = creators.ContentCreator_id
--No order by listed
; 


--7. Select the distinct columns for payment profiles
--the cc_username from the cc table
--redacted mobile, masks all numbers except first two and last four
--sort by username

SELECT 
    cc_username,
    REPLACE(mobile, SUBSTR(mobile, 3,6), '-***-***-') mobile
FROM ContentCreator;



--8. Select the same results from *QUERY* but use a CASE
--statement to change the tier column
-------------------------------------------
        select '1-Top-Tier' as video_tier, video_id, revenue, views
        from video
        where views >5000000
            union
        select '2-Mid-Tier' as video_tier, video_id, revenue, views
        from video
        where views >=1000000 and views <=5000000
            union
        select '3-Lower-Tier' as video_tier, video_id, revenue, views
        from video
        where views <1000000
        order by views desc;
-------------------------------------------
SELECT 
    CASE 
        WHEN views >5000000 THEN '1-Top-Tier'
        WHEN views >=1000000 and views <=5000000 THEN '2-Mid-Tier'
        ELSE '3-Lower-Tier'
        END video_tier,
    video_id,
    revenue,
    views
FROM Video
ORDER BY 4 DESC;



--9. Select the first name and last name for each user
--The count of videos (video_id)
--total revenue earned for each user
--influencer rank based on the total revenue earned, order by rank

SELECT 
    first_name,
    last_name,
    count_of_videos,
    total_revenue,
    RANK() OVER(ORDER BY total_revenue DESC) influencer_rank
FROM Browser_User browsers,
(
    SELECT user_id, 
        COUNT(video_id) count_of_videos, 
        SUM(revenue) total_revenue
    FROM Video
    JOIN ContentCreator USING(ContentCreator_id)
    GROUP BY user_id
)
creator
WHERE browsers.user_id = creator.user_id
;



--10. Update #9 to return a row_number, first_name, last_name, count
--of videos, total_revenue, sort by revenue desceding, do not use the
--ROWNUM, user row_number(). Make it an inline sunquery and select *
--but only return row number 4 

SELECT * 
FROM 
(
    SELECT 
        row_number() OVER(ORDER BY total_revenue DESC) row_number,
        first_name,
        last_name,
        count_of_videos,
        total_revenue
    FROM Browser_User browsers,
    (
        SELECT user_id, 
            COUNT(video_id) count_of_videos, 
            SUM(revenue) total_revenue
        FROM Video
        JOIN ContentCreator USING(ContentCreator_id)
        GROUP BY user_id
    )
    creator
    WHERE browsers.user_id = creator.user_id
) rownumbers
WHERE rownumbers.row_number = 4
;
