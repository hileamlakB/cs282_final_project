-- fsepsis

-- find disease code
SELECT icd9_code, long_title
FROM `mimmic_tables.D_ICD_DIAGNOSES`
WHERE long_title LIKE '%sepsis%' OR long_title LIKE '%septic shock%'


-- find treatments that were given to the above icd9 patients
SELECT d.hadm_id, d.icd9_code, dd.long_title, UNIQUE p.drug
FROM `mimmic_tables.DIAGNOSES_ICD` d
JOIN `mimmic_tables.D_ICD_DIAGNOSES` dd ON d.icd9_code = dd.icd9_code
JOIN `mimmic_tables.PRESCRIPTIONS` p ON d.hadm_id = p.hadm_id
WHERE dd.long_title LIKE '%sepsis%' OR dd.long_title LIKE '%septic shock%'

-- find disease code for ARDS
SELECT icd9_code, long_title
FROM `mimmic_tables.D_ICD_DIAGNOSES`
WHERE long_title LIKE '%acute respiratory distress syndrome%'
   OR long_title LIKE '%ARDS%'
   OR long_title LIKE '%respiratory failure%'
   OR long_title LIKE '%hypoxemia%'


SELECT DISTINCT p.drug
FROM `mimmic_tables.DIAGNOSES_ICD` d
JOIN `mimmic_tables.D_ICD_DIAGNOSES` dd ON d.icd9_code = dd.icd9_code
JOIN `mimmic_tables.PRESCRIPTIONS` p ON d.hadm_id = p.hadm_id
WHERE dd.long_title LIKE '%acute respiratory distress syndrome%'
   OR dd.long_title LIKE '%ARDS%'
   OR dd.long_title LIKE '%respiratory failure%'
   OR dd.long_title LIKE '%hypoxemia%'

-- Cardiovascular Events
SELECT icd9_code, long_title
FROM `mimmic_tables.D_ICD_DIAGNOSES`
WHERE long_title LIKE '%myocardial infarction%' OR long_title LIKE '%cardiac arrest%'

SELECT DISTINCT p.drug
FROM `mimmic_tables.DIAGNOSES_ICD` d
JOIN `mimmic_tables.D_ICD_DIAGNOSES` dd ON d.icd9_code = dd.icd9_code
JOIN `mimmic_tables.PRESCRIPTIONS` p ON d.hadm_id = p.hadm_id
WHERE dd.long_title LIKE '%myocardial infarction%' OR dd.long_title LIKE '%cardiac arrest%'

-- acute renal failure
SELECT icd9_code, long_title
FROM `mimmic_tables.D_ICD_DIAGNOSES`
WHERE long_title LIKE '%acute renal failure%' OR long_title LIKE '%dialysis%'

SELECT DISTINCT p.drug
FROM `mimmic_tables.DIAGNOSES_ICD` d
JOIN `mimmic_tables.D_ICD_DIAGNOSES` dd ON d.icd9_code = dd.icd9_code
JOIN `mimmic_tables.PRESCRIPTIONS` p ON d.hadm_id = p.hadm_id
WHERE dd.long_title LIKE '%acute renal failure%' OR dd.long_title LIKE '%dialysis%'



-- extract all the ARDS patient infromations
SELECT * FROM `mimmic_tables.CHARTEVENTS` ce 
WHERE ce.hadm_id IN (
    SELECT DISTINCT d.hadm_id
    FROM `mimmic_tables.DIAGNOSES_ICD` d
    JOIN `mimmic_tables.D_ICD_DIAGNOSES` dd ON d.icd9_code = dd.icd9_code
    WHERE dd.long_title LIKE '%acute respiratory distress syndrome%'
       OR dd.long_title LIKE '%ARDS%'
       OR dd.long_title LIKE '%respiratory failure%'
       OR dd.long_title LIKE '%hypoxemia%'
)

-- extract all the ARDS parameters we need
CREATE TABLE `mimmic_tables.ARDS_parameters` AS
SELECT
    'FiO2' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_ITEMS`
WHERE
    LOWER(label) LIKE '%fio2%'
UNION ALL
SELECT
    'Respiratory Rate' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_ITEMS`
WHERE
    LOWER(label) LIKE '%respiratory rate%'
UNION ALL
SELECT
    'PEEP' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_ITEMS`
WHERE
    LOWER(label) LIKE '%peep%'
UNION ALL
SELECT
    'Tidal Volume' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_ITEMS`
WHERE
    LOWER(label) LIKE '%tidal volume%'
