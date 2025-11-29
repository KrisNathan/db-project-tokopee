# Tokopee

Note regarding handling of price changes over time: 

1. we assume that the item price history is not part of business logic
2. total price listed in invoice is result of price * quantity at time of purchase
3. we assume that price changes do not affect past invoices
4. accounting wise, the total price listed in invoice is already sufficient
5. item price listed in item table is the latest price

This project uses Git LFS for storing the provided dataset and it's conversion to SQL.

## Contributors
- [@KrisNathan](https://github.com/KrisNathan) (Kristopher N.)
- [@orde-r](https://github.com/orde-r) (Danielson)
- [@florenciaolga](https://github.com/florenciaolga) (Florencia Olga)

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
