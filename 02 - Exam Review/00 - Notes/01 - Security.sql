



--Create a student role named students with a default password of password123
CREATE ROLE student IDENTIFIED BY password123;


--Use the grant statement to provide privleges to the students role
--for Students and Completed_registration tables
GRANT SELECT, INSERT, UPDATE, DELETE
ON Students
TO student;

GRANT SELECT, INSERT, UPDATE, DELETE
ON Completed_registration
TO student;


--Create a user named fallonj, then in a separate statement grant the students
--role to fallonj
CREATE USER fallonj IDENTIFIED BY password123;
GRANT student TO fallonj;


--Remove a user assigned to a role, removes the roles from fallonj
REVOKE student FROM fallonj;



--Create role faculty identified by password_123!
--grant select, update to faculty on course
--grant insert, select, update to faculty on Active Registration
CREATE ROLE faculty IDENTIFIED BY password_123!;

GRANT SELECT, UPDATE on Course to faculty;
GRANT insert, select, update on Active_registration to faculty;

CREATE USER tej_anand IDENTIFIED BY password_123!;
GRANT faculty to tej_anand;

REVOKE faculty from tej_anand;


