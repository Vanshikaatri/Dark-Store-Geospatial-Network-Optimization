# Business Analysis Document
## Dark Store Network Optimization — Quick Commerce India
**Author:** Vanshika | **Date:** June 2025 | **Domain:** Quick Commerce Operations

---

## 1. Executive Summary

This analysis evaluates the geospatial efficiency of quick commerce dark store networks operated by Blinkit, Zepto, and Swiggy Instamart across Bengaluru, Mumbai, and Delhi NCR.

**Core finding:** The current network delivers 99.9% of orders within 10 minutes in dense urban cores. However, three peripheral zones — Greater Noida, Whitefield (Bengaluru), and Thane West (Mumbai) — show measurable coverage gaps where store placement optimization could reduce average delivery distance by up to 12% while capturing underserved demand.

**Business recommendation:** Prioritize new store placement in Greater Noida and Whitefield before adding capacity to already-saturated zones like Koramangala (55.8% cannibalization rate).

---

## 2. Problem Statement

### 2.1 Business Context
Quick commerce operates on a 10-minute delivery promise. Fulfilling this profitably requires:
- Dark stores within ~2km of delivery addresses (at avg urban speed of 15 km/h)
- Stores placed where order density is high — not just where real estate is available
- No two stores so close that they split the same customer base without adding coverage

### 2.2 Analytical Questions
1. Are current store locations optimal relative to actual order distribution?
2. Which zones have high demand but insufficient store coverage?
3. What is the cannibalization risk in high-density zones?
4. How sensitive is delivery performance to small changes in store location?

---

## 3. Data Overview

| Dataset | Source | Size | Key Fields |
|---|---|---|---|
| Delivery orders | Synthetically generated from real neighbourhood coordinates | 501,000 rows | order_id, city, area, delivery_lat, delivery_lng, brand, order_value_inr, timestamp |
| Dark stores | Real store locations (Blinkit, Zepto, Swiggy Instamart) | 52 rows | store_id, brand, city, area, lat, lng |
| Zone statistics | Aggregated from order data | 35 rows | zone KPIs, opportunity score, coverage metrics |

**Data generation methodology:** Delivery addresses were generated using real ward-level coordinates for each city, weighted by population density. Order values follow a log-normal distribution (mean ₹374, range ₹99–₹2,500) consistent with industry-reported quick commerce AOV.

---

## 4. Key Metrics Defined

| Metric | Definition | Threshold |
|---|---|---|
| Delivery distance | Haversine distance from delivery address to nearest store | Target: <2km |
| Estimated delivery time | (distance / 15 km/h) × 60 + 3 min pick time | SLA: ≤10 min |
| Coverage rate | % of orders with est. delivery ≤10 min | Target: >95% |
| Opportunity score | avg_delivery_dist × log(1 + order_count) | Higher = more urgent expansion |
| Cannibalization risk | % of orders within 2km of 2+ stores | High: >40% |
| K-Means displacement | Distance between optimal centroid and actual store | Flag if >0.5km |

---

## 5. Findings

### 5.1 Overall Network Performance

The three-city network achieves strong core coverage:

- **Average delivery distance:** 0.437 km across 501K orders
- **10-minute SLA achievement:** 99.9% of all orders
- **City breakdown:**
  - Mumbai: 0.38 km avg — best coverage (compact geography, dense store network)
  - Delhi NCR: 0.45 km avg
  - Bengaluru: 0.48 km avg — most spread out due to city's dispersed layout

### 5.2 Cannibalization Risk (Koramangala Problem)

Bengaluru shows the highest overlap risk in the network:
- **55.8%** of Bengaluru orders are within 2km of two or more stores
- This compares to 29.0% in Mumbai and 23.6% in Delhi NCR
- Koramangala alone has 3 brand stores within a 1.5km radius

**Implication:** Adding more stores in Koramangala adds cost without adding coverage. Investment should shift to peripheral zones.

### 5.3 Underserved Zones (Expansion Opportunities)

Top 5 zones by opportunity score:

