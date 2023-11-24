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
