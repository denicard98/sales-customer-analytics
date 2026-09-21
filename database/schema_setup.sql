/* ============================================================
   Sales & Customer Analytics — Database Setup
   SQL Server / T-SQL — run once in SSMS or sqlcmd.

   Creates the SQL_Practice database, the five tables and the
   sample dataset used by analysis/business_questions.sql.
   Sample data was generated for practice purposes.
   ============================================================ */

IF DB_ID(N'SQL_Practice') IS NULL
BEGIN
    CREATE DATABASE SQL_Practice;
END
GO

USE SQL_Practice;
GO

-- Drop tables in dependency order, if they already exist
IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

CREATE TABLE dbo.Customers (
    customer_id       INT PRIMARY KEY,
    first_name        VARCHAR(50),
    last_name         VARCHAR(50),
    country            VARCHAR(50),
    city               VARCHAR(50),
    age                INT,
    signup_date        DATE,
    customer_segment   VARCHAR(30),
    score              INT
);

CREATE TABLE dbo.Products (
    product_id         INT PRIMARY KEY,
    product_name       VARCHAR(100),
    category           VARCHAR(50),
    unit_price         DECIMAL(10,2),
    cost_price         DECIMAL(10,2),
    supplier_country   VARCHAR(50)
);

CREATE TABLE dbo.Employees (
    employee_id    INT PRIMARY KEY,
    first_name     VARCHAR(50),
    last_name      VARCHAR(50),
    department     VARCHAR(50),
    country        VARCHAR(50),
    salary         DECIMAL(10,2),
    hire_date      DATE,
    manager_id     INT NULL,
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (manager_id)
        REFERENCES dbo.Employees(employee_id)
);

CREATE TABLE dbo.Orders (
    order_id         INT PRIMARY KEY,
    customer_id      INT,
    employee_id      INT,
    order_date       DATE,
    status           VARCHAR(30),
    payment_method   VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES dbo.Employees(employee_id)
);

CREATE TABLE dbo.OrderItems (
    order_item_id      INT PRIMARY KEY,
    order_id           INT,
    product_id         INT,
    quantity           INT,
    unit_price         DECIMAL(10,2),
    discount_percent   DECIMAL(5,2),
    FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id)
);
GO


-- Customers (18 rows)
INSERT INTO dbo.Customers (customer_id, first_name, last_name, country, city, age, signup_date, customer_segment, score) VALUES
(1, 'Ana', 'Silva', 'Portugal', 'Lisbon', 29, '2024-01-15', 'Regular', 720),
(2, 'Miguel', 'Santos', 'Portugal', 'Porto', 35, '2023-06-20', 'Premium', 850),
(3, 'Sofia', 'Costa', 'Portugal', 'Lisbon', 42, '2022-11-05', 'Premium', 910),
(4, 'Joao', 'Martins', 'Portugal', 'Coimbra', 24, '2025-02-10', 'Regular', 450),
(5, 'Laura', 'Schmidt', 'Germany', 'Berlin', 31, '2023-03-18', 'Premium', 880),
(6, 'Max', 'Weber', 'Germany', 'Munich', 46, '2022-08-12', 'Premium', 940),
(7, 'Anna', 'Fischer', 'Germany', 'Hamburg', 27, '2024-07-01', 'Regular', 610),
(8, 'Carlos', 'Garcia', 'Spain', 'Madrid', 38, '2023-09-14', 'Premium', 790),
(9, 'Lucia', 'Martinez', 'Spain', 'Barcelona', 26, '2024-04-22', 'Regular', 580),
(10, 'Diego', 'Lopez', 'Spain', 'Madrid', 51, '2021-12-01', 'Premium', 920),
(11, 'Emma', 'Smith', 'UK', 'London', 33, '2023-05-09', 'Premium', 810),
(12, 'James', 'Brown', 'UK', 'Manchester', 41, '2022-10-17', 'Regular', 690),
(13, 'Marie', 'Dubois', 'France', 'Paris', 30, '2024-02-11', 'Regular', 650),
(14, 'Lucas', 'Bernard', 'France', 'Lyon', 37, '2023-01-25', 'Premium', 860),
(15, 'Peter', 'Muller', 'Germany', 'Berlin', 22, '2025-03-03', 'Regular', 0),
(16, 'Marta', 'Sousa', 'Portugal', NULL, 28, '2025-01-08', 'Regular', 520),
(17, 'Thomas', 'Klein', 'Germany', 'Frankfurt', NULL, '2024-11-12', 'Regular', 480),
(18, 'Elena', 'Rossi', 'Italy', 'Milan', 34, '2024-06-15', NULL, 760);

-- Products (10 rows)
INSERT INTO dbo.Products (product_id, product_name, category, unit_price, cost_price, supplier_country) VALUES
(101, 'Laptop Pro', 'Electronics', 1200.00, 850.00, 'Germany'),
(102, 'Laptop Basic', 'Electronics', 750.00, 520.00, 'China'),
(103, 'Monitor 27', 'Electronics', 350.00, 220.00, 'China'),
(104, 'Wireless Mouse', 'Accessories', 45.00, 18.00, 'China'),
(105, 'Mechanical Keyboard', 'Accessories', 95.00, 40.00, 'Germany'),
(106, 'Office Desk', 'Furniture', 480.00, 300.00, 'Portugal'),
(107, 'Office Chair', 'Furniture', 320.00, 190.00, 'Portugal'),
(108, 'Headphones', 'Accessories', 150.00, 70.00, 'Germany'),
(109, 'Webcam', 'Electronics', 110.00, 55.00, 'China'),
(110, 'USB-C Hub', 'Accessories', 65.00, 25.00, 'China');

