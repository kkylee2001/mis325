--Kyle Look Fong (EID: kal3565)
--DESCRIPTION: DDL Statements for a video sharing sites that allow content creators to be paid
-- and for each user to interact with videos
--MIS325
--Homework 2





------------------------------------------------------
--DROP STATEMENTS
------------------------------------------------------

--DROP Statements for all Tables, foreign key tables first
DROP TABLE Video_topic_linking;
DROP TABLE Comments;
DROP TABLE User_topic_subscr;
DROP TABLE CreditCard;
DROP TABLE Video;
DROP TABLE ContentCreator;
DROP TABLE Browser_User;
DROP TABLE Topic;
--DROP Statements for all Sequences
DROP SEQUENCE user_seq;
DROP SEQUENCE card_seq;
DROP SEQUENCE topic_seq;
DROP SEQUENCE video_seq;
DROP SEQUENCE comment_seq;
DROP SEQUENCE user_topic_seq;
DROP SEQUENCE content_creator_seq;






------------------------------------------------------
--CREATE STATEMENTS - SEQUENCES
------------------------------------------------------
--CREATE SEQUENCE for all primary keys
--user_id sequence, starting at 1000000, incrementing by 1 and all numbers take up same space
CREATE SEQUENCE user_seq
    START WITH 1000000
    INCREMENT BY 1
    CACHE 7
    ORDER;

--card_id sequence, starting at 1000000, += 1, same space of numbers
CREATE SEQUENCE card_seq
    START WITH 1000000
    INCREMENT BY 1
    CACHE 7
    ORDER;
    
--topic_id sequence, starting at 1000000, += 1, same space of numbers
CREATE SEQUENCE topic_seq
    START WITH 1000000
    INCREMENT BY 1
    CACHE 7
    ORDER;

--video_id sequence, starting at 1000000, += 1, same space of numbers
CREATE SEQUENCE video_seq
    START WITH 1000000
    INCREMENT BY 1
    CACHE 7
    ORDER;

--comment_id sequence, starting at 1000000, += 1, same space of numbers
CREATE SEQUENCE comment_seq
    START WITH 1000000
    INCREMENT BY 1
    CACHE 7
    ORDER;
    
    
--user_topic_id sequence, starting at 1000000, += 1, same space of numbers
CREATE SEQUENCE user_topic_seq
    START WITH 1000000
    INCREMENT BY 1
    CACHE 7
    ORDER;

--content_creator_id sequence, starting at 1000000, += 1, same space of numbers
CREATE SEQUENCE content_creator_seq
    START WITH 1000000
    INCREMENT BY 1
    CACHE 7
    ORDER;
    
    
    

------------------------------------------------------
--CREATE STATEMENTS - TABLES
------------------------------------------------------
--CREATE Statements for all tables, starting with PK Tables
CREATE TABLE Topic
(
    topic_id        NUMBER(7)       PRIMARY KEY,
    topic_name      VARCHAR(15)     NOT NULL,
    topic_desc      VARCHAR(75)     NOT NULL
);


CREATE TABLE Browser_User
(
    user_id         NUMBER(7)       PRIMARY KEY,
    first_name      VARCHAR(10)     NOT NULL,
    middle_name     VARCHAR(10), --Middle name can be nullable
    last_name       VARCHAR(15)     NOT NULL,
    birthdate       DATE            NOT NULL,
    email           VARCHAR(30)     NOT NULL        UNIQUE, --email addresses should be unique, so someone doesn't create multiple accounts with one
    CC_flag         VARCHAR(1)      DEFAULT 'N'     CHECK(CC_flag = 'Y' or CC_flag =  'N'), --default values cannot be declared not null
    date_created    DATE            DEFAULT SYSDATE --Because you cannot put sysdate in a check function
);

ALTER TABLE Browser_User
     ADD CONSTRAINT age_check CHECK((MONTHS_BETWEEN(date_created, birthdate))/12 >= 13); 
        --Checking the number of years (by dividing the months between by 12) to check age
ALTER TABLE Browser_User
    ADD CONSTRAINT email_length_check   CHECK(LENGTH(email) >= 7);
        --The email must be greater than 7 characters

CREATE TABLE ContentCreator
(
    ContentCreator_id       NUMBER(7)       PRIMARY KEY,
    user_id                 NUMBER(7)       REFERENCES Browser_User(user_id), --Foreign key, browser user table
    username                VARCHAR(15)     NOT NULL        UNIQUE, --usernames should be unique
    street_address          VARCHAR(30)     NOT NULL,
    city                    VARCHAR(15)     NOT NULL,
    state                   VARCHAR(15)     NOT NULL,
    zip_code                NUMBER(5)       NOT NULL,
    state_residence         VARCHAR(15)     NOT NULL,
    country_res             VARCHAR(20)     NOT NULL,
    mobile                  CHAR(12)        NOT NULL        UNIQUE, --Assuming that no user can have the same phone as another
    tier_level              VARCHAR(1)      NOT NULL    --Assuming that the tier level is 1,2,3,4...9, with 1 being free                   
);


