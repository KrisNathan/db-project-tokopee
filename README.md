# Tokopee

This project uses Git LFS for storing the provided dataset and it's conversion to SQL.

## System Dependency

- `uv`
- `npm`
- `docker` (optional)

## Applying Migration and Populating Database with Dataset
make sure to drop the database before running (if have run before)
```sh
uv run main.py
```

## SQL Queries
The files are in the sql folder
```
./sql
```

## Rendering ERD Diagrams (Optional)

Ensure you have npm installed for this step.

```sh
uv run render_erd.py
```

## Convert Dataset to SQL (Optional)

```sh
uv run dataset_sql_builder.py
```
