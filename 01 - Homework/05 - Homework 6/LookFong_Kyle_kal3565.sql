--Kyle Look Fong
--Homework 6
-------------------------------

-------------------------------
--0.Turning on Server Output
-------------------------------
Set serveroutput on;

-------------------------------
--1.
-------------------------------
--Uses an anonymous block of PL/SQL to declare
--count_videos and set it to the count of all videos with
--a topic name of "SQL", if count is greater than 2, say 
--"The number of SQL videos is greater than 2" otherwise it should say
--the number of SQL videos is less than 2, make sure to set serveroutput on

DECLARE
    count_videos        NUMBER;
BEGIN
    SELECT COUNT(video_id) 
    INTO count_videos
    FROM video_topic_linking 
    JOIN topic USING(topic_id)
    WHERE topic_name = 'SQL';
    IF count_videos > 2 THEN dbms_output.put_line('The number of SQL videos is greater than 2'); 
    ELSE dbms_output.put_line('the number of SQL videos is less than or equal to 2');
    END IF;
END;
/



-------------------------------
--2.
-------------------------------
set define on; -- run this commend to allow variable substitutions
--update #1 to prompt user to enter user_id and dynamically pull the count
--of all videos entered by the user, dynamically output the name of user as well
DECLARE
    Users_id    NUMBER;
    video_count NUMBER;
    names       VARCHAR(20);
    
BEGIN
    Users_id := &Users_id; 
    SELECT  
        COUNT(video_id),
        first_name || ' ' || last_name 
        INTO video_count, names
    FROM Video
    LEFT JOIN ContentCreator USING(ContentCreator_id)
    LEFT JOIN Browser_User USING(user_id)
    WHERE user_id = Users_id
    GROUP BY first_name || ' ' || last_name;
    IF video_count > 2 THEN 
        dbms_output.put_line('The number of videos for ' || names || 'is greater than 2'); 
    ELSE dbms_output.put_line('The number of videos for ' || names || ' is less than or equal to 2');
    END IF;
END;
/


-------------------------------
--3. 
-------------------------------
--Write a script that attempts to insert a new comment into the comments
--table for video number 100001. Choose a random user to make the comment
-- if successful, 1 row was inseted... if not Row was not inserted

DECLARE 
    new_comment     VARCHAR(120);
    user_id         NUMBER(5);
BEGIN
    new_comment := &new_comment; -- need to put comment in quotes
    user_id := &user_id;
    INSERT INTO Comments(video_id, user_id, time_date, comment_body)
        --default comment_id is the nextval
        --pre-defined video number 100001, random user = 10000
    VALUES(100001, user_id, SYSDATE, new_comment);
    dbms_output.put_line('1 row was inserted into the comments table');

EXCEPTION
    WHEN others THEN
        dbms_output.put_line('Row was not inserted. Unexpected Exception Occured');
END;
/


-------------------------------
--4. 
-------------------------------
--Create #3 into a procedure that passes in the video_id, user_id, 
--and text for the comment. Still using the sequence to generate id
--and the date is the sysdate. 
--When exception, rollback the call
CREATE OR REPLACE PROCEDURE insert_comment(
    video_id IN NUMBER,
    user_id IN NUMBER,
    new_comment IN VARCHAR
)  IS
BEGIN
    INSERT INTO Comments(video_id, user_id, time_date, comment_body)
        --default comment_id is the nextval
        --pre-defined video number 100001, random user = 10000
    VALUES(video_id, user_id, SYSDATE, new_comment);
    dbms_output.put_line('1 row was inserted into the comments table');

EXCEPTION
    WHEN others THEN
        ROLLBACK;
        dbms_output.put_line('Row was not inserted. Unexpected Exception Occured');
END;
/ 

----- Testing the code
CALL insert_comment (100001, 10003,'I think Tricia is the cats pajamas!');

BEGIN
     insert_comment (100001, 10004,'But Tej is the bomb too!!!');
END;
/  



-------------------------------
--5. 
-------------------------------
--Use a bulk collect to capture a list of all comments on video_id 100000
--the rows should be sorted by time_date. Then display a string variable
--with the person and their comment
select * from comments;

DECLARE
    TYPE video_comments IS TABLE OF VARCHAR2(120);
    commented           video_comments;
    vid                 NUMBER;
BEGIN
    -- vid := &vid; -- make it dynamic
    vid := 100000;
    SELECT comment_body
    BULK COLLECT INTO commented
    FROM Comments
    WHERE video_id = vid
    ORDER BY time_date;
    
    FOR i in 1..commented.COUNT loop
        dbms_output.put_line('Person ' || i || ' commented: ' || commented(i));
    END LOOP;
   

END;
/


-------------------------------
--6. 
-------------------------------
--Create a function called count_comments that returned the count
--of comments on a video when it is passed a video_id.

CREATE OR REPLACE FUNCTION count_comments(
    vid NUMBER
) RETURN NUMBER
AS 
    num_comments    NUMBER;
BEGIN
    SELECT count(video_id)
    INTO num_comments
    FROM Comments
    WHERE video_id = vid;
    RETURN num_comments;
END;
/
--Checking the function
select video_id, title, count_comments(video_id)
from video
order by count_comments(video_id) desc;

