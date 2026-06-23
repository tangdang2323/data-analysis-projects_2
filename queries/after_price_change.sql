SELECT   DATE_TRUNC('month',dtime_pay) AS mm, 
         AVG(cnt_buy) AS cnt, 
         SUM(cnt_buy * price) AS revenue
FROM skygame.monetary m
	   JOIN skygame.item_list i
      ON m.id_item_buy = i.id_item
     JOIN skygame.log_prices p
		  ON m.id_item_buy = p.id_item
      AND m.dtime_pay >= p.valid_from
      AND m.dtime_pay <= COALESCE(valid_to, to_date('01/01/3000', 'DD/MM/YYYY'))
WHERE name_item = 'Crystal'
GROUP BY mm
ORDER BY mm
