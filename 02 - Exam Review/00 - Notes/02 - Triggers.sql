--Create trigger to enforce data consistency
CREATE OR REPLACE TRIGGER vendors_before_update_state
BEFORE INSERT OR UPDATE OF vendor_state
ON vendors
FOR EACH ROW
WHEN (NEW.vendor_state != UPPER(NEW.vendor_state))
BEGIN
 :NEW.vendor_state := UPPER(:NEW.vendor_state);
END;
/
--------------------------------
--------------------------------
--an update statement that fires the trigger
UPDATE vendors
SET vendor_state = 'tx'
WHERE vendor_id = 73;

--A SELECT statement that shows the new row
SELECT vendor_name, vendor_state
FROM vendors
WHERE vendor_id = 1;
 
-- Drop statement
drop trigger vendors_before_update_state;

--------------------------------
--------------------------------

--Create trigger to enforce data consistency for phone number
CREATE OR REPLACE TRIGGER vendor_before_insert_phone
BEFORE INSERT OR UPDATE OF vendor_phone
ON vendors
FOR EACH ROW
WHEN (length(NEW.vendor_phone) != 14)
BEGIN
   RAISE_APPLICATION_ERROR(-20001,
   'Insert phone number in the format (999) 999-9999.');
END;
/
--an update statement that fires the trigger
UPDATE vendors
SET vendor_phone = '(832) 528-0847'
WHERE vendor_id = 1;

--A SELECT statement that shows the new row
SELECT vendor_name, vendor_phone
FROM vendors
WHERE vendor_id = 1;
 
-- Drop statement
drop trigger vendor_before_insert_phone;
--------------------------------
--------------------------------
