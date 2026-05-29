# 🛒 Olist E-Commerce SQL Analysis

End-to-end SQL project covering data ingestion, cleaning, and business analysis on the **Brazilian E-Commerce Public Dataset by Olist** — a real-world dataset of ~100k orders placed on the Olist marketplace between 2016 and 2018.

---

## 📁 Dataset

The dataset is publicly available on [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and consists of 9 CSV files:

| File | Description |
|------|-------------|
| `olist_customers_dataset.csv` | Customer location and ID info |
| `olist_geolocation_dataset.csv` | Zip code latitude/longitude data |
| `olist_order_items_dataset.csv` | Items within each order, price, freight |
| `olist_order_payments_dataset.csv` | Payment type and installments |
| `olist_order_reviews_dataset.csv` | Customer review scores and comments |
| `olist_orders_dataset.csv` | Order status and timestamps |
| `olist_products_dataset.csv` | Product details and dimensions |
| `olist_sellers_dataset.csv` | Seller location info |
| `product_category_name_translation.csv` | Portuguese → English category names |

---

## 🗂️ Project Structure

```
olist_analysis.sql
│
├── Section 1 — Table Creation & Data Loading
├── Section 2 — Staging Tables
├── Section 3 — Data Cleaning
│   ├── 3a. Duplicate Detection
│   └── 3b. Null Handling
├── Section 4 — Standardization
└── Section 5 — Business Analysis Queries
```

---

## 🔧 What the SQL Does

### 1. Data Loading
Creates tables for all 9 CSV files and loads them using `LOAD DATA LOCAL INFILE`.

### 2. Staging Tables
Creates a staging copy of every table so the raw data is never modified directly.

### 3. Data Cleaning
- **Duplicate detection** using `ROW_NUMBER() OVER (PARTITION BY ...)` across all key tables
- **Null handling** — converts empty strings to proper `NULL` values in date and dimension columns

### 4. Standardization
- Converts date columns from `TEXT` to `DATETIME`
- Adds an English product category column populated via a translation table join
- Uppercases city names across customers and sellers for consistency

### 5. Business Analysis
| Query | Insight |
|-------|---------|
| Total orders & revenue | Overall business scale |
| Orders by status | Funnel health (delivered, cancelled, etc.) |
| Top 10 categories by revenue | Best-performing product segments |
| Monthly order volume | Demand trend over time |
| Average delivery time | Operational efficiency |
| Average delivery delay | On-time performance vs estimate |
| Top 10 states by orders | Geographic demand distribution |
| Avg review score by category | Customer satisfaction per segment |
| Category revenue ranking | DENSE_RANK() based revenue leaderboard |
| Running monthly revenue total | Cumulative growth via window function |
| One-time vs repeat buyers | Customer loyalty segmentation |
| Late delivery rate by state | Regional logistics performance |
| Payment method breakdown | Payment preference and installment usage |

---

## 🛠️ Tools Used

- **MySQL** (with `LOAD DATA LOCAL INFILE` for CSV ingestion)
- Standard SQL — CTEs, Window Functions, Joins, Aggregations

---

## ▶️ How to Run

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. Update the file paths in the `LOAD DATA LOCAL INFILE` statements to match your local directory
3. Run the script top to bottom in MySQL Workbench or any MySQL client
4. Make sure `SET GLOBAL local_infile = 1;` is executed before loading data

---

## 📊 Key Findings

### 🧾 Orders & Revenue
- The dataset contains **98,666 total orders** generating **~$15.84M in revenue**
- **97.8% of orders were successfully delivered** (96,478 out of 98,666), with only 625 cancellations (~0.6%)

### 🚚 Delivery Performance
- Average delivery time is **~12.5 days** from purchase to customer
- The average delivery delay vs estimated date is **-11.88 days**, meaning orders arrive nearly **12 days earlier** than the estimated date on average — a strong logistics performance signal
- Despite the overall early delivery trend, **AL (Alagoas)** has the highest late delivery rate at **23.93%**, followed by **MA (Maranhão)** at 19.67% and **PI (Piauí)** at 15.97% — all northeastern states, suggesting a regional logistics gap

### 🛍️ Product Categories
- The top 3 revenue-generating categories are **Health & Beauty** (~$1.44M), **Watches & Gifts** (~$1.31M), and **Bed, Bath & Table** (~$1.24M)

### 👥 Customer Loyalty
- **99,441 customers placed only one order**, making virtually all buyers one-time purchasers — a significant retention challenge for the platform

### 💳 Payments
- **Credit card** is the dominant payment method, used in **73.92% of orders** with an average of **3.5 installments**, reflecting a strong preference for installment-based purchasing common in the Brazilian market

---

## 👤 Author

Feel free to connect or reach out if you have questions about the project.
