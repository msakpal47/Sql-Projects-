#2. SQL Table Creation:#
#Write SQL CREATE TABLE statements for each entity, defining appropriate data types, constraints (primary keys, foreign keys), and indexing where necessary.#

CREATE TABLE Customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR2(100),
  email VARCHAR2(100),
  address VARCHAR2(4000),  -- or CLOB
  phone VARCHAR2(15)
);


CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

SELECT * FROM Products;

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

SELECT * FROM Orders;

CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

SELECT * FROM Order_Details;


CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_type VARCHAR(50),
    payment_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

SELECT * FROM Payments;


CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT,
    stock_level INT,
    reorder_point INT,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

SELECT * FROM Inventory;


CREATE TABLE Suppliers (
  supplier_id INT PRIMARY KEY,
  name VARCHAR2(100),
  contact_details VARCHAR2(4000)  -- or CLOB
);

SELECT * FROM Suppliers;

CREATE TABLE Supplier_Product (
    supplier_id INT,
    product_id INT,
    PRIMARY KEY (supplier_id, product_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

SELECT * FROM Supplier_Product;


#Data Insertion:#
#Use INSERT INTO statements to populate the tables with sample data for customers, products, orders, and payments.#

INSERT INTO Customers (customer_id, name, email, address, phone) 
VALUES (1, 'John Doe', 'john@example.com', '123 Elm St', '555-5555');

SELECT * FROM Customers;

INSERT INTO Products (product_id, name, category, price, stock_quantity) 
VALUES (101, 'Laptop', 'Electronics', 800.00, 50);

SELECT * FROM Products;


INSERT INTO Orders (order_id, customer_id, order_date)
VALUES (1001, 1, TO_DATE('2024-10-01', 'YYYY-MM-DD'));

SELECT * FROM Orders;


INSERT INTO Order_Details (order_detail_id, order_id, product_id, quantity, price) 
VALUES (1, 1001, 101, 1, 800.00);

SELECT * FROM Order_Details;


INSERT INTO Payments (payment_id,order_id,payment_type,payment_date,amount)
VALUES (2001,1001,'Credit Card',TO_DATE('2024-10-02', 'YYYY-MM-DD'),800.00);

SELECT * FROM Payments;

#####Queries:#####
###Basic Select Queries:####
####Retrieve all customers who have placed an order.#####

SELECT name, email FROM Customers 
WHERE customer_id IN (SELECT DISTINCT customer_id FROM Orders);

#####List the top 5 best-selling products.####
SELECT *
FROM (SELECT product_id, SUM(quantity) AS total_sold,ROW_NUMBER() OVER (ORDER BY SUM(quantity) DESC) AS rn
FROM Order_Details
GROUP BY product_id
)
WHERE rn <= 5;

####or#####

SELECT product_id, SUM(quantity) AS total_sold
FROM Order_Details
GROUP BY product_id
ORDER BY total_sold DESC
FETCH FIRST 4 ROWS ONLY;


####Joins:
####Get details of orders along with customer names and product details.#####
SELECT Orders.order_id, Customers.name, Products.name AS product, Order_Details.quantity
FROM Orders
JOIN Customers ON Orders.customer_id = Customers.customer_id
JOIN Order_Details ON Orders.order_id = Order_Details.order_id
JOIN Products ON Order_Details.product_id = Products.product_id;


####Aggregation & Grouping:###
####Calculate total sales revenue for each month.####

SELECT EXTRACT(MONTH FROM order_date) AS month, SUM(Order_Details.price * Order_Details.quantity) AS revenue
FROM Orders
JOIN Order_Details ON Orders.order_id = Order_Details.order_id
GROUP BY EXTRACT(MONTH FROM order_date);



####Subqueries:###
####Find customers who haven’t placed any orders in the last 6 months.###

SELECT name 
FROM Customers 
WHERE customer_id NOT IN (
  SELECT DISTINCT customer_id 
  FROM Orders 
  WHERE order_date >= ADD_MONTHS(SYSDATE, -6)
);

Or

SELECT name 
FROM Customers 
WHERE customer_id NOT IN (
  SELECT DISTINCT customer_id 
  FROM Orders 
  WHERE order_date >= SYSDATE - INTERVAL '6' MONTH
);


###Advanced SQL:###
####Views:Create a view to show customer order history.#####

CREATE VIEW Customer_Order_History AS 
SELECT Customers.name, Orders.order_id, Orders.order_date, SUM(Order_Details.price * Order_Details.quantity) AS total_spent
FROM Customers
JOIN Orders ON Customers.customer_id = Orders.customer_id
JOIN Order_Details ON Orders.order_id = Order_Details.order_id
GROUP BY Customers.name, Orders.order_id, Orders.order_date;

DESCRIBE Customer_Order_History;

SELECT * FROM Customer_Order_History;

##Test filters and aggregations##
SELECT * 
FROM Customer_Order_History 
WHERE total_spent > 1000;

SELECT name, SUM(total_spent) AS total_revenue 
FROM Customer_Order_History 
GROUP BY name;

##Check view dependencies##
SELECT * 
FROM ALL_DEPENDENCIES 
WHERE NAME = 'CUSTOMER_ORDER_HISTORY';

##View definition##
SELECT TEXT 
FROM ALL_VIEWS 
WHERE VIEW_NAME = 'CUSTOMER_ORDER_HISTORY';

###Stored Procedures:#####
Write a procedure to update stock levels when a new order is placed.

CREATE OR REPLACE PROCEDURE UpdateStock(
  p_prod_id IN Products.product_id%TYPE,
  p_qty IN INT
)
AS
BEGIN
  UPDATE Products
  SET stock_quantity = stock_quantity - p_qty
  WHERE product_id = p_prod_id;
END;
/


####Triggers:###
Create a trigger to automatically log every new order into an audit table.
sql

-- Create the sequence to auto-generate audit_id
CREATE SEQUENCE audit_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

-- Create the Order_Audit table
CREATE TABLE Order_Audit (
    audit_id INT PRIMARY KEY,
    order_id INT,
    customer_id INT,
    audit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE Order_Audit;

CREATE TABLE Order_Audit (
    audit_id INT PRIMARY KEY,
    order_id INT,
    customer_id INT,
    audit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

##Option 3: Check for Existing Objects###

SELECT object_name, object_type 
FROM user_objects 
WHERE object_name = 'ORDER_AUDIT';



-- Create a trigger to automatically insert the next value of audit_id from the sequence
CREATE OR REPLACE TRIGGER trg_order_audit_id
BEFORE INSERT ON Order_Audit
FOR EACH ROW
BEGIN
    :NEW.audit_id := audit_id_seq.NEXTVAL;
END;
/

#### OR ######

CREATE TRIGGER after_order_insert
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO Order_Audit (order_id, customer_id)
    VALUES (NEW.order_id, NEW.customer_id);
END;


########Optimization:#########
Use EXPLAIN to analyze the performance of complex queries and optimize them using proper indexing.

####Steps to Use EXPLAIN PLAN in Oracle:###

###EXPLAIN PLAN FOR###
SELECT * FROM Orders WHERE customer_id = 1;

####View the Execution Plan:####
After running the EXPLAIN PLAN FOR statement, you can retrieve the execution plan from the PLAN_TABLE. To do this, use the following query:

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Step 1: Generate Execution Plan
EXPLAIN PLAN 

SELECT * FROM Orders WHERE customer_id = 1;

-- Step 2: Display Execution Plan

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SELECT table_name FROM user_tables WHERE table_name = 'PLAN_TABLE';


CREATE TABLE PLAN_TABLE (
    statement_id VARCHAR2(30),
    plan_id NUMBER,
    timestamp DATE,
    remarks VARCHAR2(4000),
    operation VARCHAR2(30),
    options VARCHAR2(30),
    object_node VARCHAR2(128),
    object_owner VARCHAR2(30),
    object_name VARCHAR2(30),
    object_alias VARCHAR2(65),
    object_instance NUMBER,
    object_type VARCHAR2(30),
    optimizer VARCHAR2(255),
    search_columns NUMBER,
    id NUMBER,
    parent_id NUMBER,
    depth NUMBER,
    position NUMBER,
    cost NUMBER,
    cardinality NUMBER,
    bytes NUMBER,
    other_tag VARCHAR2(255),
    partition_start VARCHAR2(255),
    partition_stop VARCHAR2(255),
    partition_id NUMBER,
    other LONG,
    distribution VARCHAR2(30)
);

select * from PLAN_TABLE;

EXPLAIN PLAN FOR
SELECT * FROM Orders WHERE customer_id = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);---Run this command on SQL Plus for better out put

#### Sales Report Query:######
Since your Orders and Order_Details tables store the necessary information for sales reporting, you need to adjust the query to calculate the total_sales using the Order_Details table.

#####Here's how you can modify the query:#####

SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,  -- Group by year and month
    COUNT(o.order_id) AS number_of_orders,      -- Total number of orders
    SUM(od.quantity * od.price) AS total_sales, -- Sum of the quantity * price for each order (total sales)
    AVG(od.quantity * od.price) AS avg_order_value -- Average value of each order
FROM 
    Orders o
JOIN 
    Order_Details od ON o.order_id = od.order_id -- Joining Orders and Order_Details tables
GROUP BY 
    TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY 
    month;


 @##### Inventory Report Query:#######
In your database, you have the Inventory table to track stock levels and reorder points for each product. The following query will help you identify products that need to be reordered.

SELECT 
    p.product_id,
    p.name AS product_name,
    i.stock_level AS stock_quantity,
    i.reorder_point
FROM 
    Products p
JOIN 
    Inventory i ON p.product_id = i.product_id -- Joining Products and Inventory tables
WHERE 
    i.stock_level < i.reorder_point           -- Products where stock is below reorder level
ORDER BY 
    i.stock_level ASC;                        -- Order by stock quantity to prioritize
