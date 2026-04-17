# AgriFintech — Remote SQL Architect and Explorer

> **Course:** Aprendizaje Automático para Grandes Volúmenes de Datos
> **Teacher:** Dr. Juan Carlos López Pimentel
> **Evidence:** Homework — Remote SQL Architect and Explorer
> **University:** Universidad Panamericana
> **Authors:** Hector Manuel Eguiarte Carlos · Gabriel Zaid Gutiérrez González

A full-stack SQL Bridge for an agricultural fintech platform. Farmers and ranchers can be registered, their commodities tracked, and financial products (loans, insurance, credit lines) managed — all queryable through a custom web interface backed by a RESTful API connected to a remote PostgreSQL database.

---

## Project Structure

```
AgriFintech/
│
├── Phase A — Database Design
│   └── agrifintech_schema.sql     DDL (CREATE TABLE) + seed data (INSERT)
│
├── Phase B — API Proxy
│   ├── main.py                    FastAPI application (POST /query endpoint)
│   ├── requirements.txt           Python dependencies
│   ├── .env.example               DATABASE_URL connection string template
│   ├── render.yaml                Render.com deployment config
│   └── runtime.txt                Python version pin
│
├── Phase C — SQL Workbench UI
│   └── index.html                 Single-file web interface (no build tools)
│
└── Documentation
    ├── agrifintech_documentation.tex   Full LaTeX report
    └── img/                            Screenshots used in the report
        ├── img_swagger.png
        ├── img_wb_idle.png
        ├── img_wb_results.png
        ├── img_wb_error.png
        └── img_neon.png
```

---

## Phase A — Database Design

**Remote database:** [Neon.tech](https://neon.tech) (serverless PostgreSQL 15)

### Schema — 5 tables in 3NF

```
producers ─────────────────────────────── transactions
    │                                           │
    │ (M:N via junction)          (M:1)         │
    └──── producer_commodities        financial_products
               │
          commodities
```

| Table | Rows | Description |
|---|---|---|
| `producers` | 12 | Farmers & ranchers registered on the platform |
| `commodities` | 12 | Catalogue of crops and livestock (corn, cattle, avocado…) |
| `producer_commodities` | 14 | Junction table — which producer grows/raises what |
| `financial_products` | 11 | Loans, insurance, and credit lines |
| `transactions` | 13 | Financial operations requested by producers |

### Setup

1. Create a free project at [neon.tech](https://neon.tech)
2. Open the **SQL Editor** in the Neon dashboard
3. Paste and run `agrifintech_schema.sql`

---

## Phase B — API Proxy

**Stack:** Python · FastAPI · psycopg2 · Uvicorn  
**Deployment:** [Render.com](https://render.com) (free tier)

### Endpoint

```
POST /query
Content-Type: application/json

{ "sql": "SELECT * FROM producers LIMIT 5" }
```

**Success response:**
```json
{
  "status": "success",
  "rowCount": 5,
  "columns": ["producer_id", "full_name", "region", "producer_type"],
  "rows": [{ "producer_id": 1, "full_name": "Carlos Mendoza Ríos", ... }]
}
```

### Security — two independent layers

| Layer | Mechanism | Blocks |
|---|---|---|
| Application | Regex blocklist in `sanitize()` | `DROP`, `DELETE`, `TRUNCATE`, `ALTER`, `GRANT`, `EXEC`, `--`, `OR 1=1` |
| Database | Read-only PostgreSQL user | Any write/DDL at the engine level |

### Local setup

```bash
# 1. Create and activate a virtual environment
python -m venv venv
source venv/bin/activate        # Mac / Linux
venv\Scripts\activate           # Windows

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure the database connection
cp .env.example .env
# Edit .env and paste your Neon connection string

# 4. Run the server
uvicorn main:app --reload
# → http://127.0.0.1:8000
# → http://127.0.0.1:8000/docs  (Swagger UI)
```

### Deploy to Render

1. Push this repo to GitHub (`.env` is already in `.gitignore`)
2. Go to [render.com](https://render.com) → **New → Web Service** → connect the repo
3. Render auto-detects `render.yaml` — no extra configuration needed
4. Add `DATABASE_URL` as an environment variable in the Render dashboard
5. Deploy — your API gets a public HTTPS URL

---

## Phase C — SQL Workbench

A single-file HTML application. No build tools, no npm, no server — open `index.html` directly in any browser.

### Features

- **SQL editor** — multi-line monospace textarea with `Ctrl+Enter` shortcut
- **Quick query sidebar** — 6 preloaded queries (JOINs, aggregations, filters)
- **Dynamic results table** — renders column headers and rows from the API response
- **Status indicators** — success/error pill with row count and elapsed time
- **Connection tester** — ping the API and see a live green dot on success

### How to use

1. Open `index.html` in your browser
2. In the sidebar, enter the API URL (Render URL or `http://localhost:8000`)
3. Click **Test connection** — the dot turns green if the API is reachable
4. Pick a query from the sidebar or write your own SQL
5. Click **Execute** (or press `Ctrl+Enter`)

---

## Architecture

```
┌─────────────────────┐     HTTPS POST /query      ┌─────────────────────┐
│   SQL Workbench     │ ─────────────────────────► │   FastAPI (Render)  │
│   index.html        │                            │   main.py           │
│   Browser           │ ◄─────────────────────────  │   sanitize()        │
└─────────────────────┘       JSON rows            │   psycopg2          │
                                                   └──────────┬──────────┘
                                                              │ SSL/TCP
                                                              ▼
                                                   ┌─────────────────────┐
                                                   │  PostgreSQL (Neon)  │
                                                   │  5 tables · 3NF     │
                                                   │  read-only user     │
                                                   └─────────────────────┘
```

---

## Tech Stack

| Component | Technology |
|---|---|
| Database | PostgreSQL 15 on Neon.tech |
| API framework | FastAPI 0.115 |
| DB driver | psycopg2-binary 2.9 |
| API server | Uvicorn |
| Deployment | Render.com |
| Frontend | Vanilla HTML / CSS / JavaScript |

---

## Requirements

- Python 3.10+
- A [Neon.tech](https://neon.tech) account (free)
- A [Render.com](https://render.com) account (free, for deployment)
