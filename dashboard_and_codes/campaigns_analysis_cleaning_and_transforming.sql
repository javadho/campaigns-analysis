--Check columns data types
SELECT
	TABLE_NAME,
	COLUMN_NAME,
	DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS;


--Change data types for transaction_data table
ALTER TABLE transaction_data
ALTER COLUMN basket_id BIGINT

ALTER TABLE transaction_data
ALTER COLUMN day INT

	--Check why there are large numbers for quantity column of some transactions
	SELECT *
	FROM transaction_data AS t
	LEFT JOIN product AS p
	ON p.product_id = t.product_id
	ORDER BY t.quantity DESC
ALTER TABLE transaction_data
ALTER COLUMN quantity INT

	--Make some value in sales_value column to 0.001 as value 0 not make sense
	UPDATE transaction_data
	SET sales_value = 0.001
	WHERE sales_value LIKE '%[^0-9.]%';
ALTER TABLE transaction_data
ALTER COLUMN sales_value DECIMAL(6, 2)--The maximum length was found by a simple query &
									  --decimal was used becasue we need precision
	
	--Make some value in retail_disc column to 0
	UPDATE transaction_data
	SET retail_disc = 0.001
	WHERE retail_disc LIKE '%[^0-9.-]%';
ALTER TABLE transaction_data
ALTER COLUMN retail_disc DECIMAL(7, 2)

ALTER TABLE transaction_data
ALTER COLUMN week_no INT

ALTER TABLE transaction_data
ALTER COLUMN coupon_disc DECIMAL(6, 2)

ALTER TABLE transaction_data
ALTER COLUMN coupon_match_disc DECIMAL(5, 2)

ALTER TABLE transaction_data
ALTER COLUMN coupon_match_disc DECIMAL(5, 2)



--Change data types for hh_demographic table
ALTER TABLE hh_demographic
ALTER COLUMN household_key INT


--Change data types for campaign_desc table
ALTER TABLE campaign_desc
ALTER COLUMN campaign INT



--Check missing values
SELECT 
	COUNT(CASE WHEN household_key IS NULL THEN 1 END) AS houshold_key_NULL,
	COUNT(CASE WHEN basket_id IS NULL THEN 1 END) AS basket_id_NULL,
	COUNT(CASE WHEN day IS NULL THEN 1 END) AS day_NULL,
	COUNT(CASE WHEN product_id IS NULL THEN 1 END) AS product_id_NULL,
	COUNT(CASE WHEN quantity IS NULL THEN 1 END) AS quantity_NULL,
	COUNT(CASE WHEN sales_value IS NULL THEN 1 END) AS sales_value_NULL,
	COUNT(CASE WHEN store_id IS NULL THEN 1 END) AS store_id_NULL,
	COUNT(CASE WHEN retail_disc IS NULL THEN 1 END) AS retail_disc_NULL,
	COUNT(CASE WHEN week_no IS NULL THEN 1 END) AS week_no_NULL,
	COUNT(CASE WHEN coupon_disc IS NULL THEN 1 END) AS coupon_disc_NULL,
	COUNT(CASE WHEN coupon_match_disc IS NULL THEN 1 END) AS coupon_match_disc_NULL
FROM transaction_data

SELECT 
	COUNT(CASE WHEN classification_1 IS NULL THEN 1 END) AS classification_1_NULL,
	COUNT(CASE WHEN classification_2 IS NULL THEN 1 END) AS classification_2_NULL,
	COUNT(CASE WHEN classification_3 IS NULL THEN 1 END) AS classification_3_NULL,
	COUNT(CASE WHEN classification_4 IS NULL THEN 1 END) AS classification_4_NULL,
	COUNT(CASE WHEN classification_5 IS NULL THEN 1 END) AS classification_5_NULL,
	COUNT(CASE WHEN household_key IS NULL THEN 1 END) AS household_key_NULL
FROM hh_demographic

SELECT 
	COUNT(CASE WHEN description IS NULL THEN 1 END) AS description_NULL,
	COUNT(CASE WHEN campaign IS NULL THEN 1 END) AS campaign_NULL,
	COUNT(CASE WHEN start_day IS NULL THEN 1 END) AS start_day_NULL,
	COUNT(CASE WHEN end_day IS NULL THEN 1 END) AS end_day_NULL
