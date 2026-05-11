-- 1. Ежемесячная активность: общее число сессий, доля значимых (>5 мин)
SELECT 
    DATE_TRUNC('month', start_session) AS month,
    COUNT(*) AS total_sessions,
    SUM(CASE 
        WHEN (end_session - start_session) > INTERVAL '5 minute' 
        THEN 1.0 ELSE 0.0 
    END) AS significant_sessions,
    SUM(CASE 
        WHEN (end_session - start_session) > INTERVAL '5 minute' 
        THEN 1.0 ELSE 0.0 
    END) / COUNT(*) AS share_significant
FROM skygame.game_sessions
GROUP BY month
ORDER BY month;

-- 2. Средняя длина сессии (только для значимых, >5 мин)
SELECT 
    DATE_TRUNC('month', start_session) AS month,
    AVG(end_session - start_session) AS avg_session_duration
FROM skygame.game_sessions
WHERE (end_session - start_session) > INTERVAL '5 minute'
GROUP BY month
ORDER BY month;

-- 3. Средняя длина сессии в часах (через EXTRACT(EPOCH))
SELECT 
    DATE_TRUNC('month', start_session) AS month,
    AVG(EXTRACT(EPOCH FROM (end_session - start_session)) / 3600) AS avg_duration_hours
FROM skygame.game_sessions
WHERE (end_session - start_session) > INTERVAL '5 minute'
GROUP BY month
ORDER BY month;

-- 4. Доля «длинных» сессий (>1 часа) среди значимых (>5 мин)
SELECT 
    DATE_TRUNC('month', start_session) AS month,
    SUM(CASE 
        WHEN (end_session - start_session) > INTERVAL '1 hour' 
        THEN 1.0 ELSE 0.0 
    END) / COUNT(*) AS share_long_sessions
FROM skygame.game_sessions
WHERE (end_session - start_session) > INTERVAL '5 minute'
GROUP BY month
ORDER BY month;
