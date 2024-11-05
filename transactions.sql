/*The dataset retail (Clickhouse) is given –  transactions of an online store from 01-12-2010 to 09-12-2011:

    InvoiceNo – transaction number
    StockCode – item code
    Description
    Quantity – number of items in the order
    InvoiceDate
    UnitPrice
    CustomerID
    Country
	
The first task is to calculare average order value (AOV) for each country.
Please note that the order can include several identical items. 
NB! The dataset may include negative Quantity values, which means the order was canceled.*/ 

  SELECT Country,
         AVG(TotalPrice) AS Avg_Check
    FROM (
          SELECT Country,
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

/*Next we should calculate the average quantity of items in the order and the average unit price by country. The table should be ordered by average price (descending order).
Please note that the data include the rows with 'Manual' description, where the deleted positions are stored.*/
  SELECT Country,
         AVG(Quantity) AS Products,
         AVG(UnitPrice) AS Avg_Price
    FROM retail
   WHERE Description != 'Manual'
GROUP BY Country
ORDER BY Avg_Price DESC

/*Find the customer with the highest average price of the purchased products in March 2011.
Do not forget about the deleted items*/
  SELECT CustomerID,
         AVG (UnitPrice) AS Avg_price
    FROM retail
   WHERE Description != 'Manual' AND DATE_TRUNC('month', InvoiceDate) = '2011-03-01'
GROUP BY CustomerID
ORDER BY Avg_price DESC
LIMIT 1

