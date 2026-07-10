# YouTube Data Engineering Pipeline

**Work in progress** — Project 1 for the Quera Data Engineering Bootcamp (Series 8, Fall 1403): a pipeline that ingests YouTube channel and video data from PostgreSQL and MongoDB, orchestrates loading with Apache Airflow, and builds a layered (raw → silver → golden) data warehouse in ClickHouse.

> This project is not finished. This README describes what's currently implemented in the repo, not the full intended scope.

## Tech Stack

- Docker / Docker Compose
- PostgreSQL
- MongoDB
- Apache Airflow
- ClickHouse
- Metabase (service is in `docker-compose.yaml`, not yet connected/configured)

## Repository Structure

```
.
├── dags/
│   ├── insert_from_postgres.py   # Airflow DAG: Postgres -> ClickHouse (raw)
│   └── insert_from_mongo.py      # Airflow DAG: MongoDB -> ClickHouse (raw)
├── wherehouse_sql/
│   ├── data_bases.sql            # Creates raw / silver / GOLDEN databases in ClickHouse
│   ├── raw.sql                   # Raw layer table schemas
│   ├── silver_layer.sql          # Silver layer: joined channel + video events
│   ├── golden_layer.sql          # Golden layer: aggregated report tables
│   └── insert.sql                # Manual/seed inserts
├── init.sql                      # Postgres bootstrap: creates + loads `channels` table from CSV
├── docker-compose.yaml           # Airflow, Postgres, MongoDB, ClickHouse, Metabase, Redis
└── logs/                         # Airflow scheduler logs (generated at runtime)
```

## Data Model

**Raw layer** (ClickHouse `raw` database)
- `raw.postgres_storage` — channel/account metadata mirrored from Postgres `channels` table
- `raw.MONGODB_STORAGE` — video metadata mirrored from MongoDB `videos.videos` collection

**Silver layer** (ClickHouse `silver` database)
- `silver.event` — one row per video, joined with its owning channel (`userid` = `video_owner_id`), populated via a Materialized View

**Golden layer** (ClickHouse `GOLDEN` database)

| Table | Metrics | Purpose |
|---|---|---|
| `Channel_Growth` | Followers, total video visits, video count | Growth trajectory per channel |
| `TOP_PERFORM` | Highest followers, most visits, highest video count | Top 100 channels by engagement/reach |
| `video_engagement` | Visit count, like count, comments | Per-video viewer interaction (currently a plain `VIEW`, not an aggregating table) |
| `content` | Video titles, tags, visit counts | Visit counts broken down by tag |
| `geographic_distribution` | Country, followers, video visits | Regional spread of channels |

## Prerequisites

- Docker and Docker Compose
- At least 4 GB RAM and 2 CPUs available to Docker (per Airflow's recommendation)
- A `.env` file in the project root (see below)
- A `channels_export.csv` file for the initial Postgres data load
- A MongoDB dump/videos directory for `mongorestore`

## Environment Variables

Create a `.env` file in the project root:

```env
AIRFLOW_UID=50000
DB_USER=your_postgres_user
DB_PASS=your_postgres_password
DB_NAME=your_postgres_db
```

> **Note:** ClickHouse credentials (`G4_user` / `G4_pass`) and the MongoDB host are currently hardcoded in `docker-compose.yaml` and the DAG files rather than pulled from environment variables.

## Setup

1. **Clone the repo and add your `.env` file** as described above.

2. **Provide the seed data:**
   - Mount your `channels_export.csv` at the path referenced in `docker-compose.yaml` (`/root/channels/channels_export.csv` on the host) for the Postgres bulk load.
   - Mount your videos dump/export at `~/videos` on the host for MongoDB (`mongorestore`).

3. **Start the stack:**
   ```bash
   docker compose up -d
   ```
   This brings up Postgres, MongoDB, ClickHouse, Redis, Metabase, and the full Airflow cluster (webserver, scheduler, worker, triggerer).

4. **Create the ClickHouse databases and tables** — run the SQL files in `wherehouse_sql/` against your ClickHouse instance, in order:
   ```
   data_bases.sql   # creates raw / silver / GOLDEN databases
   raw.sql          # raw layer tables
   silver_layer.sql # silver layer table + materialized view
   golden_layer.sql # golden layer tables + materialized views
   ```

5. **Access the services:**
   - Airflow UI: [http://localhost:8080](http://localhost:8080) (default user/pass: `airflow` / `airflow`)
   - ClickHouse HTTP: `http://localhost:8123`
   - Metabase: [http://localhost:3000](http://localhost:3000)
   - Postgres: `localhost:5432`
   - MongoDB: `localhost:27017`

6. **Enable and trigger the DAGs** from the Airflow UI (they're paused by default):
   - `postgres_to_clickhouse`
   - `mongo_to_clickhouse_dag`

## DAGs

| DAG | Schedule | Source → Target |
|---|---|---|
| `insert_from_postgres.py` | `@daily` | Postgres `channels` → ClickHouse `raw` |
| `insert_from_mongo.py` | `@daily` | MongoDB `videos.videos` → ClickHouse `raw` |

## Known Limitations

- Table and connection names in the DAGs (e.g. `your_clickhouse_table`, `your_postgres_conn`, `your_table`) are placeholders and need real values before the DAGs will run successfully.
- Credentials are hardcoded in several places rather than stored as Airflow Connections/Variables or secrets.
- `video_engagement` is a plain `VIEW` rather than a materialized/aggregating table like the other golden-layer tables.
- Metabase is defined in `docker-compose.yaml` but not yet connected to ClickHouse or configured with dashboards.
- No automated tests yet.

## License

Apache 2.0 (inherited from the bundled Airflow `docker-compose.yaml`; adjust as needed for the rest of the project).
