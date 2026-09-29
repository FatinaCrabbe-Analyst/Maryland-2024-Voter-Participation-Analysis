-- Maryland 2024 Voter Participation Analysis
-- Validation Queries
-- Tool: BigQuery

-- =========================================================
-- 1. Validate voter registration row count
-- =========================================================

-- 🔎 Validation Query
SELECT
  COUNT(*) AS total_rows
FROM `enduring-lane-484402-k7.project_2_civic_data.voter_registration_2024`;


-- =========================================================
-- 2. Check county uniqueness
-- =========================================================

-- 🔎 Validation Query
SELECT
  COUNT(DISTINCT County) AS distinct_counties
FROM `enduring-lane-484402-k7.project_2_civic_data.voter_registration_2024`;


-- =========================================================
-- 3. Check the statewide TOTAL row
-- =========================================================

-- 🔎 Validation Query
SELECT
  County,
  TOTAL
FROM `enduring-lane-484402-k7.project_2_civic_data.voter_registration_2024`
WHERE County = 'TOTAL';
-- =========================================================
-- 4. Validate election results precinct coverage
-- =========================================================

-- 🔎 Validation Query
SELECT
  COUNT(DISTINCT CONCAT(
    `County Name`, '-',
    `Election District - Precinct`
  )) AS election_results_precincts
FROM `enduring-lane-484402-k7.project_2_civic_data.election_results_2024`;
-- =========================================================
-- 5. Validate precinct reference coverage
-- =========================================================

-- 🔎 Validation Query
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT POLL_PLACE_ID) AS distinct_polling_places,
  COUNT(DISTINCT CONCAT(
    COUNTY_NAME, '-',
    CAST(ED_PRECINCT AS STRING)
  )) AS distinct_county_precincts
FROM `enduring-lane-484402-k7.project_2_civic_data.precinct_reference_2024`;
-- =========================================================
-- 6. Validate county-name matching between datasets
-- =========================================================

-- 🔎 Validation Query
SELECT DISTINCT
  er.`County Name` AS election_county,
  vr.County AS registration_county
FROM `enduring-lane-484402-k7.project_2_civic_data.election_results_2024` er
FULL OUTER JOIN `enduring-lane-484402-k7.project_2_civic_data.voter_registration_2024` vr
  ON er.`County Name` = vr.County
WHERE er.`County Name` IS NULL
   OR vr.County IS NULL;
-- =========================================================
-- 7. Validate normalized county-name matching
-- =========================================================

-- 🔎 Validation Query
SELECT DISTINCT
  er.`County Name` AS election_county,
  vr.County AS registration_county
FROM `enduring-lane-484402-k7.project_2_civic_data.election_results_2024` er
FULL OUTER JOIN `enduring-lane-484402-k7.project_2_civic_data.voter_registration_2024` vr
  ON REPLACE(er.`County Name`, ' County', '') = vr.County
WHERE er.`County Name` IS NULL
   OR vr.County IS NULL;
-- =========================================================
-- 8. Validate final county matching logic
-- =========================================================

-- 🔎 Validation Query
SELECT
  COUNT(DISTINCT vr.County) AS matched_counties
FROM `enduring-lane-484402-k7.project_2_civic_data.voter_registration_2024` vr
JOIN `enduring-lane-484402-k7.project_2_civic_data.election_results_2024` er
  ON CASE
       WHEN er.`County Name` = 'Baltimore County'
         THEN 'Baltimore County'
       ELSE REPLACE(er.`County Name`, ' County', '')
     END = vr.County
WHERE vr.County != 'TOTAL';
-- =========================================================
-- 9. Validate election-to-precinct reference matching
-- =========================================================

-- 🔎 Validation Query
SELECT
  COUNT(DISTINCT CONCAT(
    er.`County Name`, '-',
    er.`Election District - Precinct`
  )) AS election_precincts,
  COUNT(DISTINCT CONCAT(
    pr.COUNTY_NAME, '-',
    CAST(pr.ED_PRECINCT AS STRING)
  )) AS reference_precincts
