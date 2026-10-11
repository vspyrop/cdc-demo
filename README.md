# PostgreSQL CDC to Iceberg demo

A local, dockerized CDC pipeline:

```text
synthetic generator -> PostgreSQL -> Debezium -> Kafka -> Iceberg Kafka Connect sink -> Iceberg/Parquet on MinIO
```

The Iceberg REST catalog stores table metadata in a local SQLite catalog database. PostgreSQL, Kafka, MinIO, and catalog state use named Docker volumes, so the pipeline can be stopped and restarted without losing its offsets or CDC history. Trino queries the Iceberg tables; PostgreSQL can be queried directly with `psql`.

## Start

Requires Docker Desktop with Docker Compose v2.

```sh
docker compose up --build -d
```

The first startup builds the MinIO server and Apache Iceberg Kafka Connect plugin from pinned upstream source tags and can take several minutes. Once the build completes, the generator inserts a new order every two seconds and periodically updates and deletes orders. Debezium snapshots the initial table and streams subsequent changes; the Iceberg sink commits every five seconds.

Check service and connector status:

```sh
docker compose ps
curl -s http://localhost:8083/connectors
curl -s http://localhost:8083/connectors/postgres-source/status
curl -s http://localhost:8083/connectors/iceberg-sink/status
```

## Query PostgreSQL

Open an interactive `psql` session:

```sh
docker compose exec postgres psql -U demo -d demo
```

For example:

```sql
SELECT * FROM public.orders ORDER BY id DESC LIMIT 10;
```

## Query Iceberg

The Iceberg sink preserves the CDC event log (including deletes) in `iceberg.demo.orders`. Inspect individual operations with:

```sql
SELECT id, status, _cdc.op, _cdc.offset
FROM iceberg.demo.orders
ORDER BY _cdc.offset DESC
LIMIT 20;
```

To query the current row state after applying updates and deletes, select the latest CDC event per ID and filter out delete events. The demo keeps the source topic at one partition so its Kafka offsets provide an unambiguous event order:

```sh
docker compose exec trino trino --server http://localhost:8080
```

Then query:

```sql
SHOW SCHEMAS FROM iceberg;
WITH latest_change AS (
    SELECT id, customer_name, amount, status, created_at, updated_at,
           _cdc.op AS op,
           row_number() OVER (PARTITION BY id ORDER BY _cdc.offset DESC) AS row_num
    FROM iceberg.demo.orders
)
SELECT id, customer_name, amount, status, created_at, updated_at
FROM latest_change
WHERE row_num = 1 AND op <> 'D'
ORDER BY id DESC
LIMIT 10;
```

Or run a one-off query from the host:

```sh
docker compose exec trino trino --server http://localhost:8080 \
  --execute "WITH latest_change AS (SELECT id, customer_name, amount, status, _cdc.op AS op, row_number() OVER (PARTITION BY id ORDER BY _cdc.offset DESC) AS row_num FROM iceberg.demo.orders) SELECT id, customer_name, amount, status FROM latest_change WHERE row_num = 1 AND op <> 'D' ORDER BY id DESC LIMIT 10"
```

Trino's web UI is available at <http://localhost:8080>. MinIO's console is at <http://localhost:9001> (user `demo`, password `demo-secret`); the warehouse bucket is `warehouse`.

## Stop and reset

Stop the containers but keep their data:

```sh
docker compose down
```

Remove the demo's PostgreSQL, MinIO, and catalog data too:

```sh
docker compose down -v
```

All credentials and exposed ports in this compose project are for local demonstration only. Do not expose the services or reuse these credentials in a real deployment.

## License and third-party software

The original demo files are licensed under the [MIT License](./LICENSE), copyright 2026 Vasilis Spyropoulos. Software pulled or built by Docker is not covered by that license; see [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md) for the main components and upstream license references.

In particular, the MinIO Dockerfile builds MinIO from source, which is licensed under AGPL-3.0. Review its terms before distributing a built image or binary, or making a modified version available over a network. The notice file is an informational summary, not a complete inventory of all software bundled in the container images or legal advice.
