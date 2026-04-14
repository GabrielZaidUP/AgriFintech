import os
import re
import psycopg2
import psycopg2.extras
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="AgriFintech SQL Bridge", version="1.0.0")

# Allow requests from any origin (your UI in Phase C)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)

# ── Request model ────────────────────────────────────────────
class QueryRequest(BaseModel):
    sql: str

# ── Sanitization ─────────────────────────────────────────────
# Blocks destructive or dangerous SQL keywords.
# The DB user on Neon should also have read-only permissions
# as a second layer of defense.
BLOCKED_PATTERNS = re.compile(
    r"\b(DROP|DELETE|TRUNCATE|ALTER|INSERT|UPDATE|GRANT|REVOKE"
    r"|EXEC|EXECUTE|xp_|sp_|--|\bOR\b\s+\b1\b\s*=\s*\b1\b)\b",
    re.IGNORECASE,
)

def sanitize(sql: str) -> str:
    sql = sql.strip()
    if not sql:
        raise HTTPException(status_code=400, detail="SQL query cannot be empty.")
    if len(sql) > 2000:
        raise HTTPException(status_code=400, detail="Query too long (max 2000 chars).")
    if BLOCKED_PATTERNS.search(sql):
        raise HTTPException(
            status_code=403,
            detail="Query contains forbidden keywords (DROP, DELETE, ALTER, etc.).",
        )
    return sql

# ── DB connection (created fresh per request for simplicity) ─
def get_connection():
    dsn = os.getenv("DATABASE_URL")
    if not dsn:
        raise HTTPException(status_code=500, detail="DATABASE_URL not configured.")
    try:
        return psycopg2.connect(dsn, connect_timeout=10)
    except psycopg2.OperationalError as e:
        raise HTTPException(status_code=503, detail=f"Database connection failed: {e}")

# ── Endpoints ────────────────────────────────────────────────
@app.get("/")
def root():
    return {"status": "ok", "message": "AgriFintech SQL Bridge is running."}

@app.post("/query")
def run_query(body: QueryRequest):
    clean_sql = sanitize(body.sql)

    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(clean_sql)

            # SELECT-like queries return rows
            if cur.description:
                rows = cur.fetchall()
                return {
                    "status": "success",
                    "rowCount": len(rows),
                    "columns": [desc[0] for desc in cur.description],
                    "rows": [dict(row) for row in rows],
                }
            # Non-SELECT (INSERT/UPDATE allowed if you remove them from blocklist)
            conn.commit()
            return {
                "status": "success",
                "rowCount": cur.rowcount,
                "columns": [],
                "rows": [],
            }

    except psycopg2.errors.SyntaxError as e:
        raise HTTPException(status_code=400, detail=f"SQL syntax error: {e}")
    except psycopg2.Error as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")
    finally:
        conn.close()
