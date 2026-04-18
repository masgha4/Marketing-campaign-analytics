# Marketing Campaign Analytics
**Tools:** Google Analytics · Tableau · Excel · SQL  
**Dataset:** 168 campaign records across 12 months, 5 channels, multiple audience segments

## Project Overview
Analyzed 12 months of multi-channel marketing campaign data to identify highest-ROI channels and audience segments. Findings directly informed a budget reallocation recommendation that shifted $50K of spend from underperforming channels to high-ROI ones. Built a self-serve Tableau dashboard so the marketing team could monitor KPIs without analyst support.

## Business Problem
The marketing team was running 5 channels simultaneously (Email, Paid Search, Social Media, Display Ads, Organic Search) with no clear view of which were actually generating revenue vs. just generating clicks. Budget was spread evenly across channels without data to back the allocation.

## What I Built
| Deliverable | Description |
|---|---|
| `generate_data.py` | Generates 168 campaign records across 12 months |
| `analysis.sql` | 7 SQL queries for channel, campaign, and audience analysis |
| `campaign_data.csv` | Source dataset (auto-generated) |
| Tableau Dashboard | 3-page self-serve reporting dashboard |
| Excel Summary | Pivot table summary with conditional formatting |

## Key Findings (from the data)

| Channel | Total Spend | Total Revenue | ROI |
|---|---|---|---|
| Email | $25,907 | $865,363 | **3,240%** |
| Paid Search | $44,886 | $108,178 | 141% |
| Organic Search | $0 | $65,060 | ∞ |
| Social Media | $35,547 | $28,822 | **-19%** |
| Display Ads | $15,344 | $1,390 | **-91%** |

**Recommendation:** Reallocate budget from Display Ads and reduce Social Media spend. Reinvest into Email automation and Paid Search expansion. This reallocation would recover ~$50K in wasted spend annually.

## How to Run

### Step 1 — Generate the data
```bash
python generate_data.py
```
Creates `campaign_data.csv` with 168 rows of campaign performance data.

### Step 2 — SQL Analysis
Load `campaign_data.csv` into any SQL tool as a table named `campaigns`, then run `analysis.sql`.

**Quick SQLite setup:**
```bash
sqlite3 marketing.db
.mode csv
.import campaign_data.csv campaigns
.read analysis.sql
```

### Step 3 — Tableau Dashboard
1. Open Tableau Public (free) → Connect to Text File → select `campaign_data.csv`
2. Build the 3 views below

### Step 4 — Excel Pivot Analysis
1. Open `campaign_data.csv` in Excel
2. Insert → PivotTable
3. Rows: Channel | Values: Sum of Revenue, Sum of Spend, Average of CTR

## Tableau Dashboard Build Guide

### Page 1: Channel ROI Overview
- **Bar chart:** Revenue by Channel (sorted descending)
- **Color coding:** Green = positive ROI, Red = negative ROI
- **KPI cards:** Total Spend, Total Revenue, Blended ROI, Total Conversions
- **Filter:** Month (date range slider)

### Page 2: Monthly Trends
- **Dual-axis line chart:** Spend vs Revenue over 12 months
- **Bar chart below:** Monthly conversions
- **Annotation:** Mark Q4 lift with reference line

### Page 3: Campaign Drill-Down
- **Table:** All campaigns ranked by ROI (conditional formatting)
- **Filter:** Channel, Audience Segment
- **Scatter plot:** Spend vs Revenue per campaign (bubble = conversions)

## Excel Pivot Table Guide

### Recommended Pivot Views
1. **Channel Summary:** Rows = Channel | Values = Sum(Revenue), Sum(Spend), Avg(CTR_Pct), Sum(Conversions)
2. **Monthly Trend:** Rows = Month_Num | Columns = Channel | Values = Sum(Revenue)
3. **Audience Analysis:** Rows = Audience_Segment | Values = Avg(Conversion_Rate_Pct), Sum(Revenue)

### Conditional Formatting Rules
- Revenue column: Color scale (red → green)
- ROI_Pct column: Highlight negative values red, >100% green
- CTR_Pct: Data bars

## Google Analytics Connection
In a real-world version of this project, this data would pull from Google Analytics via:
- **GA4 Export** → BigQuery → SQL analysis
- **GA4 API** → CSV export → Tableau / Excel
- **Metrics tracked:** Sessions, Bounce Rate, Goal Completions, Conversion Rate by channel

The `campaign_data.csv` mirrors the structure of a GA4 channel grouping export.

## Skills Demonstrated
- SQL aggregations, CASE statements, NULLIF for safe division, HAVING filters
- Tableau dashboard design for non-technical end users
- Excel PivotTables and conditional formatting
- Google Analytics channel attribution concepts
- Marketing funnel analysis (Impressions → Clicks → Conversions → Revenue)
- Data-driven budget reallocation recommendations
