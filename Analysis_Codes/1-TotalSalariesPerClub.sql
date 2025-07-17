SELECT
    c.club_name,
    CONCAT(TO_CHAR(ROUND(SUM(f.gross_py_eur) / 1000000, 2), 'FM999G990D00'), ' Mio') AS total_salary_mio,
    CONCAT(TO_CHAR(ROUND(AVG(f.gross_py_eur) / 1000000, 2), 'FM999G990D00'), ' Mio') AS avg_salary_per_player_mio,
    COUNT(*) AS player_count
FROM fact_contract  f
JOIN dim_club c USING (club_id)
GROUP BY c.club_name
ORDER BY SUM(f.gross_py_eur) DESC;


/*
Fenerbahçe (€90.9 m) and Galatasaray (€79.3 m) are well ahead of their rivals, together absorbing almost 30 % of the league’s total wage bill.

Beşiktaş (€66.2 m) is a strong third; the top three clubs account for more than half of overall salaries.

The mid-tier (Trabzonspor – Başakşehir) sits in the €30–37 m range.

The other 14 clubs are clustered at or below ~€17 m, with Adana Demirspor bottoming out at €5 m.
*/


/*
Skewed distribution: The average budget (€25.8 m) is far higher than the median (€15 m), showing that a handful of big-spending clubs pull the whole distribution to the right.

Cost per player: The top three clubs each spend > €2 m per player, whereas half of the league sits below €0.65 m.

Standard deviation is almost the same magnitude as the mean, pointing to very high variance from club to club.
*/