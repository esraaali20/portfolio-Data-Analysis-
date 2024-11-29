-- 1. Total Sales by Product and Store
-- This query calculates the total sales for each product in each store.
SELECT 
    SUM(I.list_price * I.quantity) AS totalSalesForProduct, 
    I.product_id, 
    O.store_id
FROM 
    sales.order_items AS I 
JOIN 
    sales.orders AS O ON I.order_id = O.order_id
GROUP BY 
    I.product_id, O.store_id
ORDER BY 
    totalSalesForProduct DESC;

-- 2. Top Customers Based on the Number of Orders They Have Placed
-- This query identifies the customers with the highest number of orders.
SELECT  
    COUNT(order_id) AS totalOrdersForEachCustomer,
    customer_id
FROM 
    sales.orders
GROUP BY 
    customer_id
ORDER BY 
    totalOrdersForEachCustomer DESC;

-- 3. Total Orders for Each Store on Each Day
-- This query counts the total number of orders placed in each store per day.
SELECT 
    order_date,
    COUNT(order_id) AS TotalOrdersPerDay,
    store_id
FROM 
    sales.orders
GROUP BY 
    order_date, store_id
ORDER BY 
    TotalOrdersPerDay DESC;

-- 4. Count the Number of NULL Values in the Quantity Column of the Stocks Table
-- This query counts the number of NULL values in the `quantity` column of the `stocks` table.
SELECT 
    COUNT(*) AS number_of_null_values
FROM 
    production.stocks
WHERE 
    quantity IS NULL;

-- 5. Replace Missing Values with 0 in the Quantity Column
-- This query replaces any NULL values in the `quantity` column with 0 in the `stocks` table.
UPDATE production.stocks
SET quantity = COALESCE(quantity, 0);

-- 6. Identify Duplicate CustomerID Rows
-- This query identifies customers who have placed multiple orders.
SELECT 
    customer_id, 
    COUNT(customer_id) AS number_of_orders
FROM 
    sales.orders
GROUP BY 
    customer_id
HAVING 
    COUNT(customer_id) > 1;

-- 7. Combine Orders for Customers into a Single String Column
-- This query combines the order IDs for customers who have multiple orders into a single string.
SELECT 
    customer_id, 
    COUNT(customer_id) AS number_of_orders,
    STRING_AGG(CAST(order_id AS VARCHAR), ', ') AS Combined_Orders
FROM 
    sales.orders
GROUP BY 
    customer_id
HAVING 
    COUNT(customer_id) > 1;

-- 8. Add a New Column to Store Combined Order IDs
-- This query adds a new column `Combined_Orders` to the `orders` table to store combined order IDs.
ALTER TABLE sales.orders
ADD Combined_Orders VARCHAR(50);

-- 9. Update the OrderIDs Column with Combined Order IDs for Customers
-- This query updates the `Combined_Orders` column with the combined order IDs for customers with multiple orders.
UPDATE sales.orders
SET Combined_Orders = SubQuery.Combined_Orders
FROM (
    SELECT 
        customer_id, 
        STRING_AGG(CAST(order_id AS VARCHAR), ', ') AS Combined_Orders
    FROM 
        sales.orders
    GROUP BY 
        customer_id
    HAVING 
        COUNT(customer_id) > 1
) AS SubQuery
WHERE 
    sales.orders.customer_id = SubQuery.customer_id;

-- 10. Verify the Updated Table with Combined Order IDs
-- This query verifies that the `Combined_Orders` column has been correctly updated.
SELECT *
FROM sales.orders
ORDER BY customer_id;

-- 11. Count the Number of Rows with NULL Shipped Date
-- This query counts the number of orders where the `shipped_date` is NULL.
SELECT 
    COUNT(*) AS no_shipped_date
FROM 
    sales.orders
WHERE 
    shipped_date IS NULL;

-- 12. Find the Most Frequent Shipped Date
-- This query finds the most frequently occurring shipped date.
SELECT TOP 1 
    shipped_date
FROM 
    sales.orders
WHERE 
    shipped_date IS NOT NULL
GROUP BY 
    shipped_date
ORDER BY 
    COUNT(*) DESC;

-- 13. Update NULL Shipped Date Values with the Most Frequent Shipped Date
-- This query updates the NULL `shipped_date` values with the most frequent shipped date.
UPDATE sales.orders
SET shipped_date = (
    SELECT TOP 1 
        shipped_date
    FROM 
        sales.orders
    WHERE 
        shipped_date IS NOT NULL
    GROUP BY 
        shipped_date
    ORDER BY 
        COUNT(*) DESC
)
WHERE 
    shipped_date IS NULL;

-- 14. Verify the Updated Table with Shipped Dates
-- This query checks the updated `sales.orders` table to ensure the `shipped_date` has been updated.
SELECT * 
FROM sales.orders;

-- 15. Update NULL Combined Orders Values with 0
-- This query updates the `Combined_Orders` column where it is NULL with 0.
UPDATE sales.orders
SET Combined_Orders = 0
WHERE Combined_Orders IS NULL;



