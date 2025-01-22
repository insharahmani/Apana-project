select* from [project].dbo.[apana.xls];

SELECT 
    AVG(Coal_India_5500_CFR_London_Close_USD) AS mean
FROM 
  [project].dbo.[apana.xls];

  SELECT 
    AVG(Coal_RB_4800_FOB_London_Close_USD) AS mean_Coal_RB_4800,
    AVG(Coal_RB_5500_FOB_London_Close_USD) AS mean_Coal_RB_5500,
    AVG(Coal_RB_5700_FOB_London_Close_USD) AS mean_Coal_RB_5700,
    AVG(Coal_RB_6000_FOB_CurrentWeek_Avg_USD) AS mean_Coal_RB_6000,
    AVG(Coal_India_5500_CFR_London_Close_USD) AS mean_Coal_India_5500,
    AVG(Price_WTI) AS mean_Price_WTI,
    AVG(Price_Brent_Oil) AS mean_Price_Brent_Oil,
    AVG(Price_Dubai_Brent_Oil) AS mean_Price_Dubai_Brent,
    AVG(Price_ExxonMobil) AS mean_Price_ExxonMobil,
    AVG(Price_Shenhua) AS mean_Price_Shenhua,
    AVG(Price_All_Share) AS mean_Price_All_Share,
    AVG(Price_Mining) AS mean_Price_Mining,
    AVG(Price_LNG_Japan_Korea_Marker_PLATTS) AS mean_Price_LNG,
    AVG(Price_ZAR_USD) AS mean_Price_ZAR_USD,
    AVG(Price_Natural_Gas) AS mean_Price_Natural_Gas,
    AVG(Price_ICE) AS mean_Price_ICE,
    AVG(Price_Dutch_TTF) AS mean_Price_Dutch_TTF,
    AVG(Price_Indian_en_exg_rate) AS mean_Price_Indian_ExRate
FROM 
    [project].dbo.[apana.xls];

	WITH OrderedData AS (
    SELECT 
        Coal_RB_4800_FOB_London_Close_USD,
        ROW_NUMBER() OVER (ORDER BY Coal_RB_4800_FOB_London_Close_USD) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM 
        [project].dbo.[apana.xls]
)
SELECT 
    AVG(Coal_RB_4800_FOB_London_Close_USD) AS median_Coal_RB_4800
FROM 
    OrderedData
WHERE 
    row_num IN (FLOOR((total_rows + 1) / 2), CEILING((total_rows + 1) / 2));
	SELECT TOP 1 
    Coal_RB_4800_FOB_London_Close_USD AS value_4800, 
    COUNT(Coal_RB_4800_FOB_London_Close_USD) AS frequency_4800
FROM 
   [project].dbo.[apana.xls]
GROUP BY 
    Coal_RB_4800_FOB_London_Close_USD
ORDER BY 
    frequency_4800 DESC;
	SELECT TOP 1 
    Coal_RB_5500_FOB_London_Close_USD AS value_5500, 
    COUNT(Coal_RB_5500_FOB_London_Close_USD) AS frequency_5500
FROM 
   [project].dbo.[apana.xls]
GROUP BY 
    Coal_RB_5500_FOB_London_Close_USD
ORDER BY 
    frequency_5500 DESC;

DELETE FROM [project].dbo.[apana.xls]
WHERE Price_Indian_en_exg_rate IS NULL 
   OR Price_LNG_Japan_Korea_Marker_PLATTS IS NULL 
   OR Price_Natural_Gas IS NULL
;
#checknullvalue

SELECT 
    'Price_Indian_en_exg_rate' AS column_name, 
    COUNT(*) AS null_count
FROM  [project].dbo.[apana.xls]
WHERE Price_Indian_en_exg_rate IS NULL
UNION
SELECT 
    'Price_LNG_Japan_Korea_Marker_PLATTS', 
    COUNT(*)AS null_count

FROM  [project].dbo.[apana.xls]
WHERE Price_LNG_Japan_Korea_Marker_PLATTS IS NULL
UNION
SELECT 
    'Price_Natural_Gas', 
    COUNT(*)
FROM  [project].dbo.[apana.xls]
WHERE Price_Natural_Gas IS NULL;
#checkcolumnwisestatics

SELECT 
    MIN(Price_Natural_Gas) AS min_price,
    MAX(Price_Natural_Gas) AS max_price,
    AVG(Price_Natural_Gas) AS avg_price
FROM  [project].dbo.[apana.xls];

kurtosis

WITH stats AS (
    SELECT
        AVG(Price_Natural_Gas) AS mean,
        COUNT(*) AS n
    FROM  [project].dbo.[apana.xls]
),
deviations AS (
    SELECT
        Price_Natural_Gas,
        (Price_Natural_Gas - stats.mean) AS deviation
    FROM  [project].dbo.[apana.xls], stats
),
sums AS (
    SELECT
        SUM(POWER(deviation, 2)) AS sum_of_squares,
        SUM(POWER(deviation, 4)) AS sum_of_fourth_powers,
        COUNT(*) AS n
    FROM deviations
)
SELECT
    (n * sum_of_fourth_powers) / POWER(sum_of_squares, 2) - 3 AS kurtosis
FROM sums;
#skewness

WITH stats AS (
    SELECT 
        AVG(Price_WTI) AS mean,
        STDEV(Price_WTI) AS stddev,
        COUNT(Price_WTI) AS n
    FROM [project].dbo.[apana.xls]
),
deviation AS (
    SELECT 
        Price_WTI,
        Price_WTI - (SELECT mean FROM stats) AS deviation
    FROM [project].dbo.[apana.xls]
),
skewness_calc AS (
    SELECT 
        SUM(POWER(deviation, 3)) AS sum_cubed_dev,
        (SELECT n FROM stats) AS n,
        (SELECT stddev FROM stats) AS stddev
    FROM deviation
)
SELECT 
    (n * sum_cubed_dev) / ((n - 1) * (n - 2) * POWER(stddev, 3)) AS skewness
FROM skewness_calc;



