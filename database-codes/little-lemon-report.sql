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

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Task4: Create a stored procedure to check whether a table in the restaurant is already booked.

DELIMITER //
CREATE PROCEDURE CheckBooking(IN book_date VARCHAR(45), IN table_no INT)
BEGIN
	SET @booking := (SELECT Booking_ID FROM Bookings WHERE Booking_Date = book_date AND Table_Number = table_no);
	IF @booking THEN
		SELECT CONCAT("Table ", table_no, " is already booked.") AS "Booking Status";
		END IF;
END//
DELIMITER ;

-- To call the procedure
CALL CheckBooking("2022-08-10 12:00:00", 5);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Task5: verify a booking, and decline any reservations for tables that are already booked under another name. 

DELIMITER //
CREATE PROCEDURE AddValidBooking(IN book_date VARCHAR(45), IN table_no INT, IN customerId INT, IN persons INT)
BEGIN
	SET @booking := (SELECT Booking_ID FROM Bookings WHERE Booking_Date = book_date AND Table_Number = table_no);

	START TRANSACTION;
		SET @nex_book_id := (SELECT MAX(Booking_ID) FROM Bookings) + 1;
			INSERT INTO Bookings
				(Booking_ID, Booking_Date, Customer_ID, Table_Number, Number_of_Persons, Staff_ID)   
			VALUES
				(@nex_book_id, book_date, customerId, table_no, persons, 2);

	-- Check if the booking is available or not
	IF @booking THEN
		ROLLBACK;
		SELECT CONCAT("Table ", table_no, " is already booked. Booking cancelled.") AS "Booking Status";
	ELSE
		COMMIT;
		SELECT CONCAT("Table ", table_no, " is booked for you.") AS "Booking Status";
	END IF;

END//
DELIMITER ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Task6: Update existing bookings in the booking table
DELIMITER //
CREATE PROCEDURE UpdateBooking( IN book_id INT, IN book_date VARCHAR(45))
BEGIN
	SET @booking := (SELECT Booking_ID FROM Bookings WHERE Booking_ID = book_id);
	IF @booking THEN
		UPDATE Bookings SET Booking_Date = book_date WHERE Booking_ID = book_id;
		SELECT CONCAT("Booking ", book_id, " is updated.") AS "Confirmation";
	ELSE
		SELECT CONCAT("There is no booking with booking id ", book_id) AS "Confirmation";
	END IF;
END//
DELIMITER ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Task7: Cancel bookings in the booking table
DELIMITER //
CREATE PROCEDURE CancelBooking( IN book_id INT)
BEGIN
	SET @booking := (SELECT Booking_ID FROM Bookings WHERE Booking_ID = book_id);
	IF @booking THEN
		SET @order := (SELECT Order_ID FROM Orders WHERE Booking_ID = book_id);
		DELETE FROM Orders_Details WHERE OrderID = @order;
		DELETE FROM Orders_Delivery_Status WHERE Order_ID = @order;
		DELETE FROM Orders WHERE Booking_ID = book_id;
		DELETE FROM Bookings WHERE Booking_ID = book_id;
		SELECT CONCAT("Booking ", book_id, " is cancelled.") AS "Confirmation";
	ELSE
		SELECT CONCAT("There is no booking with booking id ", book_id) AS "Confirmation";
	END IF;
END//
DELIMITER ;