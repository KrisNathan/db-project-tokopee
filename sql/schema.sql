CREATE DATABASE IF NOT EXISTS Tokopee_DB;
USE Tokopee_DB;

CREATE TABLE IF NOT EXISTS Customer (
    CustomerId      VARCHAR(20)     NOT NULL,
    CustomerName    VARCHAR(100)    NOT NULL,
    CustomerCountry VARCHAR(50)     NOT NULL,
    PRIMARY KEY (CustomerId)
);

CREATE TABLE IF NOT EXISTS Item (
    StockCode           VARCHAR(20)     NOT NULL,
    Description         VARCHAR(255)    NOT NULL,
    Price               DECIMAL(12, 3)  NOT NULL,
    InventoryQuantity   INT             NOT NULL DEFAULT 0,
    PRIMARY KEY (StockCode),

    CONSTRAINT CHK_Item_Price_Qty CHECK (Price >= 0 AND InventoryQuantity >= 0)
);

CREATE TABLE IF NOT EXISTS Invoice (
    InvoiceId       VARCHAR(20)     NOT NULL,
    InvoiceDate     DATE            NOT NULL,
    CustomerId      VARCHAR(20)     NOT NULL,
    TotalPrice      DECIMAL(12, 3)  NOT NULL DEFAULT 0.00,
    PRIMARY KEY (InvoiceId),

    CONSTRAINT FK_Invoice_Customer
        FOREIGN KEY (CustomerId)
        REFERENCES Customer (CustomerId)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,

    CONSTRAINT CHK_Invoice_TotalPrice CHECK (TotalPrice >= 0)
);

CREATE TABLE IF NOT EXISTS InvoiceItem (
    InvoiceId       VARCHAR(20)     NOT NULL,
    ItemStockCode   VARCHAR(20)     NOT NULL,
    Quantity        INT             NOT NULL DEFAULT 0,
    PRIMARY KEY (InvoiceId, ItemStockCode),

    CONSTRAINT FK_InvoiceItem_Invoice
        FOREIGN KEY (InvoiceId)
        REFERENCES Invoice (InvoiceId)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT FK_InvoiceItem_Item
        FOREIGN KEY (ItemStockCode)
        REFERENCES Item (StockCode)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,

    CONSTRAINT CHK_InvoiceItem_Quantity CHECK (Quantity > 0)
);