CREATE TABLE Video
(
    video_id            NUMBER(7)       PRIMARY KEY,
    ContentCreator_id   NUMBER(7)       NOT NULL        REFERENCES ContentCreator(ContentCreator_id),
    title               VARCHAR(100)    NOT NULL        UNIQUE,
    subtitle            VARCHAR(100)    NOT NULL,
    upload_date         DATE            DEFAULT SYSTIMESTAMP, --Default will be the day it is created
    video_length        NUMBER(5)       NOT NULL, --Length in Seconds (e.g. a minute video = 60)
    video_size          NUMBER(4)       NOT NULL, --Size in mb (e.g. 2.3gb = 2300), assuming nothing over 9.99gb
    views               NUMBER(8)       DEFAULT 0, --Video will default to a view count 0, like count 0 , and revenue 0
    likes               NUMBER(8)       DEFAULT 0,
    revenue             NUMBER(8)       DEFAULT 0
);


CREATE TABLE CreditCard
(
    card_id             NUMBER(7)       PRIMARY KEY,
    ContentCreator_id   NUMBER(7)       NOT NULL        REFERENCES ContentCreator(ContentCreator_id), --Foreign key, content creator id
    card_type           VARCHAR(18)     NOT NULL, --e.x. American Express
    card_num            CHAR(19)        NOT NULL        CHECK(LENGTH(card_num) >= 16), --in case someone puts 4444-4444-4444-4444
    exp_date            DATE            NOT NULL, 
    CC_id               NUMBER(3)       NOT NULL, --Assuming this is the security code on the back of the card
    street_billing      VARCHAR(20)     NOT NULL,
    city_billing        VARCHAR(20)     NOT NULL,
    state_billing       VARCHAR(15)     NOT NULL,
    zip_code_billing    NUMBER(5)       NOT NULL
);

ALTER TABLE CreditCard
    ADD CONSTRAINT valid_card CHECK(
        SUBSTR(card_num, 1, 1) = '3' OR -- American Express
        SUBSTR(card_num, 1, 1) = '4' OR --Visa
        SUBSTR(card_num, 1, 1) = '5' OR --Master Card
        SUBSTR(card_num, 1, 1) = '6'); --Discover


CREATE TABLE User_topic_subscr
(
    Topic_Subscription_ID   NUMBER(7)   NOT NULL,
    user_id                 NUMBER(7)   NOT NULL,
    topic_id                NUMBER(7)   NOT NULL
);


CREATE TABLE Comments   
(
    comment_id          NUMBER(7)       NOT NULL,
    video_id            NUMBER(7)       NOT NULL,
    user_id             NUMBER(7)       NOT NULL,
    time_date           DATE            DEFAULT SYSTIMESTAMP, --Timestamp for the comment, default to today
    comment_body        VARCHAR(200)    NOT NULL
);


CREATE TABLE Video_topic_linking
(
    video_id            NUMBER(7)       NOT NULL,
    topic_id            NUMBER(7)       NOT NULL,
    CONSTRAINT vt_pk    PRIMARY KEY(video_id, topic_id) --Primary key is composite, both video and topic
);


------------------------------------------------------
--INSERT INTO STATEMENTS
------------------------------------------------------

--Two Non Content Creators
---------------------------------------
                                    --1. Kyle Look Fong
INSERT INTO Browser_User(user_id, first_name, middle_name, last_name, birthdate, email) --Inserting user, didn't input values for date created or cc_flag
    VALUES(user_seq.NEXTVAL, 'Kyle', 'Anthony', 'Look Fong', to_date('2001/07/17','yyyy/mm/dd'), 'klookfong@utexas.edu');


                                    --2. Tej Anand    
INSERT INTO Browser_User(user_id, first_name, last_name, birthdate, email) --Inserting user, didn't input values for middle name, date created or cc_flag
    VALUES(user_seq.NEXTVAL, 'Tej', 'Anand', to_date('2001/12/25','yyyy/mm/dd'), 'tej_anand@utexas.edu');



--Four Content Creators
--------------------------------------
--Created users and then their videos so that I could use the CURRVAL function rather than inputting their 
--id's individually



                                    --1. Megan "Thee Stallion" Pete
--1. Creating the Browser User Account                                   
INSERT INTO Browser_User(user_id, first_name, middle_name, last_name, cc_flag, birthdate, email) -- Accidently misordered, specified
    VALUES(user_seq.NEXTVAL, 'Megan', 'Jovon Ruth', 'Pete', 'Y', to_date('1995/02/15','yyyy/mm/dd'), 'thee_stallion@utexas.edu');
