--АНАЛИЗ БАЗЫ ДАННЫХ 
-- 1. Базовый подсчёт строк и уникальных пользователей
SELECT 
    COUNT(*) AS total_rows,
    COUNT(id_user) AS registered_users,
    COUNT(DISTINCT id_user) AS unique_users
FROM skygame.users;

-- 1.1. Поиск дубликатов id_user
SELECT 
    id_user,
    COUNT(*) AS duplicate_count
FROM skygame.users
GROUP BY id_user
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 2. Анализ даты регистрации (диапазон, пропуски)
SELECT 
    MAX(reg_date) AS max_reg_date,
    MIN(reg_date) AS min_reg_date,
    SUM(CASE WHEN reg_date IS NULL THEN 1 ELSE 0 END) AS null_count
FROM skygame.users;

-- 3. Динамика регистраций по месяцам
SELECT 
    DATE_TRUNC('month', reg_date) AS registration_month,
    COUNT(id_user) AS users_registered
FROM skygame.users
GROUP BY registration_month
ORDER BY registration_month;

--АНАЛИЗ ИГРОВЫХ СЕССИЙ 
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

-- 3. Средняя длина сессии в часах 
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


--АНАЛИЗ ТАБЛИЦЫ refferal
-- 1. Общая статистика по рефералам
SELECT 
    COUNT(DISTINCT id_user) AS unique_users,
    COUNT(*) AS total_referrals,
    SUM(ref_reg) * 1.0 / COUNT(*) AS conversion_rate
FROM skygame.referral;

-- 2. Топ-50 пользователей по количеству приглашений
SELECT 
    id_user,
    COUNT(*) AS invites_sent
FROM skygame.referral
GROUP BY id_user
ORDER BY invites_sent DESC
LIMIT 50;

-- 3. Пользователи, которые хорошо конвертируют приглашения (>5 приглашений и ≥50% регистраций)
SELECT 
    id_user,
    COUNT(*) AS invites_sent,
    SUM(ref_reg) * 1.0 / COUNT(*) AS registration_rate
FROM skygame.referral
GROUP BY id_user
HAVING COUNT(*) > 5
   AND SUM(ref_reg) * 1.0 / COUNT(*) >= 0.5;

-- 4. Пользователи, которые много приглашали (6+), но не привели ни одной регистрации
SELECT 
    id_user,
    COUNT(*) AS invites_sent,
    SUM(ref_reg) AS registrations,
    0.0 AS registration_rate
FROM skygame.referral
GROUP BY id_user
HAVING COUNT(*) > 6 
   AND SUM(ref_reg) = 0;

-- =====================================================
-- ЗАДАНИЕ 1. Ежедневная, еженедельная и ежемесячная аудитория
-- =====================================================

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

-- =====================================================
-- ЗАДАНИЕ 2. Топ-25 пользователей по времени в игре (2022 год)
-- =====================================================

SELECT 
    u.id_user,
    SUM(EXTRACT(EPOCH FROM (g.end_session - g.start_session)) / 60) AS total_minutes
FROM skygame.users u 
INNER JOIN skygame.game_sessions g ON u.id_user = g.id_user
WHERE g.end_session IS NOT NULL 
  AND EXTRACT(YEAR FROM u.reg_date) = 2022  
GROUP BY u.id_user
ORDER BY total_minutes DESC  
LIMIT 25;

-- =====================================================
-- ЗАДАНИЕ 3. Анализ проблемных сессий (end_session IS NULL)
-- =====================================================

SELECT 
    -- Общая статистика
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN end_session IS NULL THEN 1 ELSE 0 END) AS problem_sessions,
    SUM(CASE WHEN end_session IS NULL THEN 1.0 ELSE 0.0 END) / COUNT(*) AS problem_share_total,
    
    -- По типам устройств (доля проблемных внутри каждого типа)
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'ios' THEN 1.0 ELSE 0.0 END) 
        / NULLIF(SUM(CASE WHEN dev_type = 'ios' THEN 1 ELSE 0 END), 0) AS problem_share_ios,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'android' THEN 1.0 ELSE 0.0 END) 
        / NULLIF(SUM(CASE WHEN dev_type = 'android' THEN 1 ELSE 0 END), 0) AS problem_share_android,
    
    -- Абсолютное количество проблемных сессий по типам
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'ios' THEN 1 ELSE 0 END) AS problem_sessions_ios,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'android' THEN 1 ELSE 0 END) AS problem_sessions_android,
    
    -- Распределение проблемных сессий внутри типа устройства
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'ios' THEN 1.0 ELSE 0.0 END) 
        / NULLIF(SUM(CASE WHEN end_session IS NULL THEN 1 ELSE 0 END), 0) AS problem_distribution_ios,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'android' THEN 1.0 ELSE 0.0 END) 
        / NULLIF(SUM(CASE WHEN end_session IS NULL THEN 1 ELSE 0 END), 0) AS problem_distribution_android
FROM skygame.game_sessions g
INNER JOIN skygame.users u ON g.id_user = u.id_user;
