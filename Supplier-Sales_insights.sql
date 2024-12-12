use supply_chain; 

-- 1. List the products whose name starts with C
Select * from Product where PRoductName LIKE 'C%'; 

-- 2.  Which products have the highest sales volume based on order item quantity?
Select p.ProductName , o.ProductID, 
	sum(o.Quantity) AS Total_sales
	from orderitem o
	INNER JOIN product p
        ON o.ProductID = p.ID
	GROUP BY o.ProductID
    ORDER by Total_sales DESC ; 

Select ProductID, sum(quantity) AS Total_sales 
	from orderitem 
    GROUP BY ProductID 
    ORDER by Total_sales DESC;


-- 3. Find the customer who has least total amount spent 
Select CustomerID , sum(TotalAmount) as Totalamt
	from orders
    GROUP BY CustomerID
    ORDER BY Totalamt ASC LIMIT 1  ; 
		
        
-- 4. Find the customer who has highest total amount spent 
Select CustomerID, sum(TotalAmount) AS Totalamt
	from orders
    GROUP by CustomerID
    ORDER by Totalamt DESC LIMIT 1 ;
          
-- 5. Determine how often customers place orders and identify patterns in their ordering behavior.
Select CustomerID, monthname(OrderDate) AS Month_name, 
	count(OrderDate) AS Number_of_orders
    from orders
    GROUP BY customerId, Month_name  ; 


-- 6. Calculate the total amount spent by each customer over their lifetime and identify high-value customers. 
Select o.CustomerID,  o.orderNumber , concat(c.FirstName, " " , c.LastName) as Customer_Name,
	sum(TotalAmount) as Total_Amt_Spent 
	from orders o
    INNER JOIN customer c
		on o.CustomerID = c.ID
    GROUP BY o.CustomerID, o.orderNumber
    ORDER BY Total_Amt_Spent DESC ;
   
   
-- 7. Divide customers into groups based on their total purchase amount (e.g., high spenders, average spenders, low spenders).
Select o.CustomerID, concat(c.FirstName, " " , c.LastName) as Customer_Name,
	   sum(o.TotalAmount) as Total_Amt_Spent,
       CASE
			when sum(TotalAmount) > 18000 then 'High Spenders'
            when sum(TotalAmount) < 5000 then 'Low Spenders'
            else 'Average Spenders'
            END AS Spend_Category
	   from orders o
       INNER JOIN customer c
			ON o.CustomerID = c.ID
	   GROUP BY CustomerID ;
       
Select o.CustomerID, concat(c.FirstName, " " , c.LastName) as Customer_Name,
	   sum(o.TotalAmount) as Total_Amt_Spent,
       if(sum(TotalAmount) > 18000 , 'High Spenders',
			if(sum(TotalAmount) < 5000 , 'Low Spenders', 'Average Spenders' ) 
		  ) as Spend_Category       
	   from orders o
       INNER JOIN customer c
			ON o.CustomerID = c.ID
	   GROUP BY CustomerID ;
       
	
-- 8. Determine the effectiveness of discounts on product sales.
WITH Product_Sales as (Select p.ProductName, 			
	   ((p.UnitPrice - o.UnitPrice)/p.UnitPrice) * 100 AS Discount_Percent,
       sum(Quantity) as Quantity_ordered
       from product p INNER JOIN
       orderitem o 
       on o.ProductID = p.ID 
       GROUP BY p.ProductName, Discount_Percent )
Select * from Product_Sales ;   


-- 9. From which cites do the customers order the least. Display 5 cities with least orders
Select c.city,c.country, count(o.ID) AS Num_of_orders
	from customer c
    INNER JOIN orders o 
		ON o.customerID = c.ID 
	GROUP BY c.city, c.country
    ORDER BY Num_of_orders ASC LIMIT 5 ; 
    
    