COMMIT;
--2. Creating the Content Creator for the User
INSERT INTO ContentCreator
    VALUES(content_creator_seq.NEXTVAL, 
            user_seq.CURRVAL, 
            'theestallion', 
            '123 WAP Street', 
            'Houston', 
            'TX', 
            77373, 
            'TX', 
            'United States', 
            '83288888888', 
            3);
COMMIT;
--3. Insert Credit Card info for user, 2 cards
INSERT INTO CreditCard
    VALUES(card_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'MasterCard',
            '5555111122223333',
            to_date('2023/02/20', 'yyyy/mm/dd'),
            123,
            '123 WAP Street', 
            'Houston', 
            'TX', 
            77373);
COMMIT;

INSERT INTO CreditCard
    VALUES(card_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'Visa',
            '4321000099998888',
            to_date('2025/09/20', 'yyyy/mm/dd'),
            987,
            '123 WAP Street', 
            'Houston', 
            'TX', 
            77373);
COMMIT;

--4. Create a Video
INSERT INTO Video -- DEFAULT TO RECENT VALUES
    VALUES(video_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'Savage Remix (feat. Beyonce)',
            'The remix to the infamous tik-tok sound: Savage',
            DEFAULT,
            180,
            800,
            DEFAULT,
            DEFAULT,
            DEFAULT);
COMMIT;





                                    --2. Belcalis "Cardi B" Almanzar
--1. Create the Brower User Account                                    
INSERT INTO Browser_User(user_id, first_name, last_name, cc_flag, birthdate, email)
    VALUES(user_seq.NEXTVAL, 'Belcalis', 'Almanzar', 'Y', to_date('1992/10/11','yyyy/mm/dd'), 'cardib@utexas.edu');    

--2. Creating the Content Creator Account for the User
INSERT INTO ContentCreator
    VALUES(content_creator_seq.NEXTVAL, 
            user_seq.CURRVAL, 
            'cardib', 
            '999 WAP Blvd', 
            'Bronx', 
            'NY', 
            10010, 
            'NY', 
            'United States', 
            '8889001800', 
            2);
COMMIT;

--3. Insert Credit Card info for the user
INSERT INTO CreditCard
    VALUES(card_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'Visa',
            '4000300020001000',
            to_date('2024/10/10', 'yyyy/mm/dd'),
            999,
            '999 WAP Blvd', 
            'Bronx', 
            'NY', 
            10010);
COMMIT;

--4. Create a Video
INSERT INTO Video -- DEFAULT TO RECENT VALUES
    VALUES(video_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'WAP (feat. Megan Thee Stallion)',
            'A modern perspective on sexuality in society',
            to_date('2020/08/29','yyyy/mm/dd'),
            194,
            870,
            10000000,
            100000,
            10000000);
COMMIT;





    
                                    --3. Onika "Nicki Minaj" Maraj
--1. Creating the browser_user account
INSERT INTO Browser_User(user_id, first_name, middle_name, last_name, cc_flag, birthdate, email)
    VALUES(user_seq.NEXTVAL, 'Onika', 'Tanya', 'Maraj', 'Y', to_date('1982/12/08','yyyy/mm/dd'), 'nicki_minaj@utexas.edu');
--2. Creating the Content Creator for the User
INSERT INTO ContentCreator
    VALUES(content_creator_seq.NEXTVAL, 
            user_seq.CURRVAL, 
            'nickiminaj', 
            '800 Barbie Blvd', 
            'Manhattan', 
            'NY', 
            10001, 
            'NY', 
            'United States', 
            '9990009999', 
            3);
COMMIT;
--3. Insert Credit Card info for user
INSERT INTO CreditCard
    VALUES(card_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'MasterCard',
            '5432098765434321',
            to_date('2030/01/01', 'yyyy/mm/dd'),
            444,
            'Barbie Blvd', 
            'Manhattan', 
            'NY', 
            10001);  
COMMIT;  
--4. Create a Video
INSERT INTO Video -- DEFAULT TO RECENT VALUES
    VALUES(video_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'No Frauds',
            'A response to the diss-record Shether (Remy Ma)',
            to_date('2018/12/30','yyyy/mm/dd'),
            200,
            783,
            900324,
            10543,
            77432);
COMMIT;
    
    
    

                                    --4. Amala "Doja Cat" Dlamini
--1. Create the browser user account
INSERT INTO Browser_User(user_id, first_name, middle_name, last_name, cc_flag, birthdate, email)
    VALUES(user_seq.NEXTVAL, 'Amala', '"Doja Cat"', 'Dlamini', 'Y', to_date('1995/10/21','yyyy/mm/dd'), 'doja_cat@utexas.edu');
