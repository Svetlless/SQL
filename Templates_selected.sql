/*1. The following data of the photo editor app are given:
-ID,
-time,
-event - type of event (e.g. template_selected),
-event_type (e.g. template title).
The task is to create an output with 10 templates that the users selected two or more times in a row during one session.
Session is a sequence of events in which the interval between the events is no more than 3 minutes
(i.e. the length of the session itself can be longer than 3 minutes, but the interval between the consecutive events shouldn't be more than 3 minutes)*/

WITH EventsLen AS (
         SELECT ID,
                time::timestamp AS time,
                time::timestamp - LAG(time::timestamp) OVER (
                                 PARTITION BY user_id
                                     ORDER BY time) AS events_len,
                event,
                event_type
           FROM table),
-- in this CTE I calculate the difference between the consecutive events of each user
     SessionLabel AS (
         SELECT ID,
                time,
                CASE WHEN events_len IS NULL
                     OR events_len <=interval '3 minutes' THEN 0
                     ELSE 1 END AS session_label,
                event,
                event_type
           FROM EventsLen),
-- in this CTE I mark all users with the interval more than 3 minutes as 1 
     SessionID AS (
         SELECT ID,
                time,
                SUM(session_label) OVER (PARTITION BY ID ORDER BY time) AS session_id,
                event,
                event_type
           FROM SessionLabel),
-- in this CTE I sum up 0 and 1 as the cumulative sum, in order to obtain a session number for each user
     PrevTemplate AS (
         SELECT ID,
                session_id,
                event_type,
		LAG(event_type) OVER (PARTITION BY ID, session_id ORDER BY time) AS prev_template
           FROM SessionID
          WHERE event='template_selected'),
-- for each session of each user I get the name of the previous template used
     Counts AS (
         SELECT ID,
                session_id,
                event_type AS template,
                COUNT (*) AS template_number
           FROM PrevTemplate
          WHERE template=prev_template
       GROUP BY ID, session_id, template)
-- I sum up all rows grouped by users, sessions and template types when current template = previous template
  SELECT template,
         template_number
    FROM Counts
   WHERE template_number >= 1 -- if current template=previous template, it means that the template was used two or more times in a row
ORDER BY template_number DESC
   LIMIT 10
