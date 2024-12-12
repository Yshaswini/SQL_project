# SQL_project

**Supplier-Sales data Analysis using SQL**

“Richard’s Supply” is a company which deals with different food products. The company is associated with a pool of suppliers. Every Supplier supplies different types of food products to Richard’s supply. This company also receives orders for the food products from various customers. Each order may have multiple products mentioned along with the quantity. The company has been maintaining the database for year 2012,2013 and 2014. 

This dataset has 5 tables. Each tables has relationship with each other. The UnitPrice in product table is the Marked Price of the product and the UnitPrice in orderitem specifies the selling price of the product.

**Description of schema:**
1. **Supplier** - has supplier details and contact information. UNIQUE identifer is ID. <br>
2. **Product** - has Product name and Marked price details. UNIQUE identifer is 'ID', 'SupplierID' is the foreign key refering the 'ID' Column in supplier table. <br>
3. **orderitem** - has Selling price and Quantity sold details. UNIQUE identifer is 'ID', 'ProductID' is the foreign key refering the 'ID' Column in product table, 'OrderID' is the foreign key refering the 'ID' Column in orders table. <br>
4. **orders** - has customer ID and total amount. UNIQUE identifer is 'ID', 'CustomerID' is the foreign key refering the 'ID' Column in Customer table. <br>
5. **customer** - has customer details. UNIQUE identifer is 'ID'.

Analyzed Supplier-Sales data and generated insights using JOINS, aggregate functions, GROUP BY, WHERE, HAVING clauses, string pattern matching, and advanced window functions (CTEs, RANK, ROW) in conjunction with VIEWS.

Execute the SQL files in the sequence given below.
1.	1_DDL_Case Study
2.	2_Data
3.	3_Data Constraints