UNION ALL
SELECT
    'Blood Pressure' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_ITEMS`
WHERE
    LOWER(label) LIKE '%blood pressure%'
UNION ALL
SELECT
    'Heart Rate' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_ITEMS`
WHERE
    LOWER(label) LIKE '%heart rate%'
UNION ALL
SELECT
    'Body Temperature' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_ITEMS`
WHERE
    LOWER(label) LIKE '%temperature%'
UNION ALL
SELECT
    'Glasgow Coma Scale (GCS)' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_ITEMS`
WHERE
   LOWER(label) LIKE '%glasgow coma scale%' OR LOWER(label) LIKE '%gcs%'
UNION ALL
SELECT
    'Serum Creatinine' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_LABITEMS`
WHERE
    LOWER(label) LIKE '%creatinine%'
UNION ALL
SELECT
    'Lactate' AS parameter,
    STRING_AGG(CAST(itemid AS STRING), ', ') AS itemids
FROM
    `mimmic_tables.D_LABITEMS`
WHERE
    LOWER(label) LIKE '%lactate%'


-- query to finally create the table that contains all the infromation we need

CREATE TABLE `mimmic_tables.ards_detailed` AS
SELECT
    ce.icustay_id,
    ce.charttime,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Respiratory Rate'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS Respiratory_Rate,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Tidal Volume'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS Tidal_Volume,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Body Temperature'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS Body_Temperature,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'PEEP'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS PEEP,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'FiO2'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS FiO2,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Serum Creatinine'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS Serum_Creatinine,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Blood Pressure'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS Blood_Pressure,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Heart Rate'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS Heart_Rate,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Lactate'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS Lactate,
    MAX(CASE WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Glasgow Coma Scale (GCS)'), ', ')) AS item) THEN ce.valuenum ELSE NULL END) AS Glasgow_Coma_Scale_GCS,
   (SELECT STRING_AGG(p.drug, ', ') 
     FROM `mimmic_tables.PRESCRIPTIONS` p 
     WHERE p.hadm_id = ce.hadm_id AND 
           ce.charttime BETWEEN p.STARTDATE AND p.ENDDATE
    ) AS Drugs_Used
FROM
    `mimmic_tables.ards_chartevents` ce
GROUP BY
    ce.icustay_id, ce.charttime;


CREATE TABLE `mimmic_tables.ards_detailed` AS
SELECT
    p.icustay_id,
    p.STARTDATE as starttime,
    p.ENDDATE as endtime,
    p.DRUG_TYPE,
    p.DRUG,
    p.DRUG_NAME_POE,
    p.DRUG_NAME_GENERIC,
    p.FORMULARY_DRUG_CD,
    ce.charttime,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Respiratory Rate'), ',')) AS item) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS Respiratory_Rate,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Tidal Volume'), ','))AS item ) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS Tidal_Volume,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Body Temperature'), ',')) AS item) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS Body_Temperature, 
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'PEEP'), ',')) AS item ) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS PEEP,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'FiO2'), ',')) AS item) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS FiO2,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Serum Creatinine'), ',')) AS item) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS Serum_Creatinine,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Blood Pressure'), ',')) AS item) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS Blood_Pressure,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Heart Rate'), ',')) AS item) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS Heart_Rate,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Lactate'), ',')) AS item) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS Lactate,
    MAX(CASE 
            WHEN ce.itemid IN (SELECT CAST(item AS INT64) FROM UNNEST(SPLIT((SELECT itemids FROM `mimmic_tables.ARDS_parameters` WHERE parameter = 'Glasgow Coma Scale (GCS)'), ',')) AS item) 
            THEN ce.valuenum 
            ELSE NULL 
        END) AS Glasgow_Coma_Scale_GCS
FROM
    `mimmic_tables.PRESCRIPTIONS` p
JOIN
    `mimmic_tables.ards_chartevents` ce ON p.icustay_id = ce.icustay_id AND ce.charttime BETWEEN p.STARTDATE AND p.ENDDATE
GROUP BY
    p.icustay_id, p.STARTDATE, p.ENDDATE, ce.charttime, p.DRUG_TYPE, p.DRUG, p.DRUG_NAME_POE, p.DRUG_NAME_GENERIC, p.FORMULARY_DRUG_CD;


CREATE TABLE mimmic_tables.ards_filter as
SELECT ad.*
FROM `mimmic_tables.ards_detailed` ad
JOIN `mimmic_tables.ICUSTAYS` ist ON ad.icustay_id = ist.icustay_id
JOIN `mimmic_tables.PATIENTS` pat ON pat.SUBJECT_ID = ist.SUBJECT_ID
WHERE 
    -- Calculate patient's age at the start date and filter for at least 15 years old
    TIMESTAMP_DIFF(ad.starttime, pat.dob, DAY) / 365.25 >= 15
    AND
    -- Calculate stay duration and filter between 12 hours (0.5 days) and 10 days
    (ist.outtime - ist.intime) BETWEEN INTERVAL '12' HOUR AND INTERVAL '10' DAY;



-- query to create table with the perscriptions that we have data for
CREATE TABLE `mimmic_tables.prescriptions_with_actual_price` AS
SELECT
    p.*,
    adc.OPAL_Price AS Standardized_Cost,
    adc.OPAL_Standardized_Unit AS Cost_Unit,
    CASE
        WHEN SAFE_CAST(p.DOSE_VAL_RX AS NUMERIC) IS NULL THEN NULL
        ELSE ROUND(CAST(p.DOSE_VAL_RX AS NUMERIC) * adc.OPAL_Price, 2)
    END AS Actual_Price
FROM
    `mimmic_tables.simplified_prescriptions` p
JOIN
    `sacred-union-404507.mimmic_tables.ARDS_drug_cost_clean` adc
ON
    p.drug = adc.drug
WHERE
    adc.OPAL_Price IS NOT NULL;


CREATE TABLE `sacred-union-404507.mimmic_tables.ards_filter_with_costs` AS
SELECT 
    af.*, 
    COALESCE(c.OPAL_Standardized_Cost, c.OPAL_Price) as Standardized_Cost,
    COALESCE(c.OPAL_Standardized_Unit, c.OPAL_Unit) as Standardized_Unit
FROM 
    `sacred-union-404507.mimmic_tables.ards_filter` af
LEFT JOIN 
    `sacred-union-404507.mimmic_tables.ARDS_drug_cost` c 
    ON LOWER(af.DRUG) LIKE CONCAT('%', LOWER(c.drug), '%');

-- sample the multiple icustay_id for each patient
CREATE TABLE `sacred-union-404507.mimmic_tables.ards_SampledICUStays2` AS
WITH DistinctICUStays AS (
    SELECT DISTINCT icustay_id
    FROM `sacred-union-404507.mimmic_tables.ards_filter`
)
SELECT icustay_id
FROM DistinctICUStays
WHERE RAND() < 0.2;  -- Adjust this value to control the sampling rate

-- 

-- 
CREATE TABLE `sacred-union-404507.mimmic_tables.ards_filter_with_actions` AS
SELECT 
    af.*, 
    ata.Actions
FROM 
    `sacred-union-404507.mimmic_tables.ards_filter_with_costs` af
LEFT JOIN 
    `sacred-union-404507.mimmic_tables.ards_treatment_actions` ata 
    ON LOWER(ata.Drugs) LIKE CONCAT('%', LOWER(af.DRUG), '%');

-- After creating the time intervals merge with ards_filterd 
WITH expanded_interval AS (
    SELECT
        icustay_id,
        start_time,
        end_time,
        charttime
    FROM
        `your_dataset.ards_filtered_time_interval`,
        UNNEST(SPLIT(charttimes)) AS charttime
)

SELECT
    e.icustay_id,
    e.start_time,
    e.end_time,
    e.charttime AS interval_charttime,
    AVG(f.Respiratory_Rate) AS avg_respiratory_rate,
    AVG(f.Tidal_Volume) AS avg_tidal_volume,
    AVG(f.Body_Temperature) AS avg_body_temperature,
    AVG(f.PEEP) AS avg_peep,
    AVG(f.FiO2) AS avg_fio2,
    AVG(f.Serum_Creatinine) AS avg_serum_creatinine,
    AVG(f.Blood_Pressure) AS avg_blood_pressure,
    AVG(f.Heart_Rate) AS avg_heart_rate,
    AVG(f.Lactate) AS avg_lactate,
    AVG(f.Glasgow_Coma_Scale_GCS) AS avg_glasgow_coma_scale_gcs,
    -- More AVG computations for other vital columns
    STRING_AGG(IFNULL(f.DRUG_TYPE, ''), ' ') AS drug_types,
    STRING_AGG(IFNULL(f.DRUG, ''), ' ') AS drugs,
    STRING_AGG(IFNULL(f.DRUG_NAME_POE, ''), ' ') AS drug_names_poe,
    STRING_AGG(IFNULL(f.DRUG_NAME_GENERIC, ''), ' ') AS drug_names_generic,
    STRING_AGG(IFNULL(f.FORMULARY_DRUG_CD, ''), ' ') AS formulary_drug_codes
FROM
    expanded_interval e
JOIN
    `your_dataset.ards_filter` f ON e.icustay_id = f.icustay_id AND e.charttime = f.charttime
GROUP BY
    e.icustay_id, e.start_time, e.end_time, e.charttime


CREATE TABLE `sacred-union-404507.mimmic_tables.ards_combined_actions` AS
SELECT 
    afw.*,
    ata.Actions
FROM 
    `sacred-union-404507.mimmic_tables.ards_filter_with_costs` afw
LEFT JOIN 
    `sacred-union-404507.mimmic_tables.ards_treatment_actions` ata 
    ON LOWER(ata.Drugs) LIKE CONCAT('%', LOWER(afw.DRUG), '%');


create table `sacred-union-404507.mimmic_tables.ards_final_totaled_cost` as
WITH expanded_interval AS (
    SELECT
        icustay_id,
        start_time,
        end_time,
        charttime
    FROM
        `sacred-union-404507.mimmic_tables.ards_filtered_time_interval`,
        UNNEST(SPLIT(charttimes)) AS charttime
)

SELECT
    e.icustay_id,
    e.start_time,
    e.end_time,
    AVG(aca.Respiratory_Rate) AS avg_respiratory_rate,
    AVG(aca.Tidal_Volume) AS avg_tidal_volume,
    AVG(aca.Body_Temperature) AS avg_body_temperature,
    AVG(aca.PEEP) AS avg_peep,
    AVG(aca.FiO2) AS avg_fio2,
    AVG(aca.Serum_Creatinine) AS avg_serum_creatinine,
    AVG(aca.Blood_Pressure) AS avg_blood_pressure,
    AVG(aca.Heart_Rate) AS avg_heart_rate,
    AVG(aca.Lactate) AS avg_lactate,
    AVG(aca.Glasgow_Coma_Scale_GCS) AS avg_glasgow_coma_scale_gcs,
    STRING_AGG(IFNULL(aca.DRUG, ''), ', ') AS drugs,
    STRING_AGG(IFNULL(aca.Actions, ''), ', ') AS combined_actions,
    SUM(aca.Standardized_Cost) AS total_cost
FROM
    expanded_interval e
JOIN
    `sacred-union-404507.mimmic_tables.ards_combined_actions` aca 
    ON e.icustay_id = aca.icustay_id AND e.charttime = aca.charttime
GROUP BY
    e.icustay_id, e.start_time, e.end_time




create table `sacred-union-404507.mimmic_tables.ards_final_totaled_cost` as
WITH expanded_interval AS (
    SELECT
        icustay_id,
        start_time,
        end_time,
        PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S UTC', charttime) AS charttime
    FROM
        `sacred-union-404507.mimmic_tables.ards_filtered_time_interval`,
        UNNEST(SPLIT(charttimes)) AS charttime
)

SELECT
    e.icustay_id,
    e.start_time,
    e.end_time,
    e.chartime,
    AVG(aca.Respiratory_Rate) AS avg_respiratory_rate,
    AVG(aca.Tidal_Volume) AS avg_tidal_volume,
    AVG(aca.Body_Temperature) AS avg_body_temperature,
    AVG(aca.PEEP) AS avg_peep,
    AVG(aca.FiO2) AS avg_fio2,
    AVG(cast(aca.Serum_Creatinine as INT64)) AS avg_serum_creatinine,
    AVG(aca.Blood_Pressure) AS avg_blood_pressure,
    AVG(aca.Heart_Rate) AS avg_heart_rate,
    AVG(cast(aca.Lactate as INT64)) AS avg_lactate,
    AVG(aca.Glasgow_Coma_Scale_GCS) AS avg_glasgow_coma_scale_gcs,
    STRING_AGG(IFNULL(aca.DRUG, ''), ', ') AS drugs,
    STRING_AGG(IFNULL(cast(aca.Actions as STRING), ''), ', ') AS combined_actions,
    SUM(aca.Standardized_Cost) AS total_cost
FROM
    expanded_interval e
JOIN
    `sacred-union-404507.mimmic_tables.ards_sampled_cost_evaluated` aca 
    ON e.icustay_id = aca.icustay_id AND e.charttime = aca.charttime
GROUP BY
    e.icustay_id, e.start_time, e.end_time



DRUG
Respiratory_Rate
Tidal_Volume
Body_Temperature
PEEP
FiO2
Serum_Creatinine
Blood_Pressure
Heart_Rate
Lactate
Glasgow_Coma_Scale_GCS
Actions
calculated_cost


start_time
end_time