FROM `enduring-lane-484402-k7.project_2_civic_data.election_results_2024` er
LEFT JOIN `enduring-lane-484402-k7.project_2_civic_data.precinct_reference_2024` pr
  ON er.`County Name` = pr.COUNTY_NAME
  AND CAST(REPLACE(
    er.`Election District - Precinct`, '-', ''
  ) AS INT64) = pr.ED_PRECINCT;
-- =========================================================
-- 10. Calculate presidential participation rate by jurisdiction
-- =========================================================

-- 📊 Analysis Query
WITH county_votes AS (
  SELECT
    CASE
      WHEN `County Name` = 'Baltimore County'
        THEN 'Baltimore County'
      ELSE REPLACE(`County Name`, ' County', '')
    END AS county,
    SUM(
      COALESCE(`Early Votes`, 0) +
      COALESCE(`Election Night Votes`, 0) +
      COALESCE(`Mail-In Ballot 1 Votes`, 0) +
      COALESCE(`Provisional Votes`, 0) +
      COALESCE(`Mail-In Ballot 2 Votes`, 0)
    ) AS votes_cast
  FROM `enduring-lane-484402-k7.project_2_civic_data.election_results_2024`
  WHERE `Office Name` = 'President - Vice Pres'
  GROUP BY county
),
county_registration AS (
  SELECT
    County AS county,
    TOTAL AS eligible_active_voters
  FROM `enduring-lane-484402-k7.project_2_civic_data.voter_registration_2024`
  WHERE County != 'TOTAL'
)
SELECT
  cv.county,
  cv.votes_cast,
  cr.eligible_active_voters,
  ROUND(
    cv.votes_cast / cr.eligible_active_voters * 100,
    2
  ) AS participation_rate
FROM county_votes cv
JOIN county_registration cr
  ON cv.county = cr.county
ORDER BY participation_rate DESC;
-- =========================================================
-- 11. Examine jurisdiction size versus participation rate
-- =========================================================

-- 📊 Analysis Query
WITH county_participation AS (
  SELECT
    cv.county,
    cv.votes_cast,
    cr.eligible_active_voters,
    cv.votes_cast / cr.eligible_active_voters * 100
      AS participation_rate
  FROM (
    SELECT
      CASE
        WHEN `County Name` = 'Baltimore County'
          THEN 'Baltimore County'
        ELSE REPLACE(`County Name`, ' County', '')
      END AS county,
      SUM(
        COALESCE(`Early Votes`, 0) +
        COALESCE(`Election Night Votes`, 0) +
        COALESCE(`Mail-In Ballot 1 Votes`, 0) +
        COALESCE(`Provisional Votes`, 0) +
        COALESCE(`Mail-In Ballot 2 Votes`, 0)
      ) AS votes_cast
    FROM `enduring-lane-484402-k7.project_2_civic_data.election_results_2024`
    WHERE `Office Name` = 'President - Vice Pres'
    GROUP BY county
  ) cv
  JOIN (
    SELECT
      County AS county,
      TOTAL AS eligible_active_voters
    FROM `enduring-lane-484402-k7.project_2_civic_data.voter_registration_2024`
    WHERE County != 'TOTAL'
  ) cr
  ON cv.county = cr.county
)
SELECT
  CORR(eligible_active_voters, participation_rate)
    AS size_participation_correlation
FROM county_participation;
-- =========================================================
-- 12. Analyze presidential voting methods by jurisdiction
-- =========================================================

-- 📊 Analysis Query
SELECT
  `County Name`,
  SUM(COALESCE(`Early Votes`, 0)) AS early_votes,
  SUM(COALESCE(`Election Night Votes`, 0)) AS election_night_votes,
  SUM(COALESCE(`Mail-In Ballot 1 Votes`, 0)) AS mail_in_ballot_1,
  SUM(COALESCE(`Mail-In Ballot 2 Votes`, 0)) AS mail_in_ballot_2,
  SUM(COALESCE(`Provisional Votes`, 0)) AS provisional_votes
FROM `enduring-lane-484402-k7.project_2_civic_data.election_results_2024`
WHERE `Office Name` = 'President - Vice Pres'
GROUP BY `County Name`
ORDER BY `County Name`;
