> This documentation is for issue #3.

<hr>

Little Lemon Restaurant needs some reports to monitor:
* The orders placed in the restaurant.
* The customers with specific orders.
* The menu items with specific number of orders.

And some features such as:
* Delete a specific order
* Check bookings
* Add valid bookings
* Update bookings
* Cancel Bookings

And to do those tasks we need to use some clauses and features from SQL like _Views_, _Stored Procedures_, _Triggers_ and _Prepare Statements_.

<hr>

## Task 1 : The orders placed in the restaurant ##

Little Lemon needs to know some information about the order placed in the restaurant like OrderID, Quantity, and Total Cost. It results in:

```sql
mysql> SELECT * FROM OrdersView;
+---------+----------+------------+
| OrderID | Quantity | Total_Cost |
+---------+----------+------------+
|       1 |        7 |        890 |
|       2 |        6 |        800 |
+---------+----------+------------+
2 rows in set (0.00 sec)
```

<hr>

## Task 2 : All customers with orders that cost more than $150 ##

Little Lemon needs to know some information about the customers with specific orders. It results in:

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

+-------------+---------------+----------+------+----------+
| Customer_ID | Full_Name     | Order_ID | Cost | MenuName |
+-------------+---------------+----------+------+----------+
|           1 | Rabia Mendoza |        1 |  150 | Pasta    |
|           1 | Rabia Mendoza |        1 |  140 | Salad    |
|           2 | Aayan Chaney  |        2 |  150 | Pasta    |
|           2 | Aayan Chaney  |        2 |  300 | Fried    |
+-------------+---------------+----------+------+----------+
4 rows in set (0.06 sec)
```

<hr>

## Task 3 : All menu items for which more than 2 orders have been placed ##

Little Lemon needs to know some information about the menu items for which more than 2 orders have been placed. It results in:

```sql
SELECT Name AS MenuName FROM Menu
WHERE Name = ANY(SELECT M.Name FROM Menu AS M
					INNER JOIN Orders_Details AS OD
						ON OD.Item_ID = M.Item_ID);

+----------+
| MenuName |
+----------+
| Pasta    |
| Salad    |
| Fried    |
+----------+
3 rows in set (0.14 sec)
```

<hr>

# Query Optimization #

When working with MySQL databases, the response time, or turnaround time, is extremely important. It’s particularly important in terms of how long the database takes to respond to your SQL queries. As data volumes grow, and the data requirements grow increasingly more complex, then performance becomes more important for a better end-user experience.

Database optimization is the best way to reduce database system response time. Response time is the time taken to transmit a query, process it, and transmit the response or information back to the user.  

We can optimize database queries using _stored procedures_ and _prepared statements_.

<hr>

# Task 1 : Displays the maximum ordered quantity in the Orders table #

This was done using a _Stored Procedure_ called __GetMaxQuantity()__. It results in:

```sql
mysql> CALL GetMaxQuantity();
+-----------------------+
| Max Quantity in Order |
+-----------------------+
|                     7 |
+-----------------------+
1 row in set (0.08 sec)

Query OK, 0 rows affected (0.08 sec)
```

<hr>

## Task 2 : Return information about an order #

This was done using a _Prepared Statement_ called __GetOrderDetail__. It results in:

```sql
mysql> SET @id = 1;
Query OK, 0 rows affected (0.05 sec)

mysql> EXECUTE GetOrderDetail USING @id;
+---------+----------+------------+
| OrderID | Quantity | Total_Cost |
+---------+----------+------------+
|       1 |        7 |        890 |
+---------+----------+------------+
1 row in set (0.04 sec)
```

<hr>

## Task 3 : Delete a specific order with its id ##

This was done using a _Stored Procedure_ called __CancelOrder__. It takes the Order_ID and delete the order from the __Orders__, the __Orders_Details__, and the __Orders_Delivery_Status__ tables.

```sql
mysql> CALL CancelOrder(1);
+---------------------+
| Confirmation        |
+---------------------+
| Order 1 is canceled |
+---------------------+
1 row in set (0.32 sec)

Query OK, 0 rows affected (0.32 sec)
```

<hr>

## Task 4 : Check the booking status of any table in the restaurant ##

This was done using a _Stored Procedure_ called __CheckBooking__. It takes 2 input:
1. Booking date
2. Table number
And then check if the booking already exists in the __Bookings__ table or not.

```sql
mysql> CALL CheckBooking("2022-08-10 12:00:00", 5);
+----------------------------+
| Booking Status             |
+----------------------------+
| Table 5 is already booked. |
+----------------------------+
1 row in set (0.05 sec)

