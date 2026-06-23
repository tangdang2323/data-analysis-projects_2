WITH k_f AS (
  SELECT SUM(COALESCE(ref_reg,0)) AS sum_ref_reg,
         COUNT(DISTINCT u.id_user) AS cnt_users,
         SUM(COALESCE(ref_reg,0))::FLOAT/COUNT(DISTINCT u.id_user) AS k_factor
  FROM skygame.users u  
  LEFT JOIN skygame.referral r  
  ON u.id_user = r.id_user),
cohort_size AS (
  SELECT COUNT(DISTINCT u.id_user)::FLOAT/(SELECT COUNT(DISTINCT DATE_PART('month',reg_date)) FROM skygame.users) AS size
  FROM skygame.users u  
  LEFT JOIN skygame.referral r  
  ON u.id_user = r.id_user)

SELECT k_f.k_factor,
       cohort_size.size AS av_size,
       k_f.k_factor*cohort_size.size AS expected_size
FROM k_f,cohort_size
