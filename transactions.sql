/*The dataset retail (Clickhouse) is given –  transactions of an online store from 01-12-2010 to 09-12-2011:

    InvoiceNo – transaction number
    StockCode – item code
    Description
    Quantity – number of items in the order
    InvoiceDate
    UnitPrice
    CustomerID
    Country
	
The first task is to calculate average order value (AOV) for each country.
Please note that the order can include several identical items. 
NB! The dataset may include negative Quantity values, which means the order was canceled.*/ 

  SELECT Country,
         AVG(TotalPrice) AS Avg_Check
    FROM ( SELECT Country,
                  SUM(UnitPrice*Quantity) AS TotalPrice,
                  InvoiceNo
             FROM retail
            WHERE Quantity > 0
         GROUP BY InvoiceNo, Country)
GROUP BY Country

/*The next task is to find top-5 countries based on revenue.
The table should be ordered by revenue (descending order).*/
  SELECT Country,
         SUM(UnitPrice * Quantity) AS Revenue
    FROM retail
GROUP BY Country
ORDER BY Revenue DESC
LIMIT 5

/*Next we should calculate the average quantity of items in the order and the average unit price by country. The table should be ordered by average price (descending order).*/
  SELECT Country,
         AVG(Quantity) AS Products,
         AVG(UnitPrice) AS Avg_Price
    FROM retail
GROUP BY Country
ORDER BY Avg_Price DESC

/*Find the customer with the highest average price of the purchased products in March 2011.*/
  SELECT CustomerID,
         AVG (UnitPrice) AS Avg_price
    FROM retail
   WHERE InvoiceDate >= '2011-03-01' AND InvoiceDate < '2011-04-01'
GROUP BY CustomerID
ORDER BY Avg_price DESC
LIMIT 1

/*Identify top-3 products for each country by revenue */
  WITH RankedProducts AS (
         SELECT Description,
                Country,
                SUM(Quantity * UnitPrice) AS Revenue,
                ROW_NUMBER() OVER (PARTITION BY Country ORDER BY SUM(Quantity * UnitPrice) DESC) AS rn
           FROM retail
       GROUP BY Description, Country)
SELECT Description,
       Country,
       Revenue
  FROM RankedProducts
 WHERE rn <= 3

/*Calculate MAU for each country */
  SELECT Country,
         EXTRACT(YEAR FROM InvoiceDate) AS year,
         EXTRACT(MONTH FROM InvoiceDate) AS month,
         COUNT (DISTINCT CustomerID) AS MAU
    FROM retail
   WHERE InvoiceNo IS NOT NULL AND InvoiceDate<'2011-12-01' -- the data for December 2011 is available only for December 1-9
GROUP BY Country, EXTRACT(YEAR FROM InvoiceDate), EXTRACT(MONTH FROM InvoiceDate)
ORDER BY year DESC, month DESC