--2. Create the content creator account
INSERT INTO ContentCreator
    VALUES(content_creator_seq.NEXTVAL, 
            user_seq.CURRVAL, 
            'dojacat', 
            '400 Juicy Lane', 
            'Los Angeles', 
            'CA', 
            50005, 
            'CA', 
            'United States', 
            '8995554444', 
            3);
COMMIT;
--3. Insert Credit Card info for user
INSERT INTO CreditCard
    VALUES(card_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'Visa',
            '4444111122223333',
            to_date('2021/09/20', 'yyyy/mm/dd'),
            893,
            '400 Juicy Lane', 
            'Los Angeles', 
            'CA', 
            50005);  
COMMIT;  

--4. Create a Video
INSERT INTO Video -- DEFAULT TO RECENT VALUES
    VALUES(video_seq.NEXTVAL,
            content_creator_seq.CURRVAL,
            'MOO',
            'Doja Cat is not a cat, she is a cow',
            to_date('2016/07/09','yyyy/mm/dd'),
            192,
            900,
            300921,
            90883,
            192730);
COMMIT;

    
    
    
    
--Comments Linking Table: Four comments
---------------------------------------
INSERT INTO Comments
    VALUES(comment_seq.NEXTVAL,
            1000001,
            1000000,
            to_date('2020/01/01 8:30:30','yyyy/mm/dd hh24:mi:ss'),
            'Amazing Video! Really aspiring and a great way to start 2021');
INSERT INTO Comments
    VALUES(comment_seq.NEXTVAL,
            1000001,
            1000003,
            to_date('2019/08/02 12:30:20','yyyy/mm/dd hh24:mi:ss'),
            'I too find myself having more in common with a cow, great video!');
INSERT INTO Comments
    VALUES(comment_seq.NEXTVAL,
            1000002,
            1000001,
            to_date('2018/07/24 18:22:12','yyyy/mm/dd hh24:mi:ss'),
            'Very inspiring, you showed her NicKi!');
INSERT INTO Comments
    VALUES(comment_seq.NEXTVAL,
            1000000,
            1000004,
            to_date('2020/10/06 16:07:12','yyyy/mm/dd hh24:mi:ss'),
            'I bet there is a tik tok dance to this already!');
COMMIT;




--Topics
---------------------------------------
INSERT INTO Topic VALUES (topic_seq.NEXTVAL, 'Hip Hop', '"Rap Music" that was developed in NYC');
INSERT INTO Topic VALUES (topic_seq.NEXTVAL, 'Pop', 'Popular with many styles');
INSERT INTO Topic VALUES (topic_seq.NEXTVAL, 'RNB', 'Rhythm and Blues');
INSERT INTO Topic VALUES (topic_seq.NEXTVAL, 'Instrumental', 'Music with no words');
COMMIT;
    
    
    

--User Topic Linking Table
---------------------------------------
INSERT INTO USER_TOPIC_SUBSCR VALUES(user_topic_seq.NEXTVAL, 1000000, 1000002);
INSERT INTO USER_TOPIC_SUBSCR VALUES(user_topic_seq.NEXTVAL, 1000003, 1000000);
INSERT INTO USER_TOPIC_SUBSCR VALUES(user_topic_seq.NEXTVAL, 1000005, 1000001);
INSERT INTO USER_TOPIC_SUBSCR VALUES(user_topic_seq.NEXTVAL, 1000001, 1000000);
COMMIT;



------------------------------------------------------
--INDEX STATEMENTS
------------------------------------------------------
--Creating indexes on all foreign keys for tables. 


CREATE INDEX ContentCreator_ix
    ON ContentCreator(user_id);

CREATE INDEX CreditCard_ix
    ON CreditCard(ContentCreator_id);

CREATE INDEX Video_ix
    ON Video(ContentCreator_id);

CREATE INDEX Comment_video_ix
    ON Comments(video_id);
    
CREATE INDEX Comment_user_ix
    ON Comments(user_id);

CREATE INDEX Video_topic_linking_video_ix
    ON Video_topic_linking(video_id);
    
CREATE INDEX Video_topic_linking_topic_ix
    ON Video_topic_linking(topic_id);

CREATE INDEX User_topic_subscr_video_ix
    ON User_topic_subscr(user_id);
    
CREATE INDEX User_topic_linking_topic_ix
    ON User_topic_subscr(topic_id);
    
    
    
------------------------------------------------------
--SANITY CHECK
------------------------------------------------------
--Making sure all tables populated with no errors. 
SELECT * FROM BROWSER_USER;
SELECT * FROM CONTENTCREATOR;
SELECT * FROM VIDEO;
SELECT * FROM CREDITCARD;
SELECT * FROM USER_TOPIC_SUBSCR;
SELECT * FROM COMMENTS;
SELECT * FROM VIDEO_TOPIC_LINKING; --No videos were linked to topics yet, no results
SELECT * FROM TOPIC;