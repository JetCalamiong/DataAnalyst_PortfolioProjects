SELECT *
FROM cafe_sales_1

-- remove the header 
DELETE
FROM cafe_sales_1
WHERE transaction_id = 'Transaction ID'

-- check the values of each column
SELECT DISTINCT transaction_date
FROM cafe_sales_1
ORDER BY 1;
-- every column has UNKNOWN, ERROR, [null] values except transaction_id
-- the distinct transaction_id returned 10000 rows, which means there is no duplicates
-- 1. Removing duplicates
-- skip since there are no duplicates

-- 2. Standardizing the data
-- through using the DISTINCT code, I found that there is no need to use the TRIM functions
-- goal: change data type
-- to change the data type of certain columns, we need to change unknown and errors to NULL 
UPDATE cafe_sales_1
SET
    item = CASE WHEN item IN ('', 'ERROR', 'UNKNOWN') THEN NULL ELSE (item) END,
    quantity = CASE WHEN quantity IN ('', 'ERROR', 'UNKNOWN') THEN NULL ELSE (quantity) END,
    price_per_unit = CASE WHEN price_per_unit IN ('', 'ERROR', 'UNKNOWN') THEN NULL ELSE (price_per_unit) END,
    total_spent = CASE WHEN total_spent IN ('', 'ERROR', 'UNKNOWN') THEN NULL ELSE (total_spent) END,
    payment_method = CASE WHEN payment_method IN ('', 'ERROR', 'UNKNOWN') THEN NULL ELSE (payment_method) END,
    location = CASE WHEN location IN ('', 'ERROR', 'UNKNOWN') THEN NULL ELSE (location) END,
    transaction_date = CASE WHEN transaction_date IN ('', 'ERROR', 'UNKNOWN') THEN NULL ELSE (transaction_date) END

ALTER TABLE cafe_sales_1
    ALTER COLUMN quantity         TYPE INT           USING quantity::INT,
    ALTER COLUMN price_per_unit   TYPE NUMERIC(6,2)  USING price_per_unit::NUMERIC,
    ALTER COLUMN total_spent      TYPE NUMERIC(8,2)  USING total_spent::NUMERIC,
    ALTER COLUMN transaction_date TYPE DATE          USING transaction_date::DATE;

-- 3. Handling blank values and null values

-- goal: populate the values in item, quantity, price_per_unit, total_spent 
WITH item_corresponding_with_ppu AS (
	SELECT DISTINCT item, price_per_unit
	FROM cafe_sales_1
	WHERE item IS NOT NULL AND price_per_unit IS NOT NULL
)

-- SELECT *
-- FROM cafe_sales_1 t1
-- JOIN item_corresponding_with_ppu t2
-- ON t1.price_per_unit = t2.price_per_unit
-- WHERE t1.item IS NULL

-- SELECT *
-- FROM cafe_sales_1 t1
-- JOIN item_corresponding_with_ppu t2
-- ON t1.item = t2.item
-- WHERE t1.price_per_unit IS NULL

-- replacing the null values of the item column using the price_per_unit column
UPDATE cafe_sales_1 t1
SET item = t2.item
FROM item_corresponding_with_ppu t2
WHERE t1.price_per_unit = t2.price_per_unit
  AND t1.item IS NULL;

-- replacing the null values of the price_per_unit column using the item column
UPDATE cafe_sales_1 t1
SET price_per_unit = t2.price_per_unit
FROM item_corresponding_with_ppu t2
WHERE t1.item = t2.item
  AND t1.price_per_unit IS NULL;

-- replacing the null values of the total_spent column
UPDATE cafe_sales_1
SET total_spent = quantity * price_per_unit
WHERE total_spent IS NULL AND quantity IS NOT NULL AND price_per_unit IS NOT NULL;

-- replacing the null values of the quantity column
UPDATE cafe_sales_1
SET quantity = total_spent/price_per_unit
WHERE quantity IS NULL AND total_spent IS NOT NULL AND price_per_unit IS NOT NULL;

-- replacing the null values of the price_per_unit column
UPDATE cafe_sales_1
SET price_per_unit = total_spent/quantity
WHERE price_per_unit IS NULL AND total_spent IS NOT NULL AND quantity IS NOT NULL;

-- 4. Remove the rows that are not going to be useful in data analysis
DELETE
FROM cafe_sales_1
WHERE quantity IS NULL OR price_per_unit IS NULL OR total_spent IS NULL