Query OK, 0 rows affected (0.05 sec)
```

<hr>

## Task 5 : Verify a booking, and decline any reservations for tables that are already booked under another name ##

This was done using a _Stored Procedure_ called __AddValidBooking__. It takes 4 inputs:
1. Booking date
2. Table number
3. Customer ID
4. Number of persons

And check if there's an existing booking at the same time on the same table number, it prints that there's already an existing booking. Else, it stores this booking into the __Bookings__ table.

* If there's already a booking at this time on the same table number.

	```sql
	mysql> CALL AddValidBooking("2022-08-10 12:00:00", 5, 1, 5);
	+-----------------------------------------------+
	| Booking Status                                |
	+-----------------------------------------------+
	| Table 5 is already booked. Booking cancelled. |
	+-----------------------------------------------+
	1 row in set (0.03 sec)

	Query OK, 0 rows affected (0.03 sec)
	```

* If the booking date is different from all the bookings.

	```sql
	mysql> CALL AddValidBooking("2022-10-10 12:00:00", 5, 1, 5);  
	+----------------------------+
	| Booking Status             |
	+----------------------------+
	| Table 5 is booked for you. |
	+----------------------------+
	1 row in set (0.07 sec)

	Query OK, 0 rows affected (0.07 sec)

	mysql> SELECT * FROM Bookings;
	+------------+---------------------+-------------+--------------+-------------------+----------+
	| Booking_ID | Booking_Date        | Customer_ID | Table_number | Number_of_Persons | Staff_ID |
	+------------+---------------------+-------------+--------------+-------------------+----------+
	|          1 | 2022-08-10 12:00:00 |           1 |            5 |                10 |        2 |
	|          2 | 2022-09-15 03:30:00 |           2 |            4 |                 4 |        2 |
	|          3 | 2022-10-10 12:00:00 |           1 |            5 |                 5 |        2 |
	+------------+---------------------+-------------+--------------+-------------------+----------+
	3 rows in set (0.00 sec)
	```

* If the table number is different from all the bookings.

	```sql
	mysql> CALL AddValidBooking("2022-10-10 12:00:00", 2, 1, 5); 
	+----------------------------+
	| Booking Status             |
	+----------------------------+
	| Table 2 is booked for you. |
	+----------------------------+
	1 row in set (0.03 sec)

	Query OK, 0 rows affected (0.04 sec)

	mysql> SELECT * FROM Bookings;
	+------------+---------------------+-------------+--------------+-------------------+----------+
	| Booking_ID | Booking_Date        | Customer_ID | Table_number | Number_of_Persons | Staff_ID |
	+------------+---------------------+-------------+--------------+-------------------+----------+
	|          1 | 2022-08-10 12:00:00 |           1 |            5 |                10 |        2 |
	|          2 | 2022-09-15 03:30:00 |           2 |            4 |                 4 |        2 |
	|          3 | 2022-10-10 12:00:00 |           1 |            5 |                 5 |        2 |
	|          4 | 2022-10-10 12:00:00 |           1 |            2 |                 5 |        2 |
	+------------+---------------------+-------------+--------------+-------------------+----------+
	4 rows in set (0.05 sec)
	```

<hr>

## Task 6 : Update existing bookings in the booking table ##

This was done using a _Stored Procedure_ called __UpdateBooking__. It takes 2 inputs:
1. Booking ID
2. The new booking date

* If the booking already exists

	```sql
	mysql> CALL UpdateBooking(2, "2022-09-20 3:30");
	+-----------------------+
	| Confirmation          |
	+-----------------------+
	| Booking 2 is updated. |
	+-----------------------+
	1 row in set (0.09 sec)

	Query OK, 0 rows affected (0.10 sec)

	mysql> SELECT * FROM Bookings;
	+------------+---------------------+-------------+--------------+-------------------+----------+
	| Booking_ID | Booking_Date        | Customer_ID | Table_number | Number_of_Persons | Staff_ID |
	+------------+---------------------+-------------+--------------+-------------------+----------+
	|          1 | 2022-08-10 12:00:00 |           1 |            5 |                10 |        2 |
	|          2 | 2022-09-20 03:30:00 |           2 |            4 |                 4 |        2 |
	|          3 | 2022-10-10 12:00:00 |           1 |            5 |                 5 |        2 |
	|          4 | 2022-10-10 12:00:00 |           1 |            2 |                 5 |        2 |
	+------------+---------------------+-------------+--------------+-------------------+----------+
	4 rows in set (0.00 sec)
	```

* If the booking doesn't exist.

	```sql
	mysql> CALL UpdateBooking(7, "2022-09-20 3:30"); 
	+---------------------------------------+
	| Confirmation                          |
	+---------------------------------------+
	| There is no booking with booking id 7 |
	+---------------------------------------+
	1 row in set (0.03 sec)

	Query OK, 0 rows affected (0.03 sec)
	```

<hr>

## Task 7 : Cancel a booking ##

This was done using a _Stored Procedure_ called __CancelBooking__. It takes the Booking ID which the customer wants to cancel, and delete the booking from the __Bookings__ table, as well as delete the order related to this booking from the __Orders__, __Orders_Details__, and __Orders_Delivery_Status__.

* If the booking already exists.

	```sql
	mysql> CALL CancelBooking(2);
	+-------------------------+
	| Confirmation            |
	+-------------------------+
	| Booking 2 is cancelled. |
	+-------------------------+
	1 row in set (0.29 sec)

	Query OK, 0 rows affected (0.29 sec)
	```

* If the booking doesn't exists.

	```sql
	mysql> CALL CancelBooking(8); 
	+---------------------------------------+
	| Confirmation                          |
	+---------------------------------------+
	| There is no booking with booking id 8 |
	+---------------------------------------+
	1 row in set (0.00 sec)

	Query OK, 0 rows affected (0.01 sec)
	```

<hr>