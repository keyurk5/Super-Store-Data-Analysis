-- Super Store Analysis
-- Analytical Thinking exercise using SQL

-- 1) Get top region with employee name in sales.

Create View TopRegionsWithSales
AS
(Select p.Person,o.Region, Round(Sum(o.Sales),2) as Total_Sales
FROM Orders o
INNER JOIN People p
ON o.Region = p.Region
Group by o.Region,p.Person)

Select * from TopRegionsWithSales

-- 2) Percentage Revenue per year

Declare @Total_Sales int
SET @Total_Sales = (Select Sum(Sales) From Orders)

Select datepart(year,[Order Date]) as yearly, Round((SUM(Sales)/@Total_Sales) * 100,2) as Percent_Total_Sales
FROM Orders
Group BY datepart(year,[Order Date])
ORDER BY Percent_Total_Sales DESC

-- 3) Percentage Revenue per Sub-category of products

Declare @Total_Sales int
SET @Total_Sales = (Select Sum(Sales) From Orders)

Select [Sub-Category], Round((SUM(Sales)/@Total_Sales) * 100,2) as Percent_Total_Sales
FROM Orders
Group BY [Sub-Category]
ORDER BY Percent_Total_Sales DESC

-- 4) Average Basket Size per year

Select Datepart(year,[Order Date]) as Yearwise,Round(SUM(quantity)/COUNT([Order Id]),3) as AvgBasketSize
FROM Orders
GROUP BY Datepart(year,[Order Date])
ORDER BY AvgBasketSize DESC

-- 5) Average Order Value Per year
Select Datepart(year,[Order Date]) as Yearwise, Round(SUM(Sales)/SUM(quantity),2) as AOV
FROM Orders
GROUP BY Datepart(year,[Order Date])
ORDER BY AOV DESC

-- 6) Get subcategory names with max returns of products.

Select o.[Sub-Category], COUNT(o.[Order ID]) as NumberOfReturns
From Orders o
INNER JOIN Returns r
ON o.[Order ID] = r.[Order ID]
Where r.Returned = 'Yes'
Group By [Sub-Category]
ORDER BY NumberOfReturns DESC

-- 7) Yearly, monthly, quarterly sales.

Drop View if exists yearly_sales
Create view yearly_sales
AS
(Select Datepart(year,[Order Date]) as Yearwise, Round(SUM(Sales),2) as Total_Sales
FROM Orders
GROUP BY Datepart(year,[Order Date])
)

Drop View if exists monthly_sales
Create view monthly_sales
AS
(Select DateName(month,[Order Date]) as Monthwise, Round(SUM(Sales),2) as Total_Sales
FROM Orders
GROUP BY DateName(month,[Order Date])
)

Drop View if exists quarterly_sales
Create View quarterly_sales
AS
(Select Datepart(quarter,[Order Date]) as Quarterwise, Round(SUM(Sales),2) as Total_Sales
FROM Orders
GROUP BY Datepart(quarter,[Order Date])
)

Select * from yearly_sales
Select * from monthly_sales
Select * from quarterly_sales

-- 8) Top 10 profit gaining customers for Customer loyalty program.

Select Top 10 [Customer ID], [Customer Name], Profit
FROM Orders
Order by Profit Desc

-- 9) Average ship days per ship mode

Select [Ship Mode],AVG(Datediff(day,[Order Date],[Ship Date])) as MaxShipDays
From Orders
Group by [Ship Mode]
ORDER BY MaxShipDays DESC

-- 10) 
--		1) Lets create stored procedures to get Sales per region 
--			input - Region.
--		2) Stored Procedure to get Daily report of sales
--          input - Date (DD-MM-YYYY)

Create Procedure GetSalesForRegion
@Reg nvarchar(10)
AS
(Select Region, Round(Sum(Sales),2) as Total_Sales
FROM Orders
Where Region = @Reg
Group by Region)

EXEC GetSalesForRegion 'Central'

Create Procedure GetSalesForSingleDay
@Date Date
AS
(Select CAST([Order Date] as Date) as OrderDate, Round(Sum(Sales),2) as Total_Sales
FROM Orders
Where [Order Date] = @Date
Group by [Order Date])

-- use DD-MM-YYYY format
Exec GetSalesForSingleDay '10-09-2017'
