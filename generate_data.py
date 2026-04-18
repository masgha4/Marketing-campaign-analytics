"""
generate_data.py
Generates 12 months of realistic multi-channel marketing campaign data.
Run this first before opening Excel or Tableau.
"""

import csv
import random
from datetime import date, timedelta

random.seed(7)

CHANNELS = ["Email", "Paid Search", "Social Media", "Display Ads", "Organic Search"]
CAMPAIGNS = {
    "Email":          ["Newsletter", "Drip Sequence", "Re-engagement", "Promotional Blast"],
    "Paid Search":    ["Brand Keywords", "Competitor Keywords", "Long-tail Product"],
    "Social Media":   ["LinkedIn Sponsored", "Facebook Retargeting", "Instagram Story"],
    "Display Ads":    ["Awareness Banner", "Retargeting Display"],
    "Organic Search": ["SEO Blog", "Landing Page Organic"],
}
AUDIENCES = ["New Visitors", "Returning Users", "High-Intent", "Churned Customers", "Lookalike"]

CHANNEL_PARAMS = {
    # channel: (base_impressions, base_ctr, base_conv_rate, base_cpc, base_spend)
    "Email":          (15000, 0.22, 0.035, 0,    500),
    "Paid Search":    (8000,  0.06, 0.048, 1.80, 1200),
    "Social Media":   (25000, 0.018, 0.012, 0.55, 900),
    "Display Ads":    (40000, 0.004, 0.006, 0.30, 600),
    "Organic Search": (12000, 0.045, 0.028, 0,    0),
}

rows = []
row_id = 1
start = date(2023, 1, 1)

for month_offset in range(12):
    month_start = date(start.year, start.month + month_offset
                       if start.month + month_offset <= 12
                       else start.month + month_offset - 12,
                       1)
    month_label = month_start.strftime("%B %Y")
    month_num = month_start.month

    for channel, (base_imp, base_ctr, base_conv, base_cpc, base_spend) in CHANNEL_PARAMS.items():
        for campaign in CAMPAIGNS[channel]:
            audience = random.choice(AUDIENCES)

            # Seasonal multiplier (Q4 higher, Q1 lower)
            seasonal = 1.0 + 0.3 * (month_num in [10, 11, 12]) - 0.15 * (month_num in [1, 2])
            noise = random.uniform(0.85, 1.18)

            impressions = int(base_imp * seasonal * noise * random.uniform(0.7, 1.3))
            clicks = int(impressions * base_ctr * random.uniform(0.85, 1.15))
            ctr = round(clicks / impressions * 100, 2) if impressions else 0
            conversions = int(clicks * base_conv * random.uniform(0.8, 1.2))
            conv_rate = round(conversions / clicks * 100, 2) if clicks else 0
            spend = round(base_spend * seasonal * noise * random.uniform(0.9, 1.1), 2)
            cpc = round(spend / clicks, 2) if clicks and base_cpc > 0 else 0
            revenue_generated = round(conversions * random.uniform(85, 220), 2)
            roi = round((revenue_generated - spend) / spend * 100, 1) if spend else 0

            rows.append({
                "Row_ID": row_id,
                "Month": month_label,
                "Month_Num": month_num,
                "Year": month_start.year,
                "Channel": channel,
                "Campaign": campaign,
                "Audience_Segment": audience,
                "Impressions": impressions,
                "Clicks": clicks,
                "CTR_Pct": ctr,
                "Conversions": conversions,
                "Conversion_Rate_Pct": conv_rate,
                "Spend_USD": spend,
                "CPC_USD": cpc,
                "Revenue_Generated_USD": revenue_generated,
                "ROI_Pct": roi,
            })
            row_id += 1

with open("campaign_data.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)

print(f"Generated {len(rows)} campaign records -> campaign_data.csv")

# Quick summary
total_spend = sum(r["Spend_USD"] for r in rows)
total_revenue = sum(r["Revenue_Generated_USD"] for r in rows)
total_conversions = sum(r["Conversions"] for r in rows)
print(f"Total Spend:       ${total_spend:,.2f}")
print(f"Total Revenue:     ${total_revenue:,.2f}")
print(f"Total Conversions: {total_conversions:,}")
print(f"Blended ROI:       {(total_revenue - total_spend) / total_spend * 100:.1f}%")

print("\nROI by Channel:")
by_channel = {}
for r in rows:
    ch = r["Channel"]
    by_channel.setdefault(ch, {"spend": 0, "revenue": 0})
    by_channel[ch]["spend"] += r["Spend_USD"]
    by_channel[ch]["revenue"] += r["Revenue_Generated_USD"]
for ch, v in sorted(by_channel.items(), key=lambda x: -x[1]["revenue"]):
    roi = (v["revenue"] - v["spend"]) / v["spend"] * 100 if v["spend"] else 0
    print(f"  {ch:<20} Spend: ${v['spend']:>8,.0f}  Revenue: ${v['revenue']:>9,.0f}  ROI: {roi:.0f}%")
