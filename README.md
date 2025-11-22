# Tokopee

This project uses Git LFS for storing the provided dataset and it's conversion to SQL.

## System Dependency

- `uv`
- `npm`
- `docker` (optional)

## Rendering ERD Diagrams

Ensure you have npm installed for this step.

```sh
uv run render_erd.py
```

## Convert Dataset to SQL

```sh
uv run dataset_sql_builder.py
```

## Applying Migration and Populating Database with Dataset

```sh
uv run main.py
```
