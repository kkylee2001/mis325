--Question 1: In the past five years, which programs have created the most jobs on average? How do they stack up?
--Is jobs creation of a program related to the average loan investment amount of the program?

--Insight 1: Loan participation and venture capital programs have the highest rates of job creation on average, while CAP (capital access) programs
--have the lowest job creation at just 1 job on average and the lowest job retention at just 4 jobs.
--We also see that a program's job creation is closely tied with the loan investment amount. The higher the loan/capital
--invested, the higher the number of jobs created on average. An underlying factor may be the stage of a company. You would expect
--that the programs that spur origination of larger loans would be given to high growth or mature phase business that requires
--more human capital to grow the company.

SELECT RANK() OVER (ORDER BY TRUNC(SUM(TN.loan_investment_amount)/COUNT(TN.transaction_unique_id)) DESC) AS rank, 
    PG.program_type, TRUNC(SUM(TN.loan_investment_amount)/COUNT(TN.transaction_unique_id)) AS avg_investment_amount_per_loan,
    COUNT(TN.transaction_unique_id) AS number_of_transactions, TRUNC(SUM(TN.loan_investment_amount)) AS total_investment_amount, 
    SUM(TN.jobs_created) AS jobs_created
FROM transactions TN 
JOIN (SELECT*
    FROM borrower 
    WHERE year_incorporated >= '2015') BO
    ON TN.borrower_id = BO.borrower_id
JOIN programs PG ON PG.program_id = TN.program_id
GROUP BY PG.program_type
ORDER BY TRUNC(SUM(TN.loan_investment_amount)/COUNT(TN.transaction_unique_id)) DESC;

--Question 2: How well has the SSBCI targeted young, small-sized business? The term 'young' can be defined as less than 5 years
--old, and the term 'small-sized' can be defined as 10 or fewer FTEs(Full-Time Employees).

--Insight 2: If we divide the result of query 1 by query 2, we get the percent of young, small-sized businesses that have received
--SSBCI loans. We can determine how well the SSBCI has helped the smallest of small businesses. From the results, we see that 
--5357 businesses are in the young, small-sized category out of 7504 businesses. This goes to show that the SSBCI program
--has targeted young, small-sized businesses very well, with over 71% of recipients falling under this category. This shows
--that the program has done its job quite well.

--Query 1 to get count of businesses with 10 or fewer FTEs and business that are less than 5 years old. 
SELECT count(b.borrower_id) AS young_small_businesses
FROM borrower b INNER JOIN transactions tr
ON b.borrower_id = tr.borrower_id
WHERE full_time_employees <= 10
AND TO_CHAR(disbursement_date, 'YYYY') - TO_NUMBER(year_incorporated) < 5;

--Query 2 to get total count of businesses.
SELECT count(*)
FROM transactions;

--Question 3: Excluding any VC type investment, were community development financial institutions (CDFI) impactful in LMI census 
--tracts (regions) as opposed to non CDFI lenders and financial institutions?

--Insight 3: Clearly we see significant impact of CDFI lenders helping small businesses in their community meet their capital needs.
--We see in the results that 2302 lenders in LMI regions are CDFI and 818 are NON-CDFI in LMI regions. This implies that 
--in low income areas, loans are being given by CDFIs at a rate of 2.81x over NON-CDFI lenders.

--Query 1 for loan transactions in LMI areas who are served by CDFI lenders.
SELECT count(l.lender_id) AS CDFI_Lenders
FROM lender l INNER JOIN transactions tr
ON l.lender_id = tr.lender_id
INNER JOIN borrower b
ON b.borrower_id = tr.borrower_id
WHERE LMI_type = 'LMI'
AND trans_type = 'Loan'
AND CDFI_type = 'CDFI';

--Query 2 for loan transactions in LMI areas who are served by non-CDFI lenders.
SELECT count(l.lender_id) AS non_CDFI_Lenders
FROM lender l INNER JOIN transactions tr
ON l.lender_id = tr.lender_id
INNER JOIN borrower b
ON b.borrower_id = tr.borrower_id
WHERE LMI_type = 'LMI'
AND trans_type = 'Loan'
AND CDFI_type = 'Non-CDFI';


--Question 4: Which programs have the highest leverage ratios. Leverage ratio defined as the total loan_investment_amount
--over the original SSBCI funds provided by the state/government.

--Insight 4: Clearly we can see a higher leverage ratio of funds with CAP programs which in Inisght 1 we found had
--the lowest loan amounts on average. This indiciates that for small sized loans, private financing is contributing 
--more significantly than in all other programs. CAP programs appear to be the best tool to involve the private sector
--financial institutions.

SELECT program_type, ROUND(AVG(loan_investment_amount/SSBCI_original_funds),2) AS Leverage_Ratio
FROM programs pr INNER JOIN transactions tr
ON pr.program_id = tr.program_id
WHERE SSBCI_original_funds != 0
GROUP BY program_type
ORDER BY Leverage_Ratio DESC;

--Question 5: Is there a relationship between the age of a company and the loan investment amount acquired?

--Insight 5: The results tell us that start-up companies (age = 0) are acquiring more capital and that companies in between the 
--oldest and newest acquire lesser capital (loan amounts), but that older companies are acquiring the least amount. It appears
--that as these small businesses mature, the need for capital goes down, which would makes sense in a typical business cycle.

SELECT ((TO_CHAR(disbursement_date, 'YYYY')) - TO_NUMBER(year_incorporated)) AS company_age, ROUND(AVG(loan_investment_amount)) AS total_loan_amount
FROM borrower b INNER JOIN transactions tr
ON b.borrower_id = tr.borrower_id
GROUP BY ((TO_CHAR(disbursement_date, 'YYYY')) - TO_NUMBER(year_incorporated))
ORDER BY company_age DESC;