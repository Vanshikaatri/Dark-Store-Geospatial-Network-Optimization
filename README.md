# Dark Store Geospatial Network Optimization
### Quick Commerce Analytics — Blinkit · Zepto · Swiggy Instamart

![Python](https://img.shields.io/badge/Python-3.10-blue) ![SQL](https://img.shields.io/badge/SQL-SQLite-lightgrey) ![Tableau](https://img.shields.io/badge/Tableau-Public-orange) ![Folium](https://img.shields.io/badge/Maps-Folium-green)

---

## The Business Problem

Quick commerce profitability depends on one constraint: deliver in under 10 minutes.

That constraint is entirely determined by one decision: **where you place your dark stores**.

Place them too close together and you cannibalize your own orders. Place them too far from demand clusters and you breach your delivery SLA.

This project answers: *Are Blinkit, Zepto, and Swiggy Instamart's dark stores in Bengaluru, Mumbai, and Delhi NCR placed optimally — and where should the next stores open?*

---

## Key Findings

| Metric | Value |
|---|---|
| Total orders analysed | 501,000 |
| Cities covered | 3 (Bengaluru, Mumbai, Delhi NCR) |
| Dark stores mapped | 52 across 3 brands |
| Network avg delivery distance | 0.437 km |
| Orders deliverable in ≤10 min | 99.9% |
| Revenue modelled | ₹18.7 Cr |
| Bengaluru cannibalization risk | 55.8% of orders within 2km of 2+ stores |
| Top expansion zone | Greater Noida (Delhi NCR) — opportunity score 7.20 |
| K-Means max displacement | 0.545 km from actual store positions |

---

## What the Analysis Does

**1. Haversine Distance Mapping**
Calculates real-world km (not straight-line) from every delivery address to its nearest dark store. Accounts for Earth's curvature — standard for geo analytics.

**2. K-Means Store Placement Optimization**
Runs clustering with k = current store count per city. Compares mathematically optimal positions (centroids) to actual store locations. Max displacement: 0.545 km — meaning current placement is close to optimal in dense zones, but peripheral areas like Greater Noida and Whitefield show meaningful gaps.

**3. 500m Shift Simulation**
Moves Koramangala Blinkit (BLR_BL_001) 500m in each direction. Westward shift increases avg delivery distance by 0.304 km — quantifying the cost of a seemingly small location decision.

**4. Underserved Zone Detection**
Scores all 35 zones on `opportunity_score = avg_distance × log(order_volume)`. Top 5 zones by score are all peripheral (Whitefield, Greater Noida, Thane West, Yelahanka, Electronic City) — not yet saturated, high order volume.

**5. Cannibalization Analysis**
55.8% of Bengaluru orders sit within 2km of 2+ stores (vs 23.6% in Delhi NCR). Bengaluru's network is overbuilt in core zones; peripheral zones are underserved.

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Python (NumPy, Pandas) | Data generation, vectorized distance computation |
| Scikit-learn (KMeans) | Optimal store placement clustering |
| Folium + HeatMap plugin | Interactive geospatial map |
| SQLite + SQL | Analytical queries, store load analysis, SLA monitoring |
| Tableau Public | KPI dashboard, demand heatmap, zone opportunity matrix |
| Jupyter Notebook | End-to-end documented analysis |

---

## Project Structure

```
dark_store_project/
│
├── dark_store_project.ipynb      # Main analysis notebook (run this)
│
├── data/
│   ├── raw/
│   │   ├── orders_master.csv     # 501K synthetic orders (generated)
│   │   └── dark_stores.csv       # 52 real store coordinates
│   └── processed/
│       ├── orders_with_distances.csv   # Orders enriched with delivery metrics
│       ├── zone_stats.csv              # 35 zones with KPIs + opportunity scores
│       ├── underserved_zones.csv       # Expansion opportunity zones
│       ├── kmeans_centroids.csv        # Optimal store positions (K-Means)
│       └── shift_simulation.csv        # 500m shift what-if analysis
│
├── sql/
│   └── dark_store_analysis.sql   # 10 analytical queries (run in DB Browser)
│
└── outputs/
    ├── dark_store_map.html        # Interactive Folium map (portfolio link)
    ├── analysis_charts.png        # 4-chart summary image
    └── tableau_exports/           # 7 CSVs for Tableau dashboard
```

---

## How to Run

**Requirements**
```bash
pip install pandas numpy scikit-learn folium matplotlib seaborn faker jupyter
```

**Run the notebook**
```bash
jupyter notebook dark_store_project.ipynb
```
Run cells in order (Shift+Enter). Full run time: ~3 minutes.

**SQL queries**
1. Download DB Browser for SQLite: https://sqlitebrowser.org/
2. Import `orders_with_distances.csv`, `dark_stores.csv`, `zone_stats.csv`
3. Open `sql/dark_store_analysis.sql` and run queries

---

## Live Outputs

- 🗺️ **Interactive Map:** [Link to your Folium map on GitHub Pages]
- 📊 **Tableau Dashboard:** [Link to your Tableau Public dashboard]

---

## Dataset Note

Order data is synthetically generated using real Indian neighbourhood coordinates weighted by population density. Dark store locations are based on real Blinkit, Zepto, and Swiggy Instamart presence in each city. The methodology mirrors how a real ops analytics team would model network performance from internal order logs.

---

## About

Built as a portfolio project targeting data analyst and operations roles in quick commerce.
Focus: translating geospatial data into network optimization decisions — not just visualization.

**Vanshika | B.Tech Computer Science | LPU 2026**