FROM campaign_desc

SELECT 
	COUNT(CASE WHEN description IS NULL THEN 1 END) AS description_NULL,
	COUNT(CASE WHEN campaign IS NULL THEN 1 END) AS campaign_NULL,
	COUNT(CASE WHEN household_key IS NULL THEN 1 END) AS household_key_NULL
FROM campaign_table

SELECT 
	COUNT(CASE WHEN product_id IS NULL THEN 1 END) AS product_id_NULL,
	COUNT(CASE WHEN manufacturer IS NULL THEN 1 END) AS manufacturer_NULL,
	COUNT(CASE WHEN department IS NULL THEN 1 END) AS department_NULL,
	COUNT(CASE WHEN commodity_desc IS NULL THEN 1 END) AS commodity_desc_NULL,
	COUNT(CASE WHEN sub_commodity_desc IS NULL THEN 1 END) AS sub_commodity_desc_NULL
FROM product

	SELECT *
	FROM product
	WHERE department IS NULL

	DELETE FROM product
	WHERE department IS NULL

--Check duplicates
SELECT
	household_key,
	basket_id,
	product_id,
	COUNT(*) AS num_rows
FROM transaction_data
GROUP BY household_key, basket_id, product_id
HAVING COUNT(*) > 1

SELECT
	household_key,
	COUNT(*) AS num_rows
FROM hh_demographic
GROUP BY household_key
HAVING COUNT(*) > 1

SELECT
	description,
	start_day,
	end_day,
	COUNT(*) AS num_rows
FROM campaign_desc
GROUP BY description, start_day, end_day
HAVING COUNT(*) > 1
	--Check if these two campaign are intended for different purpose or not by checking commodities
	SELECT *
	FROM campaign_desc
	WHERE description = 'TypeB' AND start_day = 624

	WITH campaign_21_22 AS(
		SELECT
			c.campaign,
			p.commodity_desc,
			COUNT(*) AS num_rows
		FROM transaction_data AS t
		INNER JOIN campaign_table AS c
		ON c.household_key = t.household_key
		INNER JOIN product AS p
		ON p.product_id = t.product_id
		WHERE c.campaign = 21 OR c.campaign = 22
		GROUP BY c.campaign, p.commodity_desc
		)
	SELECT commodity_desc, COUNT(*) AS num_same_commodity
	FROM campaign_21_22
	GROUP BY commodity_desc
	ORDER BY num_same_commodity


SELECT
	description,
	household_key,
	campaign,
	COUNT(*) AS num_rows
FROM campaign_table
GROUP BY description, household_key, campaign
HAVING COUNT(*) > 1

SELECT
	product_id,
	manufacturer,
	department,
	commodity_desc,
	COUNT(*) AS num_rows
FROM product
GROUP BY product_id, manufacturer, department, commodity_desc
HAVING COUNT(*) > 1


--Join campaign tables to a new table
CREATE TABLE campaigns (
	description NVARCHAR(50),
	campaign INT,
	household_key INT,
	start_day INT,
	end_day INT
);
INSERT INTO campaigns (description, campaign, household_key, start_day, end_day)
SELECT ct.description, ct.campaign, ct.household_key, cd.start_day, cd.end_day
FROM campaign_desc AS cd
JOIN campaign_table AS ct
ON cd.campaign = ct.campaign

SELECT *
FROM campaigns
ORDER BY campaign

DROP TABLE campaign_desc, campaign_table

	--Checking missing value again in new table
	SELECT 
		COUNT(CASE WHEN description IS NULL THEN 1 END) AS description_NULL,
		COUNT(CASE WHEN campaign IS NULL THEN 1 END) AS campaign_NULL,
		COUNT(CASE WHEN household_key IS NULL THEN 1 END) AS household_key_NULL,
		COUNT(CASE WHEN start_day IS NULL THEN 1 END) AS start_day_NULL,
		COUNT(CASE WHEN end_day IS NULL THEN 1 END) AS end_day_NULL
	FROM campaigns;