-- 16. Drop the `phone` Column from the `customers` Table
-- This query drops the `phone` column from the `customers` table.
ALTER TABLE sales.customers
DROP COLUMN phone;

-- 17. Add a Full Name Column to the `customers` Table
-- This query adds a new `FullName` column to the `customers` table.
ALTER TABLE sales.customers
ADD FullName NVARCHAR(60);

-- 18. Update the Full Name Column with Concatenated First and Last Name
-- This query concatenates the `first_name` and `last_name` to create the `FullName` column in the `customers` table.
UPDATE sales.customers
SET FullName = LOWER(CONCAT(first_name, ' ', last_name));

-- 19. Select Full Name, First Name, and Last Name from the `customers` Table
-- This query selects the `FullName`, `first_name`, and `last_name` from the `customers` table.
SELECT FullName, first_name, last_name
FROM sales.customers;

-- 20. Find Products in `stocks` Table Not Present in the `products` Table
-- This query finds products in the `stocks` table that do not exist in the `products` table.
SELECT *
FROM production.stocks
WHERE product_id NOT IN (SELECT product_id FROM production.products);

-- 21. Average Revenue Per Store
-- This query calculates the average revenue for each store.
SELECT 
    O.store_id, 
    AVG(I.quantity * I.list_price) AS Average_revenue_perStore
FROM 
    sales.order_items AS I
JOIN 
    sales.orders AS O ON I.order_id = O.order_id
GROUP BY 
    O.store_id
ORDER BY 
    Average_revenue_perStore DESC;

-- 22. Number of Orders Per Month and Year
-- This query calculates the number of orders placed per month and year.
SELECT 
    YEAR(order_date) AS year, 
    MONTH(order_date) AS month, 
    COUNT(o.order_id) AS number_of_ordersPer_date
FROM 
    sales.order_items AS i
JOIN 
    sales.orders AS o ON i.order_id = o.order_id
GROUP BY 
    YEAR(order_date), MONTH(order_date)
ORDER BY 
    year, month;

-- 23. Monthly Sales by Year and Month
-- This query calculates the total sales for each month and year.
SELECT 
    YEAR(order_date) AS year, 
    MONTH(order_date) AS month, 
    SUM(I.list_price * I.quantity) AS monthly_sales
FROM 
    sales.order_items AS I
JOIN 
    sales.orders AS O ON I.order_id = O.order_id
GROUP BY 
    YEAR(order_date), MONTH(order_date)
ORDER BY 
    year, month;

-- 24. Sales for New and Old Products
-- This query categorizes products as 'New Products' or 'Old Products' based on the launch date.
SELECT 
    CASE 
        WHEN P.launch_date > '2023-01-01' THEN 'New Products'
        ELSE 'Old Products'
    END AS product_age_group,
    SUM(I.list_price * I.quantity) AS total_sales
FROM 
    sales.order_items AS I
JOIN 
    production.products AS P ON I.product_id = P.product_id
GROUP BY 
    CASE 
        WHEN P.launch_date > '2023-01-01' THEN 'New Products'
        ELSE 'Old Products'
    END
ORDER BY 
    total_sales DESC;

-- 25. Total Sales by Store
-- This query calculates the total sales for each store.
SELECT 
    store_id, 
    SUM(list_price * quantity) AS total_sales
FROM 
    sales.order_items AS I
JOIN 
    sales.orders AS O ON I.order_id = O.order_id
GROUP BY 
    store_id
ORDER BY 
    total_sales DESC;

-- 26. Low-Performing Products (Sales below a Threshold)
-- This query identifies products with sales below a specified threshold.
SELECT 
    product_id, 
    SUM(list_price * quantity) AS total_sales
FROM 
    sales.order_items
GROUP BY 
    product_id
HAVING 
    SUM(list_price * quantity) < 1000  -- Define a threshold for "underperformance"
ORDER BY 
    total_sales ASC;

-- 27. Low-Performing Stores (Sales below a Threshold)
-- This query identifies stores with sales below a specified threshold.
SELECT 
    store_id, 
    SUM(list_price * quantity) AS total_sales 
FROM 
    sales.order_items AS I
JOIN 
    sales.orders AS O ON I.order_id = O.order_id
GROUP BY 
    store_id
HAVING 
    SUM(list_price * quantity) < 5000  -- Define a threshold
ORDER BY 
    total_sales ASC;

-- 29. Product Performance by Region (Sales for Each Product per Store by City)
-- This query calculates total sales for each product in each store by city.
SELECT 
    P.product_id,
    P.product_name, 
    O.store_id,
    S.city,  
    SUM(I.list_price * I.quantity) AS product_sales_in_city
FROM 
    sales.order_items AS I
JOIN 
    sales.orders AS O ON I.order_id = O.order_id
JOIN 
    sales.stores AS S ON O.store_id = S.store_id
JOIN 
    production.products AS P ON I.product_id = P.product_id
GROUP BY 
    P.product_id, P.product_name, O.store_id, S.city
ORDER BY 
    product_sales_in_city DESC;