-- Employees (8 rows)
INSERT INTO dbo.Employees (employee_id, first_name, last_name, department, country, salary, hire_date, manager_id) VALUES
(201, 'Sarah', 'Wilson', 'Sales', 'UK', 52000, '2021-03-15', NULL),
(202, 'Pedro', 'Almeida', 'Sales', 'Portugal', 38000, '2022-06-01', 201),
(203, 'Julia', 'Meyer', 'Sales', 'Germany', 45000, '2023-01-10', 201),
(204, 'Daniel', 'Costa', 'Finance', 'Portugal', 42000, '2022-09-20', NULL),
(205, 'Laura', 'White', 'Finance', 'UK', 48000, '2021-11-08', 204),
(206, 'Mark', 'Schneider', 'IT', 'Germany', 55000, '2020-05-12', NULL),
(207, 'Tiago', 'Fernandes', 'IT', 'Portugal', 40000, '2024-02-05', 206),
(208, 'Claire', 'Martin', 'Marketing', 'France', 41000, '2023-07-17', NULL);

-- Orders (25 rows)
INSERT INTO dbo.Orders (order_id, customer_id, employee_id, order_date, status, payment_method) VALUES
(1001, 1, 202, '2025-01-05', 'Completed', 'Card'),
(1002, 2, 202, '2025-01-12', 'Completed', 'PayPal'),
(1003, 5, 203, '2025-01-18', 'Completed', 'Card'),
(1004, 3, 202, '2025-02-02', 'Cancelled', 'Card'),
(1005, 8, 203, '2025-02-11', 'Completed', 'Transfer'),
(1006, 6, 203, '2025-02-20', 'Completed', 'Card'),
(1007, 11, 201, '2025-03-01', 'Pending', 'PayPal'),
(1008, 10, 203, '2025-03-08', 'Completed', 'Transfer'),
(1009, 4, 202, '2025-03-15', 'Completed', 'Card'),
(1010, 13, 201, '2025-03-21', 'Completed', 'PayPal'),
(1011, 2, 202, '2025-04-02', 'Completed', 'Card'),
(1012, 5, 203, '2025-04-07', 'Completed', 'Transfer'),
(1013, 9, 203, '2025-04-15', 'Cancelled', 'Card'),
(1014, 14, 201, '2025-04-23', 'Completed', 'PayPal'),
(1015, 1, 202, '2025-05-04', 'Completed', 'Card'),
(1016, 6, 203, '2025-05-10', 'Pending', 'Transfer'),
(1017, 3, 202, '2025-05-18', 'Completed', 'Card'),
(1018, 12, 201, '2025-06-01', 'Completed', 'PayPal'),
(1019, 8, 203, '2025-06-09', 'Completed', 'Card'),
(1020, 2, 202, '2025-06-17', 'Completed', 'Transfer'),
(1021, 18, 203, '2025-07-03', 'Completed', 'Card'),
(1022, 7, 203, '2025-07-12', 'Cancelled', 'PayPal'),
(1023, 11, 201, '2025-07-20', 'Completed', 'Card'),
(1024, 14, 201, '2025-08-01', 'Pending', 'Transfer'),
(1025, 5, 203, '2025-08-14', 'Completed', 'Card');

-- OrderItems (41 rows)
INSERT INTO dbo.OrderItems (order_item_id, order_id, product_id, quantity, unit_price, discount_percent) VALUES
(1, 1001, 102, 1, 750.00, 0),
(2, 1001, 104, 2, 45.00, 0),
(3, 1002, 101, 1, 1200.00, 5),
(4, 1002, 105, 1, 95.00, 0),
(5, 1003, 103, 2, 350.00, 10),
(6, 1003, 108, 1, 150.00, 0),
(7, 1004, 106, 1, 480.00, 0),
(8, 1005, 101, 1, 1200.00, 0),
(9, 1005, 104, 1, 45.00, 0),
(10, 1006, 101, 2, 1200.00, 8),
(11, 1007, 107, 1, 320.00, 0),
(12, 1007, 105, 1, 95.00, 0),
(13, 1008, 102, 1, 750.00, 0),
(14, 1008, 103, 1, 350.00, 0),
(15, 1009, 104, 3, 45.00, 0),
(16, 1010, 106, 1, 480.00, 5),
(17, 1010, 107, 1, 320.00, 5),
(18, 1011, 108, 2, 150.00, 0),
(19, 1011, 109, 1, 110.00, 0),
(20, 1012, 101, 1, 1200.00, 10),
(21, 1013, 110, 2, 65.00, 0),
(22, 1014, 102, 2, 750.00, 5),
(23, 1015, 103, 2, 350.00, 0),
(24, 1015, 104, 2, 45.00, 0),
(25, 1016, 106, 2, 480.00, 10),
(26, 1017, 101, 1, 1200.00, 0),
(27, 1017, 108, 1, 150.00, 0),
(28, 1018, 107, 2, 320.00, 0),
(29, 1019, 102, 1, 750.00, 0),
(30, 1019, 105, 1, 95.00, 0),
(31, 1020, 101, 1, 1200.00, 5),
(32, 1020, 103, 1, 350.00, 0),
(33, 1021, 108, 2, 150.00, 0),
(34, 1021, 110, 1, 65.00, 0),
(35, 1022, 109, 2, 110.00, 0),
(36, 1023, 101, 1, 1200.00, 0),
(37, 1023, 104, 2, 45.00, 0),
(38, 1024, 106, 1, 480.00, 0),
(39, 1024, 107, 1, 320.00, 0),
(40, 1025, 101, 1, 1200.00, 15),
(41, 1025, 105, 1, 95.00, 0);
GO

