/*The following datasets are given:

1. listings:
    review_scores_rating – rating based on reviews
    reviews_per_month
    id – ad ID
	host_response_rate
	host_is_superhost – whether the host is superhost (f - host, t - superhost)
	host_id
    id – housing id
    price – price per night
    room_type – room type (e.g. 'Private room')
    latitude
    longitude
	
2. calendar_summary – information about the availability and price of a particular housing by day:

    listing_id  – housing id
    date
    available(t/f)
    price – price per night

3. reviews – отзывы

    listing_id
    id – review ID
    date – review date
    reviewer_id
    reviewer_name
    comments – review*/
	
/*First, leave only those ads where the review score is above average and the number of reviews per month is less than three.
Then sort the two columns in descending order: first by the number of reviews per month, then by the score. Review_score_rating is a string*/

  SELECT toFloat64OrNull (review_scores_rating) AS rating,
         reviews_per_month,
         id
    FROM listings
   WHERE toFloat64OrNull (review_scores_rating) >
         (SELECT AVG(toFloat64OrNull(review_scores_rating))
	        FROM listings)
        AND reviews_per_month < 3
ORDER BY reviews_per_month DESC, rating DESC

/*Let's have a look at the average response rate among hosts (f) and superhosts (t).
The response rate values are stored as strings and include the % sign, which should be replaced with an empty space ('').
Each host_id has only one unique response rate value, as well as one single superhost mark. Order the table by average response rate (descending order)*/

 SELECT AVG(toInt32OrNull(replaceAll(host_response_rate, '%', ''))) AS average_response_rate,
        host_is_superhost
   FROM (SELECT DISTINCT
               host_is_superhost,
		       host_id,
		       host_response_rate
          FROM listings)
GROUP BY host_is_superhost
ORDER BY average_response_rate DESC


/*Calculate the average price per night for each host (one host can have several listings).
Combine the housing IDs into a separate array.
Sort the table by average price and host id (descending order).
Price is a string with a $ sign*/

  SELECT host_id,
         groupArray(id),
         AVG(toFloat32OrNull(replaceRegexpAll(price, '[$,]', ''))) AS avg_price
    FROM listings
GROUP BY host_id
ORDER BY avg_price DESC, host_id DESC

/*Identify which of the private rooms is closest to the Berlin city center
Berlin center location: 52.5200 latitude, 13.4050 longitude*/

  SELECT id,
         geoDistance(13.4050, 52.5200, toFloat64OrNull(longitude), toFloat64OrNull(latitude)) AS distance
    FROM listings
   WHERE room_type = 'Private room'
ORDER BY distance ASC
   LIMIT 1


/*Find those available listings in the calendar_summary table that have a higher than average number of reviews from unique users in the reviews table.
To simplify the task, we will assume that a review is a unique visitor's review to a unique listing, without taking into account possible repeated reviews from the same visitor.
Sort the result by listing_id (ascending) and limit the output to the first row.*/

  WITH AvgReviews AS (
       SELECT AVG(review_count) AS avg_reviews
         FROM (
	           SELECT listing_id,
	                  COUNT(DISTINCT reviewer_id) AS review_count
	             FROM reviews
	         GROUP BY listing_id)
		   )
  SELECT c.listing_id AS listing_id,
         COUNT(DISTINCT r.reviewer_id) AS unique_reviewers
    FROM calendar_summary AS c
    JOIN reviews AS r
      ON c.listing_id = r.listing_id
   WHERE c.available = 't'
GROUP BY c.listing_id 
  HAVING COUNT(DISTINCT r.reviewer_id) > (SELECT avg_reviews FROM AvgReviews)
ORDER BY listing_id
   LIMIT 1



