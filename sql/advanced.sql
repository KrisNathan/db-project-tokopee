-- Trigger: 
-- Create a trigger that automatically updates the inventory level of a product 
-- whenever a transaction (sale or return) involving that product is recorded.

DROP TRIGGER IF EXISTS Inventory_AfterInsert;
DROP TRIGGER IF EXISTS Inventory_AfterDelete;
DROP TRIGGER IF EXISTS Inventory_AfterUpdate;


-- Sale, When a new item is added into invoice, substract from inventory
CREATE TRIGGER Inventory_AfterInsert
AFTER INSERT ON InvoiceItem
FOR EACH ROW
BEGIN
  UPDATE Item
  SET InventoryQuantity = InventoryQuantity - NEW.Quantity
  WHERE ItemStockCode = NEW.ItemStockCode;
END;
  
-- Return, When a new item is removed from invoice, add it back into inventory
CREATE TRIGGER Inventory_AfterDelete
AFTER DELETE ON InvoiceItem
FOR EACH ROW
BEGIN
  UPDATE Item
  SET InventoryQuantity = InventoryQuantity + OLD.Quantity
  WHERE ItemStockCode = OLD.ItemStockCode;
END;
  
-- Return, When a quantity is changed, adjust inventory by difference
CREATE TRIGGER Inventory_AfterUpdate
AFTER UPDATE ON InvoiceItem
FOR EACH ROW
BEGIN
  IF OLD.Quantity <> NEW.Quantity THEN
    UPDATE Item 
    SET InventoryQuantity = InventoryQuantity - (NEW.Quantity - OLD.Quantity)
    WHERE ItemStockCode = NEW.ItemStockCode;
  END IF;
END;


-- Stored Procedure: Create a stored procedure named GetCustomerInvoiceHistory 
-- that accepts a CustomerID as input and returns a complete list of all invoices 
-- (including the date and total value) belonging to that customer.

DROP PROCEDURE IF EXISTS GetCustomerInvoiceHistory;

CREATE PROCEDURE GetCustomerInvoiceHistory (
  IN p_CustomerId VARCHAR(20)
)
BEGIN 
  SELECT 
    inv.InvoiceId,
    inv.InvoiceDate,
    inv.TotalPrice,
    COUNT(ii.ItemStockCode) as ItemsCount
  FROM Invoice inv
  LEFT JOIN InvoiceItem ii ON inv.InvoiceId = ii.InvoiceId
  WHERE inv.CustomerId = p_CustomerId
  GROUP BY inv.InvoiceId, inv.InvoiceDate, inv.TotalPrice
  ORDER BY inv.InvoiceDate DESC;
END;
