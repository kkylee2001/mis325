--1.
SELECT * FROM Vendors;

--2.
SELECT vendor_id, 
    vendor_name, 
    vendor_address1 || ' ' || vendor_address2 AS "Address", 
    vendor_city, 
    vendor_state, 
    vendor_zip_code
FROM Vendors
WHERE vendor_state IN ('NJ' , 'NY')
ORDER BY vendor_state;

--3.
SELECT vendor_id, vendor_name, 
        vendor_address1 || ' ' || vendor_address2 || ' ' || vendor_city || ' ' || vendor_state || ' ' || vendor_zip_code AS VendorAddress 
FROM Vendors
WHERE vendor_state = 'NY' 
ORDER BY vendor_state;

--4.
SELECT vendor_id, 
    invoice_number, 
    invoice_total, 
    payment_total, 
    invoice_total - payment_total AS "Amount Owed"
FROM Invoices
WHERE invoice_total - payment_total = 0;

--5.
SELECT invoice_id, 
    invoice_date, 
    ROUND(SYSDATE - invoice_date) AS "Age"
FROM INVOICES
ORDER BY 3;

--6.
SELECT vendor_id,
    SUBSTR(vendor_contact_first_name, 1, 1)|| SUBSTR(vendor_contact_last_name, 1, 1) 
    AS "Initials" 
FROM Vendors;

--7.
SELECT 'Invoice: #'
    || invoice_number
    || ' dated '
    || invoice_date
    || ' for $'
    || round(payment_total, 2)
    AS "Invoice"
FROM Invoices;

--8.
SELECT invoice_id, 
    payment_total, 
    MOD(payment_total, 10) as "Remainder"
FROM Invoices;

--9.
SELECT customer_id,
    customer_last_name,
    SUBSTR(customer_first_name, 1, 1) AS "First Initial",
    SUBSTR(customer_phone, 1, 3) 
        ||'-'|| 
        SUBSTR(customer_phone, 4, 3) 
        || '-' || 
        SUBSTR(customer_phone, 7, 4) 
    AS "Phone Number"
FROM Customers_OM;
