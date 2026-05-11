-- Топ-25 пользователей по минутам в игре (за 2022 год)
SELECT u.id_user,
       SUM(EXTRACT(EPOCH FROM (end_session - start_session)) / 60) AS session_minutes
FROM skygame.users u 
INNER JOIN skygame.game_sessions g ON u.id_user = g.id_user
WHERE end_session IS NOT NULL 
  AND DATE_PART('year', u.reg_date) = 2022  
GROUP BY u.id_user
ORDER BY session_minutes DESC  
LIMIT 25;