--Checking data values for transaction_data table
SELECT
	COUNT(*) AS row_count,
	COUNT(DISTINCT product_id) AS num_distinct_product_id,
	MIN(product_id) AS min_product_id,
	MAX(product_id) AS max_product_id,
	MIN(household_key) AS min_household_key,
	MAX(household_key) AS max_household_key,
	COUNT(DISTINCT household_key) AS num_distinct_household_key,
	COUNT(DISTINCT basket_id) AS num_distinct_basket_id,
	MIN(day) AS min_day,
	MAX(day) AS max_day,
	COUNT(DISTINCT day) AS num_distinct_day,
	MIN(quantity) AS min_quantity,
	MAX(quantity) AS max_quantity,
	COUNT(DISTINCT quantity) AS num_distinct_quantity,
	MIN(sales_value) AS min_sales_value,
	MAX(sales_value) AS max_sales_value,
	AVG(sales_value) AS avg_sales_value,
	COUNT(DISTINCT store_id) AS num_distinct_store_id,
	MIN(retail_disc) AS min_retail_disc,
	MAX(retail_disc) AS max_retail_disc,
	AVG(retail_disc) AS avg_retail_disc,
	COUNT(DISTINCT week_no) AS num_distinct_week,
	MIN(week_no) AS min_week,
	MAX(week_no) AS max_week,
	MIN(coupon_disc) AS min_coupon_disc,
	MAX(coupon_disc) AS max_coupon_disc,
	AVG(coupon_disc) AS avg_coupon_disc,
	MIN(coupon_match_disc) AS min_coupon_match_disc,
	MAX(coupon_match_disc) AS max_coupon_match_disc,
	AVG(coupon_match_disc) AS avg_coupon_match_disc
FROM transaction_data

	--Check retail_disc greater than 0
	SELECT *
	FROM transaction_data
	WHERE retail_disc > 0;
	UPDATE transaction_data
	SET retail_disc = retail_disc * -1
	WHERE retail_disc > 0;

	--Check transaction with quantity equal 0
	SELECT *
	FROM transaction_data
	WHERE quantity = 0
		AND sales_value = 0
		AND retail_disc = 0
		AND coupon_disc = 0
		AND coupon_match_disc = 0;

	DELETE FROM transaction_data
	WHERE quantity = 0
		AND sales_value = 0
		AND retail_disc = 0
		AND coupon_disc = 0
		AND coupon_match_disc = 0;
	
	--Check which products have quantity equal 0
	SELECT *
	FROM transaction_data AS t
	LEFT JOIN product AS p
	ON t.product_id = p.product_id
	WHERE p.product_id IS NULL AND t.quantity <> 0 
	ORDER BY t.product_id;
	SELECT *
	FROM transaction_data AS t
	LEFT JOIN product AS p
	ON t.product_id = p.product_id
	WHERE p.product_id IS NULL
	ORDER BY t.product_id;
	--Here I want to see if there is any product_id in transaction_data table which is NULL in product table
	--but has the quantity NOT equal to 0
	SELECT *
	FROM transaction_data
	WHERE product_id IN (
		SELECT DISTINCT(t.product_id)
		FROM transaction_data AS t
		LEFT JOIN product AS p
		ON t.product_id = p.product_id
		WHERE p.product_id IS NULL)
		AND quantity <> 0;
	--Remove rows with product_id equal NULL in product table from transaction_data table
	DELETE t
	FROM transaction_data AS t
	LEFT JOIN product AS p
	ON t.product_id = p.product_id
	WHERE p.product_id IS NULL;
	--Check remaining rows with quantity equal 0
	SELECT *
	FROM transaction_data
	WHERE quantity = 0;
	--Removing them would not impact dramatically
	DELETE FROM transaction_data
	WHERE quantity = 0;
	--Check remaining rows with quantity equal 0
	SELECT *
	FROM transaction_data
	WHERE quantity = 0;

	--Check rows with sales_value euqal 0
	SELECT * 
	FROM transaction_data
	WHERE sales_value = 0 AND retail_disc = 0 AND coupon_disc = 0 AND coupon_match_disc = 0
	--Check to see whether specific products have these 0 values
	SELECT *
	FROM product
	WHERE product_id IN (
		SELECT product_id
		FROM transaction_data
		WHERE sales_value = 0 AND retail_disc = 0 AND coupon_disc = 0 AND coupon_match_disc = 0
		)
	--Remove thses rows
	DELETE FROM transaction_data
	WHERE sales_value = 0 AND retail_disc = 0 AND coupon_disc = 0 AND coupon_match_disc = 0

