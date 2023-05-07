INSERT INTO Customers
    (Customer_ID, Full_Name, Phone_Number)
VALUES
    (1, 'Rabia Mendoza', '0123456789'),
    (2, 'Aayan Chaney', '0129876543'),
    (3, 'Fatma Welch', '0126549873');

-----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Staff
    (Staff_ID, Name, Role, Salary, Address, Contact_Number, Email)
VALUES
    (1, 'Paula Newton', 'Manager', 5000, '1649 Tree Top Lane', '0129638574', 'puala.newton@gmail.com'),
    (2, 'Kelsey Yoder', 'Waiter', 2000, '1198 Rebecca Street', '0102365478', 'kelsey.yoder@gmail.com'),
    (3, 'Mathilda Weaver', 'Cheff', 3500, '3448 Beechwood Drive', '0113256487', 'mathidla.weaver@gmail.com');

-----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Menu
    (Item_ID, Name, Category, Cuisine, Price)
VALUES
    (1, 'Pasta', 'Strachy', 'Main dish', 150),
    (2, 'Salad', 'Fruits and Vegetables', 'Starter', 70),
    (3, 'Fried', 'Strachy', 'Appetizers', 100);

-----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Bookings
    (Booking_ID, Booking_Date, Customer_ID, Table_number, Number_of_Persons, Staff_ID)
VALUES
    (1, '2022-08-10 12:00', 1, 5, 10, 2),
    (2, '2022-09-15 3:30', 2, 4, 4, 2);

-----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Orders
    (Order_ID, Table_number, Order_Date, Total_Cost, Booking_ID)
VALUES
    (1, 5, '2022-08-10 12:30', 0, 1),
    (2, 4, '2022-09-15 4:00', 0, 2);

-----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Orders_Details
    (OrderID, Item_ID, Quantity)
VALUES
    (1, 1, 5), (1, 2, 2),
    (2, 1, 4), (2, 3, 2);

-----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Orders_Delivery_Status
    (Order_ID, Delivery_Date, Delivery_Status)
VALUES
    (1, '2022-08-10 1:00', 'Completed'),
    (2, '2022-09-15 4:30', 'Completed');


-----------------------------------------------------------------------------------------------------------------------------------