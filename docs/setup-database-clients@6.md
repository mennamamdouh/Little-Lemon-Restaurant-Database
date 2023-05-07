> This documentation is for issue #6.

<hr>

# 3. Creating database clients #

Little Lemon Restaurant needs a database client to deal with the database using a Python Appliction. To do this task we need to connect python to the database, and this can be done using ```mysql-connector-python```.

First, I've imported the library then established the connection.

```python
connection = connector.connect(
    user = ENV_DATABASE_USER,
    password = ENV_DATABASE_PASSWORD,
    host = ENV_DATABASE_HOST,
    port = ENV_DATABASE_PORT)
```

After that, I've created a cursor to link the Pyhon Application to the database, and use the database.

```python
cursor = connection.cursor()

use_database = """USE Little_Lemon_DB;"""
cursor.execute(use_database)
```

Finally, Little Lemon now has a database client, and can monitor the information they need through a Python Application.

<hr>

I've done some tasks using this application:

1. Show the tables of the database

    ```python
    show_tables_query = """SHOW TABLES;""" 
    cursor.execute(show_tables_query)
    results = cursor.fetchall()

    for i, result in enumerate(results):
        print("Table no. ", i+1, ": ", result[0])
    ```

    and this gave me the following results:

    ```
    Table no.  1 :  bookings
    Table no.  2 :  customers
    Table no.  3 :  menu
    Table no.  4 :  orders
    Table no.  5 :  orders_delivery_status
    Table no.  6 :  orders_details
    Table no.  7 :  ordersview
    Table no.  8 :  staff
    ```

2. Extract some information about the customers who paid more than 60$ for the purpose of promotional campaign

    ```python
    promotional_campaign = """
        SELECT C.Full_Name, C.Phone_Number, O.Total_Cost
        FROM Customers AS C
        INNER JOIN Bookings AS B
            ON B.Customer_ID = C.Customer_ID
        INNER JOIN Orders AS O
            ON O.Booking_ID = B.Booking_ID
        WHERE O.Total_Cost > 60;
    """

    cursor.execute(promotional_campaign)

    results = cursor.fetchall()

    print("Information about customers for the purpose of promotional campaign:")

    for i, result in enumerate(results):
        print("Customer no. ", i+1, ": ", result[0], "whose contact is (", result[1], ") has paid ", result[2], "$.")
    ```

    and this gave me the following results:

    ```
    Information about customers who win promotional_campaign:
    Customer no.  1 :  Rabia Mendoza whose contact is ( 0123456789 ) has paid  890 $.
    Customer no.  2 :  Aayan Chaney whose contact is ( 0129876543 ) has paid  800 $.
    ```