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
