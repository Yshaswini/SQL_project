use supply_chain ;

-- 1.	Company sells the product at different discounted rates. Refer actual product price in product table and selling price in the 
-- order item table. Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved.
Select oi.orderId, o.orderDate, sum((p.unitPrice - oi.UnitPrice)* oi.Quantity) as Total_amount_Saved
	from product p join orderitem oi 
		on p.id = oi.ProductId
	join orders o 
		on o.Id = oi.OrderId
	group by oi.orderId
	order by Total_amount_Saved DESC ;
 
 
-- 2.	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
-- 		a. List few products that he should choose based on demand.
SELECT 
    p.Id AS ProductId, p.ProductName, SUM(oi.Quantity) AS Total_Quantity_Ordered
	FROM orderitem oi JOIN product p 
		ON oi.ProductId = p.Id
	GROUP BY p.Id, p.ProductName
	ORDER BY Total_Quantity_Ordered DESC
	LIMIT 10; 

-- 		b. Who will be the competitors for him for the products suggested in above questions.
WITH TopProducts AS (
    SELECT p.Id FROM orderitem oi
    JOIN product p 
		ON oi.ProductId = p.Id
    GROUP BY p.Id
    ORDER BY SUM(oi.Quantity) DESC
    LIMIT 10
)
SELECT p.ProductName, s.CompanyName AS Supplier, s.ContactName, s.Country
	FROM product p JOIN supplier s 
		ON p.SupplierId = s.Id
	JOIN TopProducts tp 
		ON p.Id = tp.Id
	ORDER BY p.ProductName, s.CompanyName;
    
-- 3.	Create a combined list to display customers and suppliers details considering the following criteria 
-- 		●	Both customer and supplier belong to the same country
-- 		●	Customer who does not have supplier in their country
-- 		●	Supplier who does not have customer in their country
SELECT 
    'Customer' AS Type,
    c.Id AS Id, c.FirstName AS Name, c.LastName AS Surname, c.City AS City, c.Country AS Country, c.Phone AS Phone
	FROM customer c JOIN supplier s 
		ON c.Country = s.Country
UNION ALL
    SELECT 
    'Customer' AS Type, c.Id AS Id, c.FirstName AS Name, c.LastName AS Surname, c.City AS City, c.Country AS Country, c.Phone AS Phone
	FROM customer c LEFT JOIN supplier s 
		ON c.Country = s.Country
	WHERE s.Id IS NULL
UNION ALL
	SELECT 
    'Supplier' AS Type, s.Id AS Id, s.CompanyName AS Name, s.ContactName AS Surname, 
	 s.City AS City, s.Country AS Country, s.Phone AS Phone
	FROM supplier s LEFT JOIN customer c 
		ON s.Country = c.Country
	WHERE c.Id IS NULL;

-- 4.	Every supplier supplies specific products to the customers. Create a view of suppliers and total sales made by their products 
-- and write a query on this view to find out top 2 suppliers (using windows function) in each country by total sales done by the products.
CREATE VIEW SupplierSales AS
	SELECT 
		s.Id AS SupplierId, s.CompanyName AS SupplierName, s.Country,
		SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
	FROM supplier s JOIN product p 
		ON s.Id = p.SupplierId
	JOIN orderitem oi 
		ON p.Id = oi.ProductId
	GROUP BY s.Id, s.CompanyName, s.Country;

Select * from SupplierSales ; 

WITH RankedSuppliers AS (
    SELECT SupplierId, SupplierName, Country,TotalSales,
        ROW_NUMBER() OVER (PARTITION BY Country ORDER BY TotalSales DESC) AS rank1
    FROM SupplierSales
)
SELECT SupplierId, SupplierName, Country, TotalSales 
FROM RankedSuppliers
WHERE rank1 <= 2
ORDER BY Country, rank1;

-- 5.	Find out for which products, UK is dependent on other countries for the supply. List the countries which are supplying these 
-- products in the same list.
WITH UK_SuppliedProducts AS (
    SELECT DISTINCT p.Id AS ProductId, p.ProductName
		FROM product p JOIN supplier s 
			ON p.SupplierId = s.Id
		WHERE s.Country = 'UK' ),
UK_CustomerProducts AS (
    SELECT DISTINCT p.Id AS ProductId, p.ProductName
		FROM product p JOIN orderitem oi 
			ON p.Id = oi.ProductId
		JOIN orders o 
			ON oi.OrderId = o.Id
		JOIN customer c 
			ON o.CustomerId = c.Id
		WHERE c.Country = 'UK'),
DependentProducts AS (
    SELECT cp.ProductId, cp.ProductName
		FROM UK_CustomerProducts cp	LEFT JOIN UK_SuppliedProducts sp 
			ON cp.ProductId = sp.ProductId
		WHERE sp.ProductId IS NULL
)
SELECT 
    dp.ProductName, s.Country AS Supplying_Country
	FROM DependentProducts dp JOIN product p 
		ON dp.ProductId = p.Id
	JOIN supplier s 
		ON p.SupplierId = s.Id
	WHERE s.Country != 'UK'
	ORDER BY dp.ProductName, s.Country;