--      Exam 1 Prep: DDL Statements
--      Students Database Example


------------------------------------------------------------------------
------------------------------------------------------------------------
--      Recall the SIX STEPS:
            -- 1. Identify data elements
            -- 2. Subdivide each element into its smallest useful component
            -- 3. Identify the tables and assign columns
            -- 4. Identify primary and foreign keys
            -- 5. Review whether the data structure is normalized
            -- 6. Identify the indexes
------------------------------------------------------------------------
------------------------------------------------------------------------
-- TOPIC 1: CREATE AND DROP TABLES
DROP TABLE ActiveRegistration;
DROP TABLE CompletedRegistration;
DROP TABLE Student;
DROP TABLE Course;
DROP TABLE Demo;
DROP SEQUENCE demo_seq;

CREATE TABLE Student
(
    uteid       VARCHAR2(10)     PRIMARY KEY    NOT NULL,
    fullname    VARCHAR2(25)     NOT NULL,
    address     VARCHAR2(45)     NOT NULL,
    dob         DATE

);

CREATE TABLE Course
(
    courseid    VARCHAR2(6)      PRIMARY KEY     NOT NULL,
    coursename  VARCHAR2(20)     NOT NULL,
    mandatory   VARCHAR2(1)      DEFAULT 'N'

);

CREATE TABLE CompletedRegistration
(
    c_regid    NUMBER           NOT NULL        PRIMARY KEY,
    uteid      VARCHAR2(10)     NOT NULL        REFERENCES Student(uteid),
    courseid   VARCHAR2(6)      NOT NULL        REFERENCES Course(courseid),
    grade      VARCHAR2(2)      NOT NULL        CHECK(Grade = 'A' OR Grade = 'B' OR Grade = 'C' OR Grade = 'D' OR Grade ='F')
    
);

CREATE TABLE ActiveRegistration
(
    a_regid   NUMBER            NOT NULL        PRIMARY KEY,
    uteid     VARCHAR2(10)      NOT NULL        REFERENCES Student(uteid),
    courseid  VARCHAR2(6)       NOT NULL        REFERENCES Course(courseid)
);

------------------------------------------------------------------------
------------------------------------------------------------------------
--TOPIC 2: ALTER STATEMENTS

--ADD
ALTER TABLE CompletedRegistration
    ADD (
        date_completed      NUMBER,
        demo_column         VARCHAR2(1)
        );
    
--MODIFY
ALTER TABLE CompletedRegistration
    MODIFY date_completed   DATE        NOT NULL;
    
--DROP
ALTER TABLE CompletedRegistration
    DROP COLUMN demo_column;
    
------------------------------------------------------------------------
------------------------------------------------------------------------
--TOPIC 3: CONSTRAINTS
        --Create a demo table for this topic
CREATE TABLE Demos
(
    demoid      NUMBER, 
    descrip     VARCHAR2(50),
    positive_number     NUMBER(1)
);

--3A. COLUMN LEVEL CONSTRAINTS
ALTER TABLE Demos
    MODIFY (
            demoid     CONSTRAINT demo_pk NOT NULL,
            descrip    CONSTRAINT demo_desc NOT NULL,
            positive_number     CHECK(positive_number >= 0) --Check Constraint
    );

--3B. TABLE LEVEL CONSTRAINTS
ALTER TABLE Demos
    ADD CONSTRAINT pk_two PRIMARY KEY(demoid, descrip);
    
--3C. ENABLE AND DISABLE CONSTRAINTS
ALTER TABLE Demos
    ADD CONSTRAINT example  CHECK(demoid > 1) DISABLE;
ALTER TABLE Demos
    ENABLE NOVALIDATE CONSTRAINT example;
    
    
------------------------------------------------------------------------
------------------------------------------------------------------------
--TOPIC 4: RENAME, TRUNCATE, AND DROP
RENAME Demos TO Demo;
        --Renames a table
TRUNCATE TABLE Demo;
        --Removes all data inside table
--DROP TABLE was performed above

------------------------------------------------------------------------
------------------------------------------------------------------------
--TOPIC 5: INDEXES AND SEQUENCES
CREATE INDEX student_dob_ix
    ON Student(dob DESC);
        --Use indexes for primary/foreign keys, not columns updated regularly

CREATE SEQUENCE demo_seq
    START WITH 1000
    INCREMENT BY 100
    MAXVALUE 10000000
    MINVALUE 1000
    NOCYCLE
    CACHE 30
    ORDER;
    
INSERT INTO Demo
    VALUES(demo_seq.NEXTVAL, 'Description', 1);


INSERT INTO Demo
    VALUES(demo_seq.NEXTVAL, 'Second Description', 3);

SELECT * FROM Demo;

