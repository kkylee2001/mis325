-------------------------------------------------------------------------------------------
------CODE FOR DROPPING SEQUENCES----------
-------------------------------------------------------------------------------------------
DROP SEQUENCE lender_seq;
DROP SEQUENCE borrower_seq;
DROP SEQUENCE programs_seq;

-------------------------------------------------------------------------------------------
------CODE FOR CREATING SEQUENCES----------
-------------------------------------------------------------------------------------------
CREATE SEQUENCE lender_seq
    START WITH 1000
    INCREMENT BY 1
    ORDER;

CREATE SEQUENCE borrower_seq
    START WITH 1000
    INCREMENT BY 1
    ORDER;

CREATE SEQUENCE programs_seq
    START WITH 1
    INCREMENT BY 1
    ORDER;

-------------------------------------------------------------------------------------------
------CODE FOR DROPPING TABLES----------
-------------------------------------------------------------------------------------------
DROP TABLE finance_details;
DROP TABLE transactions;
DROP TABLE programs;
DROP TABLE locations;
DROP TABLE borrower;
DROP TABLE lender;

-------------------------------------------------------------------------------------------
------CODE FOR CREATING TABLES----------
-------------------------------------------------------------------------------------------
CREATE TABLE lender
(
    lender_id               NUMBER           DEFAULT(lender_seq.NEXTVAL)     PRIMARY KEY,
    lender_name             VARCHAR(100),
    lender_type             VARCHAR(100),
    lender_type_category    VARCHAR(100),
    CDFI_type               VARCHAR(20),
    MDI_type                VARCHAR(20),
    count_rows              NUMBER
);


CREATE TABLE borrower
(
    borrower_id             NUMBER       DEFAULT(borrower_seq.NEXTVAL)                      PRIMARY KEY,
    revenue                 NUMBER,
    full_time_employees     NUMBER(10),
    year_incorporated       NUMBER(4),
    NAICS_code              NUMBER(6),
    LMI_type                VARCHAR(7), 
    metro_type              VARCHAR(9)            
);


CREATE TABLE locations
(
    zip_code                NUMBER(5)      PRIMARY KEY,
    state_id                VARCHAR(4),
    state_name              VARCHAR(30)
);


CREATE TABLE programs
(
    program_id              NUMBER         DEFAULT(programs_seq.NEXTVAL)        PRIMARY KEY,
    program_name            VARCHAR(75),
    program_type            VARCHAR(20),
    count_rows              NUMBER
);


CREATE TABLE transactions
(
    transaction_unique_id   VARCHAR(17)   PRIMARY KEY,
    program_id              NUMBER        REFERENCES programs(program_id),
    lender_id               NUMBER        REFERENCES lender(lender_id),
    borrower_id             NUMBER        REFERENCES borrower(borrower_id),
    year_reported           NUMBER(4),
    disbursement_date       DATE,
    program_zip_code        NUMBER(5)     REFERENCES locations(zip_code),
    loan_investment_amount  NUMBER,
    SSBCI_original_funds    NUMBER ,
    trans_type              VARCHAR(10),
    VC_cat                  VARCHAR(25),
    jobs_created            NUMBER(4),
    jobs_retained           NUMBER(4) 
);



CREATE TABLE finance_details
(
    finance_unique_id                    VARCHAR(17)   PRIMARY KEY        REFERENCES transactions(transaction_unique_id),
    nonprivate_amount                    NUMBER        DEFAULT(0),
    concurrent_private_financing         NUMBER        DEFAULT(0),
    borrower_insurance_premium           NUMBER        DEFAULT(0),
    lender_insurance_premium             NUMBER        DEFAULT(0),
    guaranteed_amount                    NUMBER        DEFAULT(0),
    collateral_support                   NUMBER        DEFAULT(0),
    SSBCI_recycled_funds                 NUMBER        DEFAULT(0),
    subsequent_private_financing         NUMBER        DEFAULT(0)
);

-------------------------------------------------------------------------------------------
------CODE FOR SEEDING TABLES WITH DATA----------
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
------CODE FOR INSERTING DATA INTO LENDER TABLE----------
-------------------------------------------------------------------------------------------
INSERT INTO lender (lender_name, lender_type, lender_type_category, CDFI_type, MDI_type, count_rows)
SELECT lender_name, lender_type, lender_type_category, CDFI_type,  MDI_type, COUNT(*)
FROM final
WHERE revenue >0 AND year_incorporated > 2008
GROUP BY lender_name, lender_type, lender_type_category, CDFI_type, MDI_type;

