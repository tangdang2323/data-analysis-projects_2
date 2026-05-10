-- DAU (Daily Active Users)
SELECT 
    DATE_TRUNC('day', start_session) AS activity_day,
    COUNT(DISTINCT id_user) AS dau
FROM skygame.game_sessions
GROUP BY activity_day
ORDER BY activity_day;

-- WAU (Weekly Active Users)
SELECT 
    DATE_TRUNC('week', start_session) AS activity_week,
    COUNT(DISTINCT id_user) AS wau
FROM skygame.game_sessions
GROUP BY activity_week
ORDER BY activity_week;

-- MAU (Monthly Active Users)
SELECT 
    DATE_TRUNC('month', start_session) AS activity_month,
    COUNT(DISTINCT id_user) AS mau
FROM skygame.game_sessions
GROUP BY activity_month
ORDER BY activity_month;
