SELECT CASE 
       WHEN reg_date BETWEEN '2022.11.01' AND '2022.12.31' THEN 1  
       ELSE 0 
       END 
       AS user_type,
       AVG(end_session - start_session) AS avg_session_time
FROM skygame.users u  
LEFT JOIN skygame.game_sessions g 
ON g.id_user = u.id_user
WHERE end_session - start_session > INTERVAL '5 minute'
GROUP BY user_type
