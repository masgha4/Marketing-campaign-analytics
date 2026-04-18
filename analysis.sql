-- ============================================================
-- Marketing Campaign Analytics — SQL Analysis
-- Tool: SQLite / PostgreSQL / any SQL engine
-- Data: campaign_data.csv (load into table called `campaigns`)
-- ============================================================

-- ── 1. CHANNEL PERFORMANCE OVERVIEW ─────────────────────
-- The top-level view: which channels are worth the spend?
SELECT
    Channel,
    SUM(Impressions)                                            AS total_impressions,
    SUM(Clicks)                                                 AS total_clicks,
    ROUND(AVG(CTR_Pct), 2)                                      AS avg_ctr_pct,
    SUM(Conversions)                                            AS total_conversions,
    ROUND(AVG(Conversion_Rate_Pct), 2)                          AS avg_conv_rate_pct,
    ROUND(SUM(Spend_USD), 2)                                    AS total_spend,
    ROUND(SUM(Revenue_Generated_USD), 2)                        AS total_revenue,
    ROUND((SUM(Revenue_Generated_USD) - SUM(Spend_USD))
          / NULLIF(SUM(Spend_USD), 0) * 100, 1)                 AS roi_pct
FROM campaigns
GROUP BY Channel
ORDER BY roi_pct DESC;


-- ── 2. MONTH-OVER-MONTH TREND ────────────────────────────
-- Are we growing? Track spend vs revenue over 12 months.
SELECT
    Month,
    Month_Num,
    ROUND(SUM(Spend_USD), 2)            AS monthly_spend,
    ROUND(SUM(Revenue_Generated_USD), 2) AS monthly_revenue,
    SUM(Conversions)                    AS monthly_conversions,
    ROUND(AVG(CTR_Pct), 2)              AS avg_ctr
FROM campaigns
GROUP BY Month, Month_Num
ORDER BY Month_Num;


-- ── 3. BEST PERFORMING CAMPAIGNS ────────────────────────
-- Which specific campaigns drive the highest ROI?
SELECT
    Channel,
    Campaign,
    SUM(Conversions)                                             AS total_conversions,
    ROUND(SUM(Spend_USD), 2)                                     AS total_spend,
    ROUND(SUM(Revenue_Generated_USD), 2)                         AS total_revenue,
    ROUND((SUM(Revenue_Generated_USD) - SUM(Spend_USD))
          / NULLIF(SUM(Spend_USD), 0) * 100, 1)                  AS roi_pct
FROM campaigns
WHERE Spend_USD > 0
GROUP BY Channel, Campaign
ORDER BY roi_pct DESC
LIMIT 10;


-- ── 4. AUDIENCE SEGMENT ANALYSIS ────────────────────────
-- Which audience converts best?
SELECT
    Audience_Segment,
    SUM(Impressions)                    AS total_impressions,
    SUM(Conversions)                    AS total_conversions,
    ROUND(AVG(Conversion_Rate_Pct), 2)  AS avg_conv_rate,
    ROUND(SUM(Revenue_Generated_USD), 2) AS total_revenue
FROM campaigns
GROUP BY Audience_Segment
ORDER BY avg_conv_rate DESC;


-- ── 5. EMAIL vs PAID SEARCH DEEP DIVE ───────────────────
-- These two drive the most revenue — compare head to head
SELECT
    Channel,
    ROUND(AVG(CTR_Pct), 2)              AS avg_ctr,
    ROUND(AVG(Conversion_Rate_Pct), 2)  AS avg_conv_rate,
    ROUND(SUM(Revenue_Generated_USD) / NULLIF(SUM(Conversions), 0), 2) AS revenue_per_conversion,
    ROUND(SUM(Spend_USD) / NULLIF(SUM(Conversions), 0), 2)             AS cost_per_conversion
FROM campaigns
WHERE Channel IN ('Email', 'Paid Search')
GROUP BY Channel;


-- ── 6. CHANNELS TO CUT (Negative ROI) ───────────────────
-- Which channels are losing money?
SELECT
    Channel,
    ROUND(SUM(Spend_USD), 2)                                    AS total_spend,
    ROUND(SUM(Revenue_Generated_USD), 2)                        AS total_revenue,
    ROUND(SUM(Revenue_Generated_USD) - SUM(Spend_USD), 2)       AS net_profit_loss,
    ROUND((SUM(Revenue_Generated_USD) - SUM(Spend_USD))
          / NULLIF(SUM(Spend_USD), 0) * 100, 1)                  AS roi_pct
FROM campaigns
GROUP BY Channel
HAVING roi_pct < 0
ORDER BY roi_pct ASC;


-- ── 7. Q4 SEASONAL LIFT ──────────────────────────────────
-- Does Q4 (Oct–Dec) outperform the rest of the year?
SELECT
    CASE WHEN Month_Num IN (10, 11, 12) THEN 'Q4 (Oct-Dec)'
         ELSE 'Rest of Year' END         AS period,
    ROUND(AVG(CTR_Pct), 2)              AS avg_ctr,
    ROUND(AVG(Conversion_Rate_Pct), 2)  AS avg_conv_rate,
    ROUND(SUM(Revenue_Generated_USD), 2) AS total_revenue,
    ROUND(SUM(Spend_USD), 2)            AS total_spend
FROM campaigns
GROUP BY period;
