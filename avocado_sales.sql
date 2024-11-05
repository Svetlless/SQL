/*The data on avocado sales from the Clickhouse database are given:
    date
    average_price
    total_volume
    plu4046 — number of sold  PLU* 4046 avocados
    plu4225 — number of sold  PLU 4225 avocados
    plu4770 — number of sold  PLU 4770 avocados
    total_bags
    small_bags
    large_bags
    xlarge_bags 
    type — organic or conventional
    year
    region
The data are on the end of each week (not on each day) are presented. For each date there are several rows, for different regions and avocado types.*/ 

/*Task 1. How many organic avocados were sold by the end of each week (cumulative sum) in New York and Los Angeles from 04/01/15?*/
  SELECT date,
         region,
         SUM(total_volume) OVER w AS cumulative_sum
    FROM avocado
   WHERE (region = 'NewYork' OR region = 'LosAngeles')
         AND type = 'organic'
         AND date >= '2015-01-04'
WINDOW w AS
	    (PARTITION BY region
	    ORDER BY date ASC
	    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) --because the dataset includes the data on each week
ORDER BY region DESC, date ASC

/*Task 2. Find out when the sales (total_volume) of conventional avocados fell sharply compared to the previous week in the USA.*/

  SELECT date,
  	 region,
	 total_volume,
         total_volume - LAG(total_volume, 1) OVER w AS week_diff
    FROM avocado
   WHERE region = 'TotalUS' AND type = 'conventional'
WINDOW w AS (ORDER BY date ASC)
ORDER BY date ASC

/*Task 3. Calculate the moving average of avocado price in New York (partition by avocado type). Use the current week and previous two weeks as a window.*/

  SELECT type,
         date,
         average_price,
         AVG(average_price) OVER w AS rolling_price
    FROM avocado
   WHERE region = 'NewYork'
WINDOW w AS (PARTITION BY type
             ORDER BY date ASC
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
ORDER BY date ASC

