USE Tokopee_DB;

-- Query 1: New Product
-- Add a new, never-before-seen product to the database
INSERT INTO Item (StockCode, Description, Price, InventoryQuantity)
VALUES ('NEW001', 'Wireless Gaming Mouse - High-precision wireless gaming mouse with RGB lighting', 89.99, 50);
-- Verify the insert
SELECT * FROM Item WHERE StockCode = 'NEW001';



-- Query 2: Customer Order
-- An existing customer orders two different products in a single transaction
-- Insert new invoice
INSERT INTO Invoice (InvoiceId, InvoiceDate, CustomerId, TotalPrice)
VALUES ('INV_NEW001', '2025-11-11', '12346', 0.00);

-- Insert first item to the invoice
INSERT INTO InvoiceItem (InvoiceId, ItemStockCode, Quantity)
VALUES ('INV_NEW001', '10002', 2);

-- Insert second item to the invoice
INSERT INTO InvoiceItem (InvoiceId, ItemStockCode, Quantity)
VALUES ('INV_NEW001', '10080', 3);

-- Update the total price of the invoice
UPDATE Invoice
SET TotalPrice = (
    SELECT SUM(ii.Quantity * i.Price)
    FROM InvoiceItem ii
    JOIN Item i ON ii.ItemStockCode = i.StockCode
    WHERE ii.InvoiceId = 'INV_NEW001'
)
WHERE InvoiceId = 'INV_NEW001';

-- Update inventory quantities for purchased items
UPDATE Item
SET InventoryQuantity = InventoryQuantity - 2
WHERE StockCode = '10002';

UPDATE Item
SET InventoryQuantity = InventoryQuantity - 3
WHERE StockCode = '10080';

-- Verify the order
SELECT * FROM Invoice WHERE InvoiceId = 'INV_NEW001';
SELECT * FROM InvoiceItem WHERE InvoiceId = 'INV_NEW001';



-- Query 3: Customer Return
-- Process a return for one of the items from the order above

-- Get the quantity being returned
-- SQL Server and SQL client version issue
SET @return_invoice = 'INV_NEW001' COLLATE utf8mb4_0900_ai_ci;
SET @return_stockcode = '10002' COLLATE utf8mb4_0900_ai_ci;
SET @return_quantity = 1;

-- 1. Delete the row if the return quantity equals purchased quantity
DELETE FROM InvoiceItem
WHERE InvoiceId = @return_invoice 
  AND ItemStockCode = @return_stockcode 
  AND Quantity <= @return_quantity;

-- 2. Otherwise, update the quantity (decrease it)
UPDATE InvoiceItem
SET Quantity = Quantity - @return_quantity
WHERE InvoiceId = @return_invoice 
  AND ItemStockCode = @return_stockcode;

-- Update the invoice total price
UPDATE Invoice
SET TotalPrice = (
    SELECT COALESCE(SUM(ii.Quantity * i.Price), 0)
    FROM InvoiceItem ii
    JOIN Item i ON ii.ItemStockCode = i.StockCode
    WHERE ii.InvoiceId = @return_invoice
)
WHERE InvoiceId = @return_invoice;

-- Restore inventory quantity
UPDATE Item
SET InventoryQuantity = InventoryQuantity + @return_quantity
WHERE StockCode = @return_stockcode;

-- Verify the return
SELECT * FROM Invoice WHERE InvoiceId = 'INV_NEW001';
SELECT * FROM InvoiceItem WHERE InvoiceId = 'INV_NEW001';
SELECT * FROM Item WHERE StockCode = 'NEW001';



-- Query 4: Analytical Report
-- Find the top 10 customers by total money spent
SELECT 
    c.CustomerId,
    c.CustomerName,
    c.CustomerCountry,
    COUNT(DISTINCT inv.InvoiceId) AS TotalOrders,
    SUM(inv.TotalPrice) AS TotalSpent
FROM Customer c
JOIN Invoice inv ON c.CustomerId = inv.CustomerId
GROUP BY c.CustomerId, c.CustomerName, c.CustomerCountry
ORDER BY TotalSpent DESC
LIMIT 10;



-- Query 5: Analytical Report
-- Identify the month with the highest total sales revenue in 2011
SELECT 
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month,
    MONTHNAME(InvoiceDate) AS MonthName,
    COUNT(InvoiceId) AS TotalInvoices,
    SUM(TotalPrice) AS TotalRevenue
FROM Invoice
WHERE YEAR(InvoiceDate) = 2011
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate), MONTHNAME(InvoiceDate)
ORDER BY TotalRevenue DESC
LIMIT 1;