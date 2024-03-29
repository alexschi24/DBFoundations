--*************************************************************************--
-- Title: Assignment06
-- Author: ShaunaeAlex
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-02-21,ShaunaeAlex,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ShaunaeAlex')
	 Begin 
	  Alter Database [Assignment06DB_ShaunaeAlex] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ShaunaeAlex;
	 End
	Create Database Assignment06DB_ShaunaeAlex;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ShaunaeAlex;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View vCategories
With Schemabinding
As
  Select CategoryID, CategoryName From dbo.Categories;
GO
Select * From vCategories

Create View vProducts
With Schemabinding
As
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
GO
Select * From vProducts

Create View vEmployees
With Schemabinding
As
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
GO
Select * From vEmployees

Create View vInventories
With Schemabinding
As
  Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] From dbo.Inventories;
GO
Select * From vInventories

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

Deny Select on Inventories to Public;
Grant Select On vInventories to Public;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View vProductsbyCategories
As 
Select Top 100000 CategoryName, ProductName, UnitPrice
FROM dbo.Categories
JOIN Products On Categories.CategoryID = Products.CategoryID
Order By CategoryName, ProductName; 
GO
Select * From vProductsbyCategories

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View vInventoriesByProductsByDates
As
Select Top 10000 ProductName, InventoryDate, [Count]
FROM dbo.Products
JOIN Inventories On Products.ProductID = Inventories.ProductID
Order By ProductName, InventoryDate, [Count];
GO
Select * From vInventoriesByProductsByDates


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create View vInventoriesByEmployeesByDates
As
Select Distinct Top 10000
InventoryDate,
[EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
FROM Inventories 
Left Join Employees 
ON Inventories.EmployeeID = Employees.EmployeeID
Order By InventoryDate;
GO
Select * From vInventoriesByEmployeesByDates

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View vInventoriesByProductsByCategories
As
Select Top 10000
CategoryName, ProductName, InventoryDate, [Count]
FROM Categories
Left Join Products
ON Categories.CategoryID = Products.CategoryID
Left Join Inventories
ON Products.ProductID = Inventories.ProductID
Order by CategoryName, ProductName, InventoryDate, [Count]
GO
Select * From vInventoriesByProductsByCategories

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vInventoriesByProductsByEmployees
As
Select Top 10000
CategoryName, ProductName, InventoryDate, [Count], [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
FROM Categories
Left Join Products
ON Categories.CategoryID = Products.CategoryID
Left Join Inventories
ON Products.ProductID = Inventories.ProductID
Left Join Employees
ON Inventories.EmployeeID = Employees.EmployeeID
Order by InventoryDate, CategoryName, ProductName, [EmployeeName];
GO
Select * From vInventoriesByProductsByEmployees

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vInventoriesForChaiAndChangByEmployees
As
Select Top 10000
CategoryName, ProductName, InventoryDate, [Count], [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
FROM Categories
Left Join Products
ON Categories.CategoryID = Products.CategoryID
Left Join Inventories
ON Products.ProductID = Inventories.ProductID
Left Join Employees
ON Inventories.EmployeeID = Employees.EmployeeID
Where Inventories.ProductID in (Select ProductID From Products Where ProductName In ('Chai', 'Chang'))
Order by InventoryDate, CategoryName, ProductName, [EmployeeName];
GO
Select * From vInventoriesForChaiAndChangByEmployees


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View vEmployeesByManager
As
Select Top 10000
Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName as Manager,
Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName as Employee
FROM Employees as Emp
Join Employees as Mgr
ON Emp.ManagerID = Mgr.EmployeeID
Order by Manager, Employee;
GO
Select * From vEmployeesByManager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create View vInventoriesByProductsByCategoriesByEmployees
As
Select Top 10000
vCategories.CategoryID, 
vCategories.CategoryName, 
vProducts.ProductID, 
vProducts.ProductName, 
vProducts.UnitPrice, 
vInventories.InventoryID, 
vInventories.InventoryDate, 
vInventories.[Count], 
Emp.EmployeeID, 
Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName as Employee,
Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName as Manager
FROM vCategories
Inner Join vProducts
ON vCategories.CategoryID = vProducts.CategoryID
Inner Join vInventories
ON vProducts.ProductID = vInventories.ProductID
Inner Join vEmployees as Emp
ON vInventories.EmployeeID = Emp.EmployeeID
Inner Join vEmployees as Mgr
ON Emp.ManagerID = Mgr.EmployeeID
Order By CategoryName, ProductName, InventoryID, Employee;
Select * From vInventoriesByProductsByCategoriesByEmployees

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/