-- 10. Identify common combinations of products ordered together. 
Select o.CustomerID, o.orderNumber, p.ProductName, o.orderDate
	from orders o  
	INNER JOIN orderitem oi 
		ON oi.orderID = o.ID
	INNER join product p 
		ON oi.ProductID = p.ID 
	GROUP BY o.CustomerID, o.orderNumber , p.ProductName, o.orderDate 
	ORDER BY o.CustomerID ; 
    
SELECT 
	p1.ProductName AS Product1, 
    p2.ProductName AS Product2, 
    COUNT(*) AS CombinationCount
    FROM orders o
    INNER JOIN orderitem oi1 ON oi1.orderID = o.ID
    INNER JOIN orderitem oi2 ON oi2.orderID = o.ID AND oi1.ProductID < oi2.ProductID  -- Ensure unique pairs
    INNER JOIN product p1 ON oi1.ProductID = p1.ID
    INNER JOIN product p2 ON oi2.ProductID = p2.ID
    GROUP BY p1.ProductName, p2.ProductName
    HAVING COUNT(*) > 1  -- Filter to show pairs that occur more than once
    ORDER BY CombinationCount DESC;

    
-- 11. Rank products based on their total order quantity using window functions.
Select p.ProductName , oi.ProductID , sum(oi.quantity) AS Total_quantity,
	RANK() OVER(ORDER BY sum(oi.quantity) DESC) Product_rank
	from orderitem oi 
    INNER JOIN product p
		ON oi.ProductID = p.ID 
	GROUP BY oi.ProductID ; 
    
-- 12. Rank products based on their sales performance ?
Select p.ID , p.ProductName , 
	sum(o.quantity * o.UnitPrice) AS Total_Sales_prod
    from orderitem o INNER JOIN product p ON
	p.ID  = o.ProductId 
    GROUP BY p.ID
    ORDER BY Total_Sales_prod DESC
     ;
     
Select ID , ProductName , Total_Sales_prod,
	RANK() Over(Order by Total_Sales_prod DESC) AS Product_Rank
    from 
    ( Select p.ID , p.ProductName , 
	sum(o.quantity * o.UnitPrice) AS Total_Sales_prod
    from orderitem o 
	INNER JOIN product p 
		ON p.ID  = o.ProductId
    GROUP BY p.ID
     ) Sales;
     
 
-- 13. Identify customers who have stopped placing orders using window functions and calculating the time since their last purchase.
Select c.FirstName , o.TotalAmount, c.ID, o.OrderDate  -- Using RIGHT JOIN
	from orders o 
    RIGHT JOIN customer c 
		ON c. ID = o.CustomerID 
	WHERE o.TotalAmount IS NULL ; 

Select c.FirstName , o.TotalAmount, c.ID, o.OrderDate  -- Using LEFT JOIN
	from customer c
    left JOIN  orders o 
		ON c. ID = o.CustomerID 
	WHERE o.TotalAmount IS NULL ; 

Select * from orders where CustomerID in (57,22) ;
Select * from customer where ID IN (57,22) ; 


-- Analyze the sales performance of products over time and identify any trends or seasonality.
-- 14. Calculate the average Amount over the time?
Select extract(year from orderDate)  as Order_Year, extract(Month from orderDate) as Order_Month,
	avg(TotalAmount) as Avg_Amount
	from orders 
    GROUP BY Order_Year , Order_Month ;
    

-- 15. Calculate the number of order per month over the time?
Select extract(year from orderDate)  as Order_Year, extract(Month from orderDate) as Order_Month,
	count(ID) as Number_of_orders
	from orders 
    GROUP BY Order_Year, Order_Month ; 
    
-- 16. Find the percentage of total sales contributed by each product?        
Create VIEW Sales AS
	Select p.ID , p.productName,  sum(oi.UnitPrice * oi.quantity) AS Total_Sales_product 
    from product p 
    INNER JOIN orderitem oi
		ON p.ID = oi.ProductID
	GROUP BY p.ID; 
        
Select * from Sales ; 
Select ID, productName, Total_Sales_product ,
	(Total_Sales_product/Sum(Total_Sales_product) OVER( )) * 100 AS Percentage_Sales_product
    from Sales ;  
    
