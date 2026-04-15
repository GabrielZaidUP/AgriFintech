# 🌾 AgriFintech — Remote SQL Architect and Explorer

> **Course:** Aprendizaje Automático para Grandes Volúmenes de Datos
> **Teacher:** Dr. Juan Carlos López Pimentel
> **Evidence:** Homework — Remote SQL Architect and Explorer
> **University:** Universidad Panamericana

A full-stack SQL Bridge for an agricultural fintech platform. Farmers and ranchers can be registered, their commodities tracked, and financial products (loans, insurance, credit lines) managed — all queryable through a custom web interface backed by a RESTful API connected to a remote PostgreSQL database.

---

## 📁 Project Structure

```
agrifintech/
├── 📄 agrifintech_schema.sql     # Phase A — DDL + seed data (PostgreSQL)
│
├── 📂 agrifintech-api/           # Phase B — FastAPI backend
│   ├── main.py                   # API application
│   ├── requirements.txt          # Python dependencies
│   ├── .env.example              # Connection string template
│   └── render.yaml               # Render.com deployment config
│
└── 📂 agrifintech-workbench/     # Phase C — SQL Workbench UI
    └── index.html                # Single-file web interface
```

---

## 🗄️ Phase A — Database Design

**Remote database:** [Neon.tech](https://neon.tech) (serverless PostgreSQL)

### Schema — 5 tables in 3NF

```
producers ──────────────────────────────────── transactions
    │                                               │
    │  (many-to-many)              (many-to-one)   │
    └──── producer_commodities        financial_products
               │
          commodities
```

| Table | Rows | Description |
|---|---|---|
| `producers` | 12 | Farmers & ranchers registered on the platform |
| `commodities` | 10 | Catalogue of crops and livestock (corn, cattle, avocado…) |
| `producer_commodities` | 12 | Junction table — which producer grows/raises what |
| `financial_products` | 10 | Loans, insurance, and credit lines |
| `transactions` | 12 | Financial operations requested by producers |

### Setup

1. Create a free project at [neon.tech](https://neon.tech)
2. Open the **SQL Editor** in the Neon dashboard
3. Paste and run `agrifintech_schema.sql`

---

## ⚙️ Phase B — API Proxy

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
  "rows": [{ "producer_id": 1, "full_name": "Carlos Mendoza", ... }]
}
```

### Security — two independent layers

| Layer | Mechanism | Blocks |
|---|---|---|
| Application | Regex blocklist in `sanitize()` | `DROP`, `DELETE`, `TRUNCATE`, `ALTER`, `GRANT`, `EXEC`, `--`, `OR 1=1` |
| Database | Read-only PostgreSQL user | Any write/DDL operation at the engine level |

### Local setup

```bash
# 1. Enter the API folder
cd agrifintech-api

# 2. Create and activate virtual environment
python -m venv venv
source venv/bin/activate        # Mac / Linux
venv\Scripts\activate           # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure the database connection
cp .env.example .env
# Edit .env and paste your Neon connection string:
# DATABASE_URL=postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require

# 5. Run the server
uvicorn main:app --reload
# → http://127.0.0.1:8000
# → http://127.0.0.1:8000/docs  (interactive Swagger UI)
```

### Deploy to Render

1. Push this repo to GitHub (make sure `.env` is in `.gitignore`)
2. Go to [render.com](https://render.com) → **New → Web Service** → connect your repo
3. Render auto-detects `render.yaml` — no extra configuration needed
4. Add `DATABASE_URL` as an environment variable in the Render dashboard
5. Deploy → your API gets a public URL like `https://agrifintech-api.onrender.com`

---

## 🖥️ Phase C — SQL Workbench

A single-file HTML application. No build tools, no npm, no server required — just open `index.html` in your browser.

### Features

- **SQL editor** — multi-line monospace textarea with `Ctrl+Enter` shortcut
- **Quick query sidebar** — 6 preloaded queries (JOINs, aggregations, filters)
- **Dynamic results table** — renders column headers and rows from the API response
- **Status indicators** — colored success/error pill with row count and elapsed time
- **Connection tester** — ping the API and see a live green dot on success
- **NULL highlighting** — NULL values displayed in muted style, not as empty cells

### How to use

1. Open `agrifintech-workbench/index.html` in your browser
2. In the sidebar, set the API URL to your Render URL (or `http://localhost:8000`)
3. Click **Test connection** — the dot turns green if the API is reachable
4. Pick a query from the sidebar or write your own
5. Click **Execute** (or press `Ctrl+Enter`)

---

## 🏗️ Architecture

```
┌─────────────────────┐        POST /query         ┌─────────────────────┐
│   SQL Workbench     │  ─────────────────────────► │   FastAPI (Render)  │
│   index.html        │                             │   main.py           │
│   Browser           │ ◄─────────────────────────  │   sanitize()        │
└─────────────────────┘        JSON rows            │   psycopg2          │
                                                    └──────────┬──────────┘
                                                               │ SQL query
                                                               ▼
                                                    ┌─────────────────────┐
                                                    │  PostgreSQL (Neon)  │
                                                    │  5 tables · 3NF     │
                                                    │  SSL · read-only    │
                                                    └─────────────────────┘
```

---

## 🧰 Tech Stack

| Component | Technology | Why |
|---|---|---|
| Database | PostgreSQL 15 on Neon.tech | Remote, serverless, free, SSL |
| API framework | FastAPI 0.115 | Auto docs, Pydantic validation, fast |
| DB driver | psycopg2-binary 2.9 | Standard PostgreSQL adapter for Python |
| API server | Uvicorn | Lightweight ASGI, production-ready |
| Deployment | Render.com | Free tier, zero-config from GitHub |
| Frontend | Vanilla HTML/CSS/JS | No dependencies, runs anywhere |

---

## 📋 Requirements

- Python 3.10+
- A [Neon.tech](https://neon.tech) account (free)
- A [Render.com](https://render.com) account (free) — for deployment only

---

## 📄 License
Gabriel Zaid Gutierrez Gonzalez
Academic project — Universidad Panamericana · 2026
