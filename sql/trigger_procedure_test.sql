-- Check initial state
SELECT StockCode, InventoryQuantity FROM Item WHERE StockCode = 'NEW001';

-- sell 5 items, should reduce Inventory by 5
INSERT INTO Invoice (InvoiceId, InvoiceDate, CustomerId, TotalPrice) 
VALUES ('TEST_AUTO_01', NOW(), '12346', 0);
INSERT INTO InvoiceItem (InvoiceId, ItemStockCode, Quantity) 
VALUES ('TEST_AUTO_01', 'NEW001', 5);

-- verify inventory, should be 5 less
SELECT ItemStockCode, InventoryQuantity FROM Item WHERE ItemStockCode = 'NEW001';

-- partial return change quantity from 5 to 2 -> Return 3 items
UPDATE InvoiceItem SET Quantity = 2 WHERE InvoiceId = 'TEST_AUTO_01';

-- verify inventory, should increase 3
SELECT ItemStockCode, InventoryQuantity FROM Item WHERE ItemStockCode = 'NEW001';

-- full return -> return remaining 2 items
DELETE FROM InvoiceItem WHERE InvoiceId = 'TEST_AUTO_01';

-- verify inventory, should be back to original
SELECT ItemStockCode, InventoryQuantity FROM Item WHERE ItemStockCode = 'NEW001';

-- run stored procedure
CALL GetCustomerInvoiceHistory('12682');
