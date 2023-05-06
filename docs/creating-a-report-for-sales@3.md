> This documentation is for issue #3.

Little Lemon Restaurant needs some reports about:
1. The orders placed in the restaurant
2. All customers with orders that cost more than $150.
3. All menu items for which more than 2 orders have been placed.
4. Creating some optimized queries to help Little Lemon monitor the sales

And to do this task we need to use some clauses and features from SQL like _Views_.

<hr>

## Task 1 : The orders placed in the restaurant ##

Little Lemon needs to know some information about the order placed in the restaurant like OrderID, Quantity, and Total Cost.

Here is the code of the view:

<ul>

```sql
CREATE VIEW OrdersView AS
SELECT OD.OrderID, SUM(OD.Quantity) AS Quantity, O.Total_Cost
FROM Orders_Details AS OD
INNER JOIN Orders AS O
	ON O.Order_ID = OD.OrderID
GROUP BY OD.OrderID;
```

</ul>

This results in the following information:

<ul>

| OrderID | Quantity    | Total Cost    |
| :---:   | :---:       | :---:         |

</ul>

<hr>

## Task 2 : All customers with orders that cost more than $150 ##

Little Lemon needs to know some information about the customers with specific orders.

Here is the code:

<ul>

```sql
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
```

</ul>

This results in the following information:

<ul>

| CustomerID | FullName    | OrderID    | Cost | MenuName |
| :---:      | :---:       | :---:      |:---: |:---:     |

</ul>

<hr>

## Task 3 : All menu items for which more than 2 orders have been placed ##

Little Lemon needs to know some information about the menu items for which more than 2 orders have been placed.

Here is the code:

<ul>

```sql
SELECT Name AS MenuName FROM Menu
WHERE Name = ANY(SELECT M.Name FROM Menu AS M
					INNER JOIN Orders_Details AS OD
						ON OD.Item_ID = M.Item_ID);
```

</ul>

This results in the following information:

<ul>

| MeneName |
| :---:    |

</ul>

<hr>

# Query Optimization #

When working with MySQL databases, the response time, or turnaround time, is extremely important. It’s particularly important in terms of how long the database takes to respond to your SQL queries. As data volumes grow, and the data requirements grow increasingly more complex, then performance becomes more important for a better end-user experience.

Database optimization is the best way to reduce database system response time. Response time is the time taken to transmit a query, process it, and transmit the response or information back to the user.  

We can optimize database queries using _stored procedures_ and _prepared statements_.

<hr>

# Task 1 : Displays the maximum ordered quantity in the Orders table #

The code:

<ul>

```sql
DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
	SELECT MAX(TQ.Total_Quantity) AS "Max Quantity in Order"
    FROM ((SELECT SUM(Quantity) AS Total_Quantity FROM Orders_Details GROUP BY OrderID)) AS TQ;
END//
DELIMITER ;
```

</ul>

To call the procedure:

<ul>

```sql
CALL GetMaxQuantity();
```

</ul>

This results in the following information:

<ul>

| Max Quantity in Order |
| :------------------:  |

</ul>

<hr>

## Task 2 : Return information about an order #

The code:

<ul>

```sql
PREPARE GetOrderDetail FROM 'SELECT OD.OrderID, SUM(OD.Quantity) AS Quantity, O.Total_Cost
FROM Orders_Details AS OD
INNER JOIN Orders AS O
	ON O.Order_ID = OD.OrderID
WHERE OD.OrderID = ?
GROUP BY OD.OrderID';
```

</ul>

To return Order Details of a specific order:

<ul>

```sql
SET @id = 1;
EXECUTE GetOrderDetail USING @id;
```

</ul>

This results in the following information:

<ul>

| OrderID | Quantity    | Total Cost    |
| :---:   | :---:       | :---:         |

</ul>

<hr>

## Task 3 : Delete a specific order with its id ##

The code:

<ul>

```sql
DELIMITER //
CREATE PROCEDURE CancelOrder(IN id_order INT)
BEGIN
	DELETE FROM Orders_Details WHERE OrderID = id_order;
	DELETE FROM Orders_Delivery_Status WHERE Order_ID = id_order;
	DELETE FROM Orders WHERE Order_ID = id_order;
    SELECT CONCAT('Order ', id_order, ' is canceled') as 'Confirmation';
END//
DELIMITER ;
```

</ul>

To call the procedure:

<ul>

```sql
CALL CancelOrder(1);
```

</ul>

This results in the following information:
<ul>

|      Confirmation     |
| :------------------:  |
| Order 1 is cancelled |

</ul>

<hr>

## Task 4 : Check the booking status of any table in the restaurant ##

The code:

<ul>

```sql
DELIMITER //
CREATE PROCEDURE CheckBooking(IN book_date VARCHAR(45), IN table_no INT)
BEGIN
	SET @booking := (SELECT Booking_ID FROM Bookings WHERE Booking_Date = book_date AND Table_Number = table_no);
	IF @booking THEN
		SELECT CONCAT("Table ", table_no, " is already booked.") AS "Booking Status";
		END IF;
END//
DELIMITER ;
```

</ul>

To call the procedure:

<ul>

```sql
CALL CheckBooking("2022-08-10 12:00:00", 5);
```

</ul>

<hr>

## Task 5 : verify a booking, and decline any reservations for tables that are already booked under another name ##

The code:

<ul>

```sql
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
```

<hr>

## Task 6 : Update existing bookings in the booking table ##

The code:

<ul>

```sql
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
```

<hr>

## Task 7 : Update existing bookings in the booking table ##

The code:

<ul>

```sql
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
```

<hr>