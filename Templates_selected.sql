/*1. Дана таблица действий пользователей:
-ID,
-time,
-event - тип действия (в т.ч. template_selected),
-event_type (конкретизация действия, например, название шаблона).
Необходимо вывести 10 шаблонов, которые пользователи применяли 2 и более раз подряд в течение одной сессии.
Сессия - последовательность событий, в которой промежуток между соседними событиями не более 3 минут
(т.е. длина самой сессии может быть любой, но между последовательными событиями интервал не более 3 минут)*/

WITH EventsLen AS (
         SELECT ID,
                time::timestamp AS time,--неизвестно, какой формат time, поэтому на всякий случай изменила на timestamp
                time::timestamp - LAG(time::timestamp) OVER (
                                 PARTITION BY user_id
                                     ORDER BY time) AS events_len,
                event,
                event_type
           FROM table),
-- в этом CTE вычисляем разницу во времени между последовательными событиями каждого юзера
     SessionLabel AS (
         SELECT ID,
                time,
                CASE WHEN events_len IS NULL
                     OR events_len <=interval '3 minutes' THEN 0
                     ELSE 1 END AS session_label,
                event,
                event_type
           FROM EventsLen),
--в этом CTE присваиваем 1 всем событиям, которые произошли с интервалом более 3 минут
     SessionID AS (
         SELECT ID,
                time,
                SUM(session_label) OVER (PARTITION BY ID ORDER BY time) AS session_id,
                event,
                event_type
           FROM SessionLabel),
-- в этом CTE суммируем 0 и 1 как накопительную сумму, чтобы для каждого юзера получить номер сессии
     PrevTemplate AS (
         SELECT ID,
                session_id,
                event_type,
			 LAG(event_type) OVER (PARTITION BY ID, session_id ORDER BY time) AS prev_template
           FROM SessionID
          WHERE event='template_selected'),
-- для каждой сессии каждого юзера получаем значение предыдущего шаблона, если его нет (это – первое действие), оставляем значение текущего шаблона
     Counts AS (
         SELECT ID,
                session_id,
                event_type AS template,
                COUNT (*) AS template_number
           FROM PrevTemplate
          WHERE template=prev_template
       GROUP BY ID, session_id, template)
-- суммируем все строки, сгруппированные по юзерам, сессиям и типам шаблона, когда текущий шаблон = предыдущему (т.е., шаблоны выбраны подряд)
  SELECT template,
         template_number
    FROM Counts
   WHERE template_number >= 1 #т.к. если шаблон=предыдущему шаблону, его выбрали 2 раза и более
ORDER BY template_number DESC
   LIMIT 10
