WITH active_senders AS (
  SELECT DISTINCT sender_id
  FROM raw_transactions
  WHERE complete_timestamp BETWEEN DATE(now()) - 7 AND DATE(now())
),
last_24_months_txns AS (
  SELECT
    sender_id,
    amount_usd,
    receive_country,
    complete_timestamp
  FROM raw_transactions
  WHERE complete_timestamp > (DATE(now()) - 730)
)
SELECT
  sender_id,
  -- txn.receive_country,
  -- country.risk_level
  COUNT(*) AS count,
  MIN(txn.complete_timestamp) AS first_txn_ts,
  MAX(txn.complete_timestamp) AS last_txn_ts,
  SUM(txn.amount_usd) AS total_volume,
  SUM(
    CASE WHEN country.risk_level >= 'low' THEN txn.amount_usd ELSE 0 END
  ) AS low_risk_volume,
  SUM(
    CASE WHEN country.risk_level >= 'medium' THEN txn.amount_usd ELSE 0 END
  ) AS medium_risk_volume,
  SUM(
    CASE WHEN country.risk_level >= 'high' THEN txn.amount_usd ELSE 0 END
  ) AS high_risk_volume
FROM
  active_senders snd
LEFT OUTER JOIN
  last_24_months_txns txn
USING (sender_id)
LEFT OUTER JOIN
  country_risks country
ON (txn.receive_country = country.country)
GROUP BY sender_id
ORDER BY sender_id
LIMIT 5
;