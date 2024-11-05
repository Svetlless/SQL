/*installs — installs by day:

    DeviceID;
    InstallationDate;
    InstallCost;
    Platform (on which platform the app was installed: iOS/ Android);
    Source (app store/ ads / website).

  events:

    DeviceID;
    AppPlatform (on which platform the app is used: iOS/ Android);
    EventDate;
    events —  number of views of all products during this day for this DeviceID.

  checks — data on purchases by day:

    UserID;
    Rub — total check by date;
    BuyDate.

  devices: 

    DeviceID;
    UserID

Users don't have to log in to view the products. Before the users logs in, we know the DeviceID only. Users should log in to make a purchase.*/

/*Let's check how many products users who came from diffferent sources view on average from different platforms.
The table should be ordered by average views (descending order) and include 30 rows.*/
  SELECT AVG (e.events) AS average_views,
         i.Platform AS platform,
         i.Source AS source
    FROM events AS e
    JOIN installs AS i
      ON e.DeviceID = i. DeviceID)
GROUP BY i.Platform, i.Source
ORDER BY average_views DESC
   LIMIT 30

/*Let's now calculate the conversion from installs to views by install platform.
In this case, we are looking at the proportion of DeviceIDs that have views compared to all DeviceIDs in installs.*/

   SELECT i.Platform AS platform,
          COUNT(DISTINCT e.DeviceID) / COUNT(DISTINCT i.DeviceID) AS conversion_rate
     FROM installs as i
LEFT JOIN events as e
       ON i.DeviceID = e.DeviceID
 GROUP BY i.Platform

/*From which source did the users who made the largest number of purchases come?
Note that purchases that cost 0 rubles are also considered to be purchases.*/

  SELECT COUNT(ch.Rub) as purchases,
         u.Source as source
    FROM checks as ch
    JOIN (
	      SELECT i.Source AS Source,
                 d.UserID AS UserID
            FROM installs as i
            JOIN devices as d
              ON i.DeviceID = d.DeviceID) as u
      ON ch.UserID = u.UserID
GROUP BY u.Source
ORDER BY purchases DESC
   LIMIT 1