--Checking data values for hh_demographic table
SELECT
	COUNT(DISTINCT classification_1) AS num_distinct_classification1,
	MIN(classification_1) AS min_classification1,
	MAX(classification_1) AS max_classification1,
	COUNT(DISTINCT classification_2) AS num_distinct_classification2,
	MIN(classification_2) AS min_classification2,
	MAX(classification_2) AS max_classification2,
	COUNT(DISTINCT classification_3) AS num_distinct_classification3,
	MIN(classification_3) AS min_classification3,
	MAX(classification_3) AS max_classification3,
	COUNT(DISTINCT classification_4) AS num_distinct_classification4,
	MIN(classification_4) AS min_classification4,
	MAX(classification_4) AS max_classification4,
	COUNT(DISTINCT classification_5) AS num_distinct_classification5,
	MIN(classification_5) AS min_classification5,
	MAX(classification_5) AS max_classification5
FROM hh_demographic;

	SELECT DISTINCT(classification_3)
	FROM hh_demographic
	--Changing the values to their INT values and changing column name accordingly
	EXEC sp_rename 'hh_demographic.classification_3', 'classification_3_level', 'COLUMN';

	UPDATE hh_demographic
	SET classification_3_level = SUBSTRING(classification_3_level, 6, 2);

	ALTER TABLE hh_demographic
	ALTER COLUMN classification_3_level INT;

	SELECT DISTINCT(classification_3_level)
	FROM hh_demographic
	ORDER BY classification_3_level;

	--Change the name of columns
	EXEC sp_rename 'hh_demographic.classification_1', 'age_group', 'COLUMN';
	EXEC sp_rename 'hh_demographic.classification_2', 'gender', 'COLUMN';
	EXEC sp_rename 'hh_demographic.classification_3_level', 'income', 'COLUMN';
	EXEC sp_rename 'hh_demographic.classification_4', 'household_size', 'COLUMN';
	EXEC sp_rename 'hh_demographic.classification_5', 'education', 'COLUMN';

	--Change column values
	UPDATE hh_demographic
	SET age_group = CASE age_group 
						WHEN 'Age Group1' THEN '18-24 yrs'
						WHEN 'Age Group2' THEN '25-34 yrs'
						WHEN 'Age Group3' THEN '35-44 yrs'
						WHEN 'Age Group4' THEN '45-54 yrs'
						WHEN 'Age Group5' THEN '55-64 yrs'
						WHEN 'Age Group6' THEN '65+ yrs'
					END
	FROM hh_demographic;

	UPDATE hh_demographic
	SET gender = CASE gender 
						WHEN 'Y' THEN 'Female'
						WHEN 'X' THEN 'Male'
						WHEN 'Z' THEN 'Other'
					END
	FROM hh_demographic;


	ALTER TABLE hh_demographic
	ALTER COLUMN income VARCHAR(20);

	UPDATE hh_demographic
	SET income = CASE income 
						WHEN '1' THEN '<$45k'
						WHEN '2' THEN '<$45k'
						WHEN '3' THEN '<$45k'
						WHEN '4' THEN '$45K-$100K'
						WHEN '5' THEN '$45K-$100K'
						WHEN '6' THEN '$45K-$100K'
						WHEN '7' THEN '$100K-$150K'
						WHEN '8' THEN '$100K-$150K'
						WHEN '9' THEN '$100K-$150K'
						WHEN '10' THEN '>$100K'
						WHEN '11' THEN '>$100K'
						WHEN '12' THEN '>$100K'
					END
	FROM hh_demographic;

	UPDATE hh_demographic
	SET education = CASE education 
						WHEN 'Group1' THEN 'Less than high school'
						WHEN 'Group2' THEN 'High school'
						WHEN 'Group3' THEN 'College training'
						WHEN 'Group4' THEN 'College diploma'
						WHEN 'Group5' THEN 'Bachelor’s degree'
						WHEN 'Group6' THEN 'Graduate degree'
					END
	FROM hh_demographic;

