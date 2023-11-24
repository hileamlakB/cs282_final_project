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

-- how do we want to group the diseases
-- and how do we find the price data for all these
