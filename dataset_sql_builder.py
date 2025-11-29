import csv
import math
from datetime import datetime
from decimal import Decimal
from typing import Iterator, Optional

from mnemonic import Mnemonic
from pydantic import BaseModel, Field, FiniteFloat, ValidationError


def sql_escape(s: str) -> str:
    return s.replace("'", "''")


# Example CSV
# Invoice,StockCode,Description,Quantity,InvoiceDate,Price,Customer ID,Country
# 489434,85048,15CM CHRISTMAS GLASS BALL 20 LIGHTS,12,2009-12-01 07:45:00,6.95,13085.0,United Kingdom


class DataRow(BaseModel):
    invoice: str
    stock_code: str
    description: Optional[str]
    quantity: int
    invoice_date: datetime
    price: Decimal
    country: str
    customer_id: Optional[str]


def read_typed_csv(filepath: str) -> Iterator[DataRow]:
    """Reads a CSV file and yields typed NamedTuple objects."""
    with open(filepath, "r", newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            parsed_dt = datetime.strptime(
                row["InvoiceDate"].strip(), "%Y-%m-%d %H:%M:%S"
            )

            raw_customer_id = row["Customer ID"]
            clean_customer_id = None
            
            if raw_customer_id:
                try:
                    # Converts "12346.0" -> 12346.0 -> 12346 -> "12346"
                    clean_customer_id = str(int(float(raw_customer_id)))
                except ValueError:
                    clean_customer_id = raw_customer_id.upper()

            yield DataRow(
                invoice=row["Invoice"].upper(),
                stock_code=row["StockCode"].upper(),
                description=None if row["Description"] == "" else row["Description"],
                quantity=abs(int(row["Quantity"])),
                invoice_date=parsed_dt,
                price=Decimal(row["Price"]),
                country=row["Country"],
                # customer_id=None
                # if row["Customer ID"] == ""
                # else row["Customer ID"].upper(),
                customer_id=clean_customer_id,
            )


class Customer(BaseModel):
    customer_id: str
    customer_name: str
    customer_country: str


class Item(BaseModel):
    stock_code: str
    description: str
    price: Decimal = Field(gt=Decimal("0"))
    inventory_quantity: int = Field(gt=0)


class Invoice(BaseModel):
    invoice_id: str
    invoice_date: datetime
    customer_id: str
    total_price: Decimal


class InvoiceItem(BaseModel):
    invoice_id: str
    item_stock_code: str
    quantity: int


def main():
    customers: dict[str, Customer] = {}
    items: dict[str, Item] = {}
    invoices: dict[str, Invoice] = {}
    invoice_items: dict[str, InvoiceItem] = {}

    mnemo = Mnemonic("english")

    for row in read_typed_csv("online_retail_data.csv"):
        # print(row)
        if row.customer_id not in customers and row.customer_id:
            try:
                m = mnemo.generate(strength=128)
                cname = " ".join(m.split()[:2])
                customer = Customer(
                    customer_id=row.customer_id,
                    customer_name=cname,
                    customer_country=row.country,
                )
                customers[row.customer_id] = customer
            except Exception as e:
                # print(f"{row}: {e}")
                pass

        if row.stock_code not in items and row.description:
            try:
                item = Item(
                    stock_code=row.stock_code,
                    description=row.description,
                    price=row.price,
                    inventory_quantity=10,  # no idea
                )
                items[row.stock_code] = item
            except ValidationError as e:
                pass

        total_price = row.price * Decimal(str(row.quantity))
        if row.invoice not in invoices:
            try:
                invoice = Invoice(
                    invoice_id=row.invoice,
                    invoice_date=row.invoice_date,
                    customer_id=row.customer_id,
                    total_price=total_price,
                )
                invoices[row.invoice] = invoice
            except Exception as e:
                # print(f"ERROR: {row}\n{e}")
                pass
        elif row.invoice in invoices:
            invoices[row.invoice].total_price += total_price
            if row.customer_id:
                invoices[row.invoice].customer_id = row.customer_id

        if (
            row.invoice
            and row.stock_code
            and row.invoice in invoices
            and row.stock_code in items
        ):
            invoice_item_key = f"{row.invoice}-{row.stock_code}"
            if invoice_item_key not in invoice_items:
                try:
                    invoice_item = InvoiceItem(
                        invoice_id=row.invoice,
                        item_stock_code=row.stock_code,
                        quantity=row.quantity,
                    )
                    invoice_items[invoice_item_key] = invoice_item
                except Exception as e:
                    pass

    # Write SQL to dataset.sql
    with open("dataset.sql", "w") as f:
        f.write("INSERT INTO Customer VALUES\n")
        values = [
            f"('{sql_escape(customer.customer_id)}', '{sql_escape(customer.customer_name)}', '{sql_escape(customer.customer_country)}')"
            for customer in customers.values()
        ]
        f.write(",\n".join(values) + ";\n\n")

        f.write("INSERT INTO Item VALUES\n")
        values = [
            f"('{sql_escape(item.stock_code)}', '{sql_escape(item.description)}', {item.price}, {item.inventory_quantity})"
            for item in items.values()
        ]
        f.write(",\n".join(values) + ";\n\n")
        f.write("INSERT INTO Invoice VALUES\n")
        values = [
            f"('{sql_escape(invoice.invoice_id)}', '{invoice.invoice_date.strftime('%Y-%m-%d %H:%M:%S')}', '{sql_escape(invoice.customer_id)}', {invoice.total_price})"
            for invoice in invoices.values()
        ]
        f.write(",\n".join(values) + ";\n\n")

        f.write("INSERT INTO InvoiceItem VALUES\n")
        values = [
            f"('{sql_escape(invoice_item.invoice_id)}', '{sql_escape(invoice_item.item_stock_code)}', {invoice_item.quantity})"
            for invoice_item in invoice_items.values()
        ]
        f.write(",\n".join(values) + ";\n\n")


if __name__ == "__main__":
    main()