--Checking data values for campaigns table
SELECT
	COUNT(DISTINCT description) AS num_distinct_description,
	MIN(description) AS min_descirption,
	MAX(description) AS max_description,
	COUNT(DISTINCT campaign) AS num_distinct_campaign,
	MIN(campaign) AS min_campaign,
	MAX(campaign) AS max_campaign,
	COUNT(DISTINCT household_key) AS num_distinct_household_key,
	MIN(household_key) AS min_household_key,
	MAX(household_key) AS max_household_key,
	COUNT(DISTINCT start_day) AS num_distinct_start_day,
	MIN(start_day) AS min_start_day,
	MAX(start_day) AS max_start_day,
	COUNT(DISTINCT end_day) AS num_distinct_end_day,
	MIN(end_day) AS min_end_day,
	MAX(end_day) AS max_end_day
FROM campaigns;


--Checking data values for campaigns table
SELECT
	COUNT(DISTINCT description) AS num_distinct_description,
	MIN(description) AS min_descirption,
	MAX(description) AS max_description,
	COUNT(DISTINCT campaign) AS num_distinct_campaign,
	MIN(campaign) AS min_campaign,
	MAX(campaign) AS max_campaign,
	COUNT(DISTINCT household_key) AS num_distinct_household_key,
	MIN(household_key) AS min_household_key,
	MAX(household_key) AS max_household_key,
	COUNT(DISTINCT start_day) AS num_distinct_start_day,
	MIN(start_day) AS min_start_day,
	MAX(start_day) AS max_start_day,
	COUNT(DISTINCT end_day) AS num_distinct_end_day,
	MIN(end_day) AS min_end_day,
	MAX(end_day) AS max_end_day
FROM campaigns;

--Checking data values for product table
SELECT
	COUNT(DISTINCT product_id) AS num_distinct_product_id,
	MIN(product_id) AS min_product_id,
	MAX(product_id) AS max_product_id,
	COUNT(DISTINCT manufacturer) AS num_distinct_manufacturer,
	COUNT(DISTINCT department) AS num_distinct_department,
	COUNT(DISTINCT commodity_desc) AS num_distinct_commodity_desc,
	COUNT(DISTINCT sub_commodity_desc) AS num_distinct_sub_commodity_desc
FROM product;

--Add duration column to campaigns table
ALTER TABLE campaigns 
ADD duration INT;
UPDATE campaigns
SET duration = end_day - start_day + 1
SELECT *
FROM campaigns;


--Create transactions_campaigns table
WITH transactions_in_campaigns AS(
	SELECT *
	FROM transaction_data
	WHERE day BETWEEN (
		SELECT MIN(start_day)
		FROM campaigns
		)
		AND
		(SELECT MAX(end_day)
		FROM campaigns
		)
)
SELECT
	t.household_key,
	t.basket_id,
	t.product_id,
	t.day,
	t.sales_value,
	t.quantity,
	c.campaign,
	c.start_day,
	c.end_day
INTO transactions_campaigns
FROM transactions_in_campaigns AS t
JOIN campaigns AS c
	ON t.household_key = c.household_key
WHERE t.day >= c.start_day
  AND t.day <= c.end_day;



--Add date column to transactions table
ALTER TABLE transaction_data
ADD date DATE;

UPDATE transaction_data
SET date = DATEADD(
	DAY,
	day - 1,
	'2023-03-01'
	);

SELECT day, date
FROM transaction_data
WHERE day = 224

--Check if there is any single quantity in baskets
SELECT basket_id, SUM(quantity) AS total_quantity
FROM transactions_campaigns
GROUP BY basket_id
ORDER BY total_quantity;

