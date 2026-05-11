SELECT 
    SUM(CASE WHEN end_session IS NULL THEN 1 ELSE 0 END) AS cnt_problem,
    SUM(CASE WHEN end_session IS NULL THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_problem,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'ios' THEN 1.0 ELSE 0.0 END) / SUM(CASE WHEN dev_type = 'ios' THEN 1 ELSE 0 END) AS problem_ios,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'android' THEN 1.0 ELSE 0.0 END) / SUM(CASE WHEN dev_type = 'android' THEN 1 ELSE 0 END) AS problem_android,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'ios' THEN 1 ELSE 0 END) AS cnt_problem_ios,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'android' THEN 1 ELSE 0 END) AS cnt_problem_android,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'ios' THEN 1.0 ELSE 0.0 END) / SUM(CASE WHEN end_session IS NULL THEN 1 ELSE 0 END) AS share_problem_ios,
    SUM(CASE WHEN end_session IS NULL AND dev_type = 'android' THEN 1.0 ELSE 0.0 END) / SUM(CASE WHEN end_session IS NULL THEN 1 ELSE 0 END) AS share_problem_android
FROM skygame.game_sessions g
INNER JOIN skygame.users u ON g.id_user = u.id_user;
