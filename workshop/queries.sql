-- EXPLAIN VERBOSE
WITH active_senders AS
(
  SELECT DISTINCT sender_id
  FROM raw_transactions
  WHERE complete_timestamp BETWEEN DATE(now()) - 7 AND DATE(now())
),
aggregates AS (
  SELECT
    snd.sender_id,
    SUM(txn.amount_usd) AS low_risk_volume,
    SUM(CASE WHEN country.risk_level >= 'medium' THEN txn.amount_usd ELSE 0 END) AS medium_risk_volume,
    SUM(CASE WHEN country.risk_level >= 'high' THEN txn.amount_usd ELSE 0 END) AS high_risk_volume,
    COUNT(*) AS total_transaction_count,
    SUM(CASE WHEN txn.complete_timestamp >= (DATE(now()) - 10) THEN 1 ELSE 0 END) AS ten_day_volume,
    COUNT(DISTINCT txn.recipient_id) AS recipient_count,
    MIN(txn.complete_timestamp) AS first_complete_timestamp,
    MAX(txn.complete_timestamp) AS last_complete_timestamp
  FROM
  active_senders snd
  LEFT JOIN
  (
    SELECT
      sender_id,
      recipient_id,
      amount_usd,
      receive_country,
      complete_timestamp
    FROM raw_transactions
  ) txn
  USING (sender_id)
  LEFT JOIN latest_country_risks country
  ON txn.receive_country = country.country
  GROUP BY sender_id
)
SELECT 
  sender_id,
  ag.low_risk_volume,
  ag.medium_risk_volume,
  ag.high_risk_volume,
  COALESCE(tl.trust_level, 1) AS trust_level
FROM aggregates ag
LEFT JOIN
(
  SELECT id, trust_level FROM participant_trust_levels
) tl
ON (ag.sender_id = tl.id)
WHERE
  low_risk_volume > COALESCE(trust_level, 1) * (SELECT volume_threshold_usd FROM latest_risk_thresholds WHERE risk_level = 'low')
OR medium_risk_volume > COALESCE(trust_level, 1) * (SELECT volume_threshold_usd FROM latest_risk_thresholds WHERE 
risk_level = 'medium')
OR high_risk_volume > COALESCE(trust_level, 1) * (SELECT volume_threshold_usd FROM latest_risk_thresholds WHERE risk_level = 'high')