Select p.ID , p.productName,  sum(oi.UnitPrice * oi.quantity) AS Total_Sales_product,   -- Without creating VIEW
	(sum(oi.UnitPrice * oi.quantity)/ SUM(sum(oi.UnitPrice * oi.quantity)) OVER()) * 100 AS Percentage_contribution
    from product p 
    INNER JOIN orderitem oi
		ON p.ID = oi.ProductID
	GROUP BY p.ID; 
        
-- 17. Identify customers who have not placed an order in the last 6 months?
-- Data set contains data for year 2012, 2013 and 2014
Select c.ID , concat(c.Firstname , " " , c.LastName) AS F_Name ,   
	extract(Year from o.orderDate) as Order_year , 
    extract(Month from o.orderDate) AS Order_Month, o.TotalAmount
    from orders o
    RIGHT JOIN customer c 
		ON c.ID = o.CustomerID
	WHERE o.orderDate > ('2014-05-06' - INTERVal 6 month) and o.TotalAmount IS NULL ;  
    
    
-- 18. Running Total Sales of each month
Select  extract(Year from orderDate) AS Ord_Year, Month(orderDate) AS Ord_Month,
	sum(TotalAmount)
	from orders
	GROUP by Ord_Year, Ord_Month ;  -- this is just for tally
    
Select Ord_Year, Ord_month, Total_amount,
	sum(Total_amount) OVER(ROWS between unbounded preceding and current row) As Running_Total
	from (
	Select DISTINCT extract(Year from orderDate) AS Ord_Year,     
		Month(orderDate) AS Ord_Month,
		sum(TotalAmount) as Total_amount
		from orders  
		GROUP BY Ord_Year , Ord_Month ) Sale_by_month;
	
    
-- 19. Identify top 3 products sold each month
WITH Top3_products AS(
Select Year(o.orderDate) AS Year_s , month(o.orderDate) as Month_s , p.ProductName , sum(oi.Quantity),
	Rank( ) OVER(Partition by Year(o.orderDate) , Month(o.orderDate) ORDER by sum(oi.Quantity) DESC) AS top_3
    from product p
    INNER JOIN orderitem oi
		ON oi.ProductID = p.ID
    INNER JOIN orders o
		ON o.ID = oi.orderID   
	GROUP BY Year(o.orderDate), Month(o.orderDate), p.ProductName
	ORDER BY Year(o.orderDate), Month(o.orderDate), SUM(oi.Quantity) DESC )
Select * from Top3_products where top_3 <= 3 ;
		

-- 20. Identify the top 10% of customers based on their total spending?    
WITH TopSales2 AS (
	Select NTILE(10) OVER(ORDER BY sum(o.TotalAmount) DESC) AS top_group,
	c.Id, c.Firstname , c.City, sum(o.TotalAmount) as Total_Amt
    from customer c 
    INNER JOIN orders o 
		ON c.ID = o.CustomerID
	GROUP BY c.ID 
	ORDER BY sum(o.TotalAmount) DESC ) 
Select * from TopSales2  
	WHERE top_group = 1 ; 
    
    
-- 21. Calculate the year-over-year growth in sales for each product?
Create VIEw Sales_each_product AS 
	Select p.Id , p.ProductName, o.OrderDate, o.TotalAmount
    from product p 
    INNER JOIN orderitem oi
		ON p.ID = oi.ProductID
	INNER JOIN orders o
		ON o.ID = oi.OrderID ; 
    