-------------------------------------------------------------------------------------------
------CODE FOR INSERTING DATA INTO BORROWER TABLE----------
-------------------------------------------------------------------------------------------
INSERT INTO borrower (revenue, full_time_employees, year_incorporated, NAICS_code, LMI_type, metro_type)
SELECT revenue, full_time_employees, year_incorporated, NAICS_code, LMI_type, metro_type
FROM final
WHERE revenue >0 AND year_incorporated > 2008;

-------------------------------------------------------------------------------------------
------CODE FOR INSERTING DATA INTO LOCATIONS TABLE----------
-------------------------------------------------------------------------------------------
INSERT INTO locations (zip_code, state_id, state_name)
SELECT DISTINCT zip_code, state_id, state_name
FROM final
WHERE zip_code IS NOT NULL AND revenue >0 AND year_incorporated > 2008;

-------------------------------------------------------------------------------------------
------CODE FOR INSERTING DATA INTO PROGRAMS TABLE----------
-------------------------------------------------------------------------------------------
INSERT INTO programs (program_name, program_type, count_rows)
SELECT program_name, program_type, COUNT(*)
FROM final
WHERE program_name IS NOT NULL AND revenue>0 AND year_incorporated > 2008
GROUP BY program_name, program_type
ORDER BY program_name;

-------------------------------------------------------------------------------------------
------CODE FOR INSERTING DATA INTO TRANSACTIONS TABLE----------
-------------------------------------------------------------------------------------------
INSERT INTO transactions (transaction_unique_id, year_reported, disbursement_date, program_zip_code, loan_investment_amount,
        SSBCI_original_funds, trans_type, VC_cat, jobs_created, jobs_retained)
SELECT DISTINCT unique_id, year_reported, disbursement_date, zip_code, loan_investment_amount,
        SSBCI_original_funds, trans_type, VC_cat, jobs_created, jobs_retained
FROM final
WHERE unique_id IS NOT NULL AND revenue >0 AND year_incorporated > 2008;

-------------------------------------------------------------------------------------------
------CODE FOR UPDATING TRANSACTION TABLE WITH PROGRAM_ID, LENDER_ID, AND BORROWER_ID----------
-------------------------------------------------------------------------------------------
UPDATE transactions
SET program_id = (SELECT program_id FROM (SELECT unique_id, program_id
                                            FROM final f JOIN programs p ON
                                            f.program_name = p.program_name) table2
                                    WHERE transactions.transaction_unique_id = table2.unique_id);
                                    
UPDATE transactions
SET lender_id = (SELECT lender_id FROM (SELECT unique_id, lender_id
                                            FROM final f JOIN lender p ON
                                            f.lender_name = p.lender_name) table2
                                    WHERE transactions.transaction_unique_id = table2.unique_id);

UPDATE transactions
SET borrower_id = (SELECT borrower_id FROM (SELECT unique_id, borrower_id
                                            FROM final f JOIN borrower b ON
                                            f.revenue = b.revenue 
                                            AND f.NAICS_Code = b.NAICS_Code 
                                            AND f.year_incorporated = b.year_incorporated
                                            AND f.full_time_employees = b.full_time_employees
                                            AND f.LMI_type = b.LMI_type
                                            AND f.metro_type = b.metro_type) table2
                                    WHERE transactions.transaction_unique_id = table2.unique_id);                               

-------------------------------------------------------------------------------------------
------CODE FOR INSERTING DATA INTO FINANCE DETAILS TABLE----------
-------------------------------------------------------------------------------------------
INSERT INTO finance_details (finance_unique_id, nonprivate_amount, concurrent_private_financing, borrower_insurance_premium,
            lender_insurance_premium, guaranteed_amount, collateral_support, SSBCI_recycled_funds,
            subsequent_private_financing)
SELECT unique_id, nonprivate_amount, concurrent_private_financing, borrower_insurance_premium,
            lender_insurance_premium, guaranteed_amount, collateral_support, SSBCI_recycled_funds,
            subsequent_private_financing
FROM final
WHERE unique_id IS NOT NULL AND revenue>0 AND year_incorporated > 2008;



-------------------------------------------------------------------------------------------
------TROUBLESHOOTING CODE-------
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
------CODE FOR SELECTING DUPLICATES FROM THE IMPORTED DATA----------
-------------------------------------------------------------------------------------------
SELECT final.*
FROM final JOIN (SELECT unique_id, COUNT(*)
                    FROM final
                    GROUP BY unique_id
                    HAVING COUNT(*) >1) b
ON final.unique_id = b.unique_id;

SELECT COUNT(*) FROM Final;

