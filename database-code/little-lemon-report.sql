USE Little_Lemon_DB;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

											  -- Total Cost Trigger --

DELIMITER //
CREATE TRIGGER TotalCost AFTER INSERT ON Orders_Delivery_Status FOR EACH ROW
BEGIN
	UPDATE Orders
		SET Total_Cost = (SELECT SUM(OD.Quantity * M.Price) FROM Orders_Details AS OD
							INNER JOIN Menu AS M
								ON M.Item_ID = OD.Item_ID
							WHERE OD.OrderID = NEW.Order_ID)
		WHERE Order_ID = NEW.Order_ID;
END//
DELIMITER ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

											  -- Little Lemon Report --

-- Task1: OrdersView
CREATE VIEW OrdersView AS
SELECT OD.OrderID, SUM(OD.Quantity) AS Quantity, O.Total_Cost
FROM Orders_Details AS OD
INNER JOIN Orders AS O
	ON O.Order_ID = OD.OrderID
GROUP BY OD.OrderID;

-- To show the results of the view
SELECT * FROM OrdersView;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Task2: Customers
SELECT C.Customer_ID, C.Full_Name, O.Order_ID, (M.Item_ID * M.Price) AS Cost, M.Name AS MenuName
FROM Customers AS C
INNER JOIN Bookings AS B
	ON B.Customer_ID = C.Customer_ID
INNER JOIN Orders AS O
	ON O.Booking_ID = B.Booking_ID
INNER JOIN Orders_Details AS OD
	ON OD.OrderID = O.Order_ID
INNER JOIN Menu AS M
	ON M.Item_ID = OD.Item_ID
WHERE O.Total_Cost > 150;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Task3: Menu Items
SELECT Name AS MenuName FROM Menu
WHERE Name = ANY(SELECT M.Name FROM Menu AS M
					INNER JOIN Orders_Details AS OD
						ON OD.Item_ID = M.Item_ID);
                        
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

												-- Optimized Queries --

-- Task1: Displays the maximum ordered quantity in the Orders table.
DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
	SELECT MAX(TQ.Total_Quantity) AS "Max Quantity in Order"
    FROM ((SELECT SUM(Quantity) AS Total_Quantity FROM Orders_Details GROUP BY OrderID)) AS TQ;
END//
DELIMITER ;

-- To call the procedure
CALL GetMaxQuantity();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Task2: Create a prepared statement to return information about an order

PREPARE GetOrderDetail FROM 'SELECT OD.OrderID, SUM(OD.Quantity) AS Quantity, O.Total_Cost
FROM Orders_Details AS OD
INNER JOIN Orders AS O
	ON O.Order_ID = OD.OrderID
WHERE OD.OrderID = ?
GROUP BY OD.OrderID';

-- To use the prepared statement for a specific order
SET @id = 1;
EXECUTE GetOrderDetail USING @id;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Task3: Create a stored procedure to delete a specific order with its id
DELIMITER //
CREATE PROCEDURE CancelOrder(IN id_order INT)
BEGIN
	DELETE FROM Orders_Details WHERE OrderID = id_order;
	DELETE FROM Orders_Delivery_Status WHERE Order_ID = id_order;
	DELETE FROM Orders WHERE Order_ID = id_order;
    SELECT CONCAT('Order ', id_order, ' is canceled') as 'Confirmation';
END//
DELIMITER ;

-- To call the procedure
CALL CancelOrder(1);