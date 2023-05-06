> This documentation is for issue #3.

Little Lemon Restaurant needs some reports about:
1. The orders placed in the restaurant
2. All customers with orders that cost more than $150.
3. All menu items for which more than 2 orders have been placed.

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