WITH sales_year_1 AS ( 
	Select ID , ProductName, sum(TotalAmount) as year_2012_sales
		from Sales_each_product
        WHERE YEAR(orderDate) = 2012
        GROUP BY ID, ProductName
),
sales_year_2 AS (
	Select ID , ProductName, sum(TotalAmount) as year_2013_sales
		from Sales_each_product
        WHERE YEAR(OrderDate) = 2013
        Group By ID, ProductName
),
sales_year_3 AS (
	Select ID, ProductName , sum(TotalAmount) as year_2014_sales
		from Sales_each_product
        WHERE Year(OrderDate) = 2014
        Group BY id, ProductName
) 
Select 
    y2.ID,  
    y2.ProductName, 
    y1.year_2012_sales, 
    y2.year_2013_sales, 
    y3.year_2014_sales,
    ((y2.year_2013_sales - y1.year_2012_sales) / y1.year_2012_sales) * 100 AS Year_growth_from_2012_to_2013,
    ((y3.year_2014_sales - y2.year_2013_sales) / y2.year_2013_sales) * 100 AS Year_growth_from_2013_to_2014
FROM 
    sales_year_2 y2
JOIN 
    sales_year_1 y1 ON y1.ID = y2.ID 
JOIN 
    sales_year_3 y3 ON y3.ID = y2.ID;
 
-- 22. Find the Sales growth rate per month    
WITH Monthly_Sales AS(
Select Year(o.orderDate) AS Year_s , Month(o.orderDate) as Month_s , sum(o.TotalAmount) AS TotalRevenue
    from product p 
    INNER JOIN orderitem oi
		ON oi.ProductID = p.ID
	INNER JOIN orders o
		ON o.ID = oi.orderID 
	GROUP BY Year_s , Month_s
)    
Select Year_s, Month_s, TotalRevenue,
	TotalRevenue - LAG(TotalRevenue, 1, 0) OVER( ) AS Monthy_Sale_Rate
    from Monthly_Sales; 
    

-- 23. Find products that have not been sold in the last year 
Select DISTINCT ID, ProductName 
	from product
	WHERE ID NOT IN 
		(Select distinct p.ID -- ,p.ProductName -- , l.year_order
		from product p 
		INNER JOIN orderitem oi
			ON oi.ProductID = p.ID
		RIGHT JOIN
			(Select ID   -- , YEAR(orderDate) as year_order
			from orders
			WHERE YEAR(orderDate) = 2014 ) AS l
		ON l.ID = oi.OrderID ) ;
     
-- to verify above command comparing the total number of products and number of products ordered in 2024
Select DISTINCT count(ProductName) from product ;  
Select distinct p.ProductName, l.year_order    -- gives product name that were used in 2014
	from product p 
	INNER JOIN orderitem oi
		ON oi.ProductID = p.ID
	RIGHT JOIN
		(Select ID, YEAR(orderDate) as year_order
        from orders
		WHERE YEAR(orderDate) = 2014 ) AS l 
	ON l.ID = oi.OrderID;
    
    
-- 24. List the number of products supplied by each supplier
Select s.CompanyName , count(p.ProductName) AS Product_count
	from product p 
    INNER join supplier s
		ON s.ID = p.SupplierID 
	GROUP by s.companyName 
    ORDER by Product_count DESC; 
        
-- 25. How many orders for each city
Select c.country, c.city, count(o.orderNumber) AS num_of_orders
	from customer c
    INNER JOIN orders o
		ON o.CustomerID = c.ID
	GROUP by c.country, c.city
    ORDER by num_of_orders DESC ; 
    
    
-- 26. Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved.
-- Refer actual product price in product table and selling price in the order item table.
Select o.orderID , sum((p.UnitPrice- o.UnitPrice) * o.Quantity) as amount_saved
    from product p
    INNER JOIN orderitem o
		ON o.ProductID = p.ID  
	GROUP BY o.orderID
	ORDER BY amount_saved DESC ;
    
-- 27. Find out for which products, UK is dependent on other countries for the supply. List the countries which are supplying these products in the same list.
WITH Product_list AS (
	Select p.productName, s.Country As supplier_country,  c.Country AS Coustomer_country 
		from supplier s
        INNER JOIN product p
			ON p.SupplierID = s.ID
		INNER JOIN orderitem oi
			ON oi.ProductID = p.ID
		INNER JOIN orders o
			ON o.ID = oi.orderID
		INNER JOIN customer c
			ON c.ID = o.customerID 
		where c.country LIKE 'UK' )
Select * from Product_list ;

    
