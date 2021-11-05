-- Add views for versioned tables
-- depends: 20211031_01_7r83L-add-raw-data-tables

-- All hail stackoverflow
-- https://stackoverflow.com/questions/9430743/selecting-most-recent-and-specific-version-in-each-group-of-records-for-multipl
CREATE VIEW latest_risk_thresholds AS
SELECT risk_level, volume_threshold_usd FROM risk_thresholds rt1
WHERE rt1.created = (
  SELECT max(created)
  FROM risk_thresholds rt2
  WHERE rt2.risk_level = rt1.risk_level
)
LIMIT 1;

CREATE VIEW latest_country_risks AS
SELECT country, risk_level FROM country_risks rt1
WHERE rt1.created = (
  SELECT max(created)
  FROM country_risks rt2
  WHERE rt2.country = rt1.country
)
LIMIT 1;