| Zone | City | Orders | Avg Distance | Opportunity Score |
|---|---|---|---|---|
| Greater Noida | Delhi NCR | 14,815 | 0.75 km | 7.20 |
| Whitefield | Bengaluru | 13,456 | 0.75 km | 7.13 |
| Yelahanka | Bengaluru | 8,233 | 0.69 km | 6.22 |
| Thane West | Mumbai | 13,594 | 0.63 km | 6.00 |
| Electronic City | Bengaluru | 11,704 | 0.63 km | 5.90 |

These are not remote areas — they generate 10K–15K orders each. They're underserved because expansion has prioritised core zones.

### 5.4 K-Means Optimization Gap

Running K-Means with k = current store count per city and comparing centroids to actual positions:
- Maximum displacement from optimal: **0.545 km** (Bengaluru)
- Average displacement across all 52 stores: **0.28 km**
- All stores are within 0.6km of their mathematical optimum

**Implication:** Current placement is efficient within dense zones. The real gap is not store misplacement — it's missing stores in peripheral high-demand areas (finding corroborated by opportunity score analysis).

### 5.5 Location Sensitivity — 500m Shift Simulation

Testing BLR_BL_001 (Koramangala Blinkit):

| Scenario | Avg Distance | Change |
|---|---|---|
| Baseline (current) | 0.333 km | — |
| Shift North 500m | 0.568 km | +0.235 km |
| Shift South 500m | 0.592 km | +0.259 km |
| Shift East 500m | 0.589 km | +0.257 km |
| Shift West 500m | 0.637 km | +0.304 km |

A 500m westward shift increases average delivery distance by **91%** for that store's catchment. This quantifies why lease decisions for dark stores require geospatial validation — a "reasonable" location can meaningfully hurt performance.

### 5.6 Peak Demand Pattern

- **Evening peak (7–10pm):** Highest order volume — 28% of daily orders in 3 hours
- **Morning peak (8–10am):** 15% of daily orders — breakfast and grocery runs
- **Dead window (1–5am):** <3% of daily orders
- **Weekend vs weekday:** Weekends show 12–15% higher order volumes

**Operational implication:** Staffing and inventory replenishment cycles should align with the evening peak, not be uniform across hours.

---

## 6. Recommendations

### Immediate (0–3 months)
1. **Open store in Greater Noida:** Highest opportunity score (7.20), 14,815 orders/month with 0.75km avg distance. A single store would bring coverage inline with core zones.
2. **Open store in Whitefield (Bengaluru):** 13,456 orders/month, tech hub demographics with high AOV potential.

### Medium-term (3–6 months)
3. **Freeze new store openings in Koramangala and Bandra:** Cannibalization rate too high. New openings will hurt contribution margin without incrementally improving coverage.
4. **Repurpose lease review in Thane West:** Current 0.63km avg distance is serviceable but not excellent — evaluate if existing store is in optimal sub-location.

### Analytical (ongoing)
5. **Implement live opportunity score monitoring:** Rebuild this model monthly with fresh order data. Peripheral zones become high-priority zones as density grows.
6. **Add road network distance:** Current model uses straight-line Haversine. OSMnx integration would give actual drive-time estimates — more accurate for SLA modelling.

---

## 7. Limitations & Assumptions

| Assumption | Impact if wrong |
|---|---|
| Delivery speed = 15 km/h constant | Real speed varies by traffic, time of day. Peak hour times would be higher. |
| Order volume = uniform across months | Seasonality not modelled. Festive months likely spike 20–30%. |
| Store capacity = unlimited | In reality, store throughput has an order/hour ceiling. Overloaded stores breach SLA even at short distances. |
| Brand-neutral assignment | Model assigns each order to the nearest store of any brand. Real users are brand-loyal — competitive dynamics are simplified. |

---

## 8. Tools & Methodology

| Phase | Tool | Method |
|---|---|---|
| Data generation | Python (NumPy, Pandas) | Population-weighted Gaussian spread around real coordinates |
| Distance computation | Python (NumPy broadcasting) | Haversine formula, vectorized across 501K × 52 pairs |
| Optimization | Scikit-learn KMeans | k = current store count, n_init=10, random_state=42 |
| Simulation | Python | Coordinate translation using degree-km conversion |
| Querying | SQLite | 10 analytical queries including window functions, CASE aggregations |
| Visualization | Folium + Tableau Public | Interactive map + 5-chart KPI dashboard |

---

*This document is part of a portfolio project demonstrating geospatial analytics applied to quick commerce operations.*
