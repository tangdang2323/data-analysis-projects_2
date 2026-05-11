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