-------------------------------------------------------------------------------------------
------CODE FOR DELETING DUPLICATES FROM THE IMPORTED DATA----------
-------------------------------------------------------------------------------------------
DELETE FROM Final
WHERE unique_id IN (
                    SELECT unique_id
                    FROM final
                    GROUP BY unique_id
                    HAVING COUNT(*) >1);

-------------------------------------------------------------------------------------------
------CODE FOR COMMITING DELETE DUPLICATES FROM THE IMPORTED DATA----------
-------------------------------------------------------------------------------------------
COMMIT;

-------------------------------------------------------------------------------------------
------CODE FOR SELECTING DISTINCT ZIP CODES FROM THE SEEDED DATA----------
-------------------------------------------------------------------------------------------
SELECT DISTINCT zip_code, state_id, state_name
FROM final
WHERE zip_code IS NOT NULL AND revenue >0 AND year_incorporated > 2008;

-------------------------------------------------------------------------------------------
------CODE FOR SELECTING DUPLICATE ZIP CODES FROM THE SEEDED DATA----------
-------------------------------------------------------------------------------------------
SELECT zip_code, COUNT(*)
                    FROM (SELECT DISTINCT zip_code, state_id, state_name
                            FROM final
                            WHERE zip_code IS NOT NULL AND revenue >0 AND year_incorporated > 2008)
                    GROUP BY zip_code
                    HAVING COUNT(*) >1;

-------------------------------------------------------------------------------------------
------CODE FOR SELECTING DUPLICATE ZIP CODES FROM THE IMPORTED DATA----------
-------------------------------------------------------------------------------------------
SELECT final.*
FROM final JOIN (SELECT zip_code, COUNT(*)
                    FROM (SELECT DISTINCT zip_code, state_id, state_name
                            FROM final
                            WHERE zip_code IS NOT NULL AND revenue >0 AND year_incorporated > 2008)
                    GROUP BY zip_code
                    HAVING COUNT(*) >1) b
ON final.zip_code = b.zip_code;

-------------------------------------------------------------------------------------------
------CODE FOR DELETING DUPLICATE ZIP CODES FROM THE SEEDED DATA----------
-------------------------------------------------------------------------------------------
DELETE FROM final WHERE zip_code IN(SELECT zip_code
                                    FROM (SELECT DISTINCT zip_code, state_id, state_name
                                            FROM final
                                            WHERE zip_code IS NOT NULL AND revenue >0 AND year_incorporated > 2008)
                                    GROUP BY zip_code
                                    HAVING COUNT(*) >1);
                                    
-------------------------------------------------------------------------------------------
------CODE FOR SELECTING DISTINCT ZIP CODES FROM THE SEEDED DATA----------    
-------------------------------------------------------------------------------------------
COMMIT;

-------------------------------------------------------------------------------------------
------CODE FOR DELETING NULL PROGRAM NAMES FROM THE IMPORTED DATA----------
-------------------------------------------------------------------------------------------
DELETE FROM final WHERE program_name IS NULL;
COMMIT;

-------------------------------------------------------------------------------------------
------CODE FOR SELECTING AND DELETING DUPLICATE LENDER NAMES FROM THE SEEDED DATA----------
-------------------------------------------------------------------------------------------
SELECT lender_name, COUNT(*)
FROM lender
GROUP BY Lender_name
HAVING COUNT(*)>1;

DELETE FROM final
WHERE lender_name IN (
                    SELECT lender_name
                    FROM lender
                    GROUP BY Lender_name
                    HAVING COUNT(*)>1);

-------------------------------------------------------------------------------------------
------CODE FOR SELECTING AND DELETING DUPLICATE BORROWER DATA FROM THE SEEDED DATA----------
-------------------------------------------------------------------------------------------
SELECT * FROM borrower;

SELECT NAICS_Code || revenue || year_incorporated || full_time_employees || lmi_type || metro_type AS borrower_identity, COUNT(*)
FROM final
WHERE revenue>0 AND year_incorporated > 2008
GROUP BY NAICS_Code || revenue || year_incorporated || full_time_employees || lmi_type || metro_type
HAVING COUNT(*)>1;


DELETE FROM final
WHERE NAICS_Code || revenue || year_incorporated || full_time_employees || lmi_type || metro_type IN (
                    SELECT NAICS_Code || revenue || year_incorporated || full_time_employees || lmi_type || metro_type
                    FROM final
                    GROUP BY NAICS_Code || revenue || year_incorporated || full_time_employees || lmi_type || metro_type
                    HAVING COUNT(*)>1);

COMMIT;
-------------------------------------------------------------------------------------------