--Sales per Day KPI
WITH sales_per_day AS(
	SELECT
		campaign,
		day,
		SUM(sales_value) AS total_sales_per_day
	FROM transactions_campaigns
	GROUP BY campaign, day
	)
SELECT
	campaign,
	AVG(total_sales_per_day) AS SPD
FROM sales_per_day
GROUP BY campaign
ORDER BY campaign

--Sales per Houshold KPI
WITH sales_per_household AS(
	SELECT
		campaign,
		household_key,
		SUM(sales_value) AS total_sales_per_household
	FROM transactions_campaigns
	GROUP BY campaign, household_key
	)
SELECT
	campaign,
	AVG(total_sales_per_household) AS SPH
FROM sales_per_household
GROUP BY campaign
ORDER BY campaign

--Sales per Basket KPI
WITH sales_per_basket AS(
	SELECT
		campaign,
		basket_id,
		SUM(sales_value) AS total_sales_per_basket
	FROM transactions_campaigns
	GROUP BY campaign, basket_id
	)
SELECT
	campaign,
	AVG(total_sales_per_basket) AS SPB
FROM sales_per_basket
GROUP BY campaign
ORDER BY campaign

--Units per Basket KPI

WITH units_per_basket AS (
	SELECT 
		campaign,
		basket_id,
		SUM(quantity) AS total_units_per_basket
	FROM transactions_campaigns
	GROUP BY campaign, basket_id
	)
SELECT
	campaign,
	ROUND(AVG(CAST(total_units_per_basket AS FLOAT)), 2) AS units_per_basket
FROM units_per_basket
GROUP BY campaign
ORDER BY campaign;

--Single Quantity per Basket KPI
WITH total_unit_per_campaign_basket AS(
	SELECT
		campaign,
		basket_id,
		SUM(quantity) AS total_units
	FROM transactions_campaigns
	GROUP BY campaign, basket_id
	)
SELECT
	campaign,
	ROUND(((CAST(SUM(CASE WHEN total_units = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*))) * 100, 2) AS '%SQB'
FROM total_unit_per_campaign_basket
GROUP BY campaign
ORDER BY campaign;

--Add new_customer in each day to transaction_data table

ALTER TABLE transaction_data
ADD new_customer varchar(5);

UPDATE transaction_data
SET new_customer = CASE
		WHEN day = (
			SELECT MIN(t2.day)
			FROM transaction_data AS t2
			WHERE t2.household_key = transaction_data.household_key
			)
			THEN 'Yes'
		ELSE 'No'
	END;

SELECT household_key, basket_id, day, new_customer
FROM transaction_data
ORDER BY household_key, day;


SELECT *
FROM transaction_data
ORDER BY day

WITH transactions_in_campaigns AS(
	SELECT *
	FROM transaction_data
	WHERE day BETWEEN (
		SELECT MIN(start_day)
		FROM campaigns
		)
		AND
		(SELECT MAX(end_day)
		FROM campaigns
		)
		)
SELECT
	*
FROM transactions_in_campaigns AS t
JOIN campaigns AS c
	ON t.household_key = c.household_key
WHERE t.day >= c.start_day
AND t.day <= c.end_day;


WITH total_households AS (SELECT day, COUNT(DISTINCT household_key) AS total_hh_day
FROM transaction_data
GROUP BY day
)

SELECT AVG(total_hh_day)
FROM total_households
WHERE day < 224



--Add store column
ALTER TABLE transaction_data
ADD store NVARCHAR(255);


-- Create city and direction lists

--Define cities
DECLARE @Cities TABLE (CityID INT IDENTITY(1,1), CityName NVARCHAR(100));
INSERT INTO @Cities (CityName)
VALUES 
('Toronto'), ('Vancouver'), ('Calgary'), ('Edmonton'), ('Ottawa'),
('Montreal'), ('Regina'), ('Saskatoon'), ('Winnipeg'), ('Halifax'),
('Victoria'), ('St. John''s'), ('Quebec City'), ('Hamilton'), ('London'),
('Kitchener'), ('Windsor'), ('Charlottetown'), ('Fredericton'), ('Whitehorse'),
('Yellowknife'), ('Iqaluit'), ('Kelowna'), ('Red Deer'), ('Thunder Bay'),
('Barrie'), ('Guelph'), ('Brantford'), ('Kamloops'), ('Prince George'),
('Grande Prairie'), ('Medicine Hat'), ('Lethbridge'), ('Saint John'), ('Drummondville'),
('Saguenay'), ('Sherbrooke'), ('Trois-Rivières'), ('Cornwall'), ('Sarnia'),
('Peterborough'), ('Nanaimo'), ('Abbotsford'), ('Chilliwack'), ('Langley'),
('Delta'), ('Surrey'), ('Burnaby'), ('Richmond'), ('Coquitlam'),
('New Westminster'), ('Moose Jaw'), ('Swift Current'), ('Lloydminster'), ('Estevan'),
('Weyburn'), ('Yorkton'), ('Prince Albert'), ('Flin Flon'), ('Brandon'),
('Steinbach'), ('Thompson'), ('Kenora'), ('Orillia'), ('North Bay'),
('Timmins'), ('Sudbury'), ('Oshawa'), ('Pickering'), ('Whitby'),
('Markham'), ('Mississauga'), ('Brampton'), ('Niagara Falls'), ('Welland'),
('St. Catharines'), ('Leamington'), ('Stratford'), ('Cambridge'), ('Waterloo'),
('Milton'), ('Oakville'), ('Burlington'), ('Saint-Hyacinthe'), ('Blainville'),
('Laval'), ('Gatineau'), ('Longueuil'), ('Terrebonne'), ('Châteauguay'),
('Repentigny'), ('Granby'), ('Joliette'), ('Shawinigan'), ('Alma'),
('Sept-Îles'), ('Val-d''Or'), ('Rimouski'), ('Corner Brook'), ('Gander'),
('Happy Valley-Goose Bay'), ('Bay Roberts'), ('Clarenville'), ('Summerside'), ('Cranbrook'),
('Penticton'), ('Quesnel'), ('Fort St. John'), ('Dawson Creek'), ('Inuvik'),
('Fort McMurray'), ('Cold Lake'), ('Camrose'), ('Okotoks'), ('Spruce Grove'),
('Beaumont'), ('Stony Plain');

--Define directions
DECLARE @Directions TABLE (DirectionID INT IDENTITY(1,1), Direction NVARCHAR(10));
INSERT INTO @Directions (Direction)
VALUES ('North'), ('South'), ('East'), ('West');

--Assign a unique row number to each store_id
WITH StoreRanked AS (
    SELECT store_id, ROW_NUMBER() OVER (ORDER BY store_id) AS rn
    FROM (SELECT DISTINCT store_id FROM transaction_data WHERE store_id IS NOT NULL) AS stores
),
CityCount AS (
    SELECT COUNT(*) AS cnt FROM @Cities
),
DirectionCount AS (
    SELECT COUNT(*) AS cnt FROM @Directions
),
AssignedNames AS (
    SELECT 
        s.store_id,
        c.CityName,
        d.Direction,
        s.rn
    FROM StoreRanked s
    CROSS APPLY (
        SELECT CityName 
        FROM @Cities 
        WHERE CityID = ((s.rn - 1) % (SELECT cnt FROM CityCount)) + 1
    ) c
    CROSS APPLY (
        SELECT Direction 
        FROM @Directions 
        WHERE DirectionID = ((s.rn - 1) % (SELECT cnt FROM DirectionCount)) + 1
    ) d
)
--Update store_table
UPDATE t
SET t.store = a.CityName + ' ' + a.Direction + ' ' + CAST(t.store_id AS NVARCHAR)
FROM transaction_data t
JOIN AssignedNames a ON t.store_id = a.store_id;




--Times of visit for each household per week

WITH visits_per_household_week AS(
	SELECT 
		week_no,
		household_key,
		COUNT(DISTINCT basket_id) AS visit_count
	FROM transaction_data
	GROUP BY week_no, household_key
	)
SELECT 
	week_no,
	AVG(visit_count * 1.0) AS avg_visit_per_household
FROM visits_per_household_week
GROUP BY week_no
ORDER BY week_no