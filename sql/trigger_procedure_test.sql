-- Check initial state
SELECT StockCode, InventoryQuantity FROM Item WHERE StockCode = 'NEW001';

-- TEST 1: Sell 5 items (Trigger should reduce Inventory by 5)
INSERT INTO Invoice (InvoiceId, InvoiceDate, CustomerId, TotalPrice) 
VALUES ('TEST_AUTO_01', NOW(), '12346', 0);
INSERT INTO InvoiceItem (InvoiceId, ItemStockCode, Quantity) 
VALUES ('TEST_AUTO_01', 'NEW001', 5);

-- Verify Inventory (Should be 5 less)
SELECT StockCode, InventoryQuantity FROM Item WHERE StockCode = 'NEW001';

-- TEST 2: Partial Return/Update (Change Qty from 5 to 2) -> Return 3 items
UPDATE InvoiceItem SET Quantity = 2 WHERE InvoiceId = 'TEST_AUTO_01';

-- Verify Inventory (Should increase by 3)
SELECT StockCode, InventoryQuantity FROM Item WHERE StockCode = 'NEW001';

-- TEST 3: Full Return (Delete Row) -> Return remaining 2 items
DELETE FROM InvoiceItem WHERE InvoiceId = 'TEST_AUTO_01';

-- Verify Inventory (Should be back to original)
SELECT StockCode, InventoryQuantity FROM Item WHERE StockCode = 'NEW001';

-- TEST 4: Run Stored Procedure
CALL GetCustomerInvoiceHistory('12682');