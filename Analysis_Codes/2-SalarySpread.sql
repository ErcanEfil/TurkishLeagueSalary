WITH spread AS (
    SELECT
        c.club_name,
        MAX(f.gross_py_eur) - MIN(f.gross_py_eur)                      AS spread_abs_eur,
        (MAX(f.gross_py_eur) - MIN(f.gross_py_eur))
            / NULLIF(AVG(f.gross_py_eur), 0)                           AS spread_rel_to_avg,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY f.gross_py_eur)
      - PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY f.gross_py_eur)   AS spread_p90_p10_eur,
        AVG(f.gross_py_eur)                                            AS avg_salary
    FROM fact_contract f
    JOIN dim_club      c USING (club_id)
    GROUP BY c.club_name
)

SELECT
    club_name,

    CONCAT(TO_CHAR(ROUND((spread_abs_eur / 1000000)::NUMERIC, 2), 'FM999G990D00'), ' mio') AS spread_abs_mio,
    ROUND(spread_rel_to_avg::NUMERIC, 2) AS spread_rel_to_avg,

    CONCAT(TO_CHAR(ROUND((spread_p90_p10_eur / 1000000)::NUMERIC, 2), 'FM999G990D00'), ' mio') AS spread_p90_p10_mio,

    CASE
        WHEN spread_p90_p10_eur / NULLIF(avg_salary, 0) <= 1.68  THEN 'Balanced'
        ELSE 'Uneven'
    END AS wage_balance

FROM spread
ORDER BY spread_p90_p10_eur DESC;


WITH spread AS (
    SELECT
        c.club_name,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY f.gross_py_eur) -
        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY f.gross_py_eur) AS spread_p90_p10_eur
    FROM fact_contract f
    JOIN dim_club c USING (club_id)
    GROUP BY c.club_name
)
SELECT
    ROUND( (AVG(spread_p90_p10_eur)::NUMERIC / 1000000), 2 ) AS league_avg_p90_p10_mio
FROM spread;


--spread_abs_mio : Gap between the highest- and lowest-paid player in the squad (m€)
--spread_rel_to_avg : Same gap, normalised by the club’s average salary (→ how many times bigger than the mean)
--spread_p90_p10_mio : Distance between the 90th and 10th salary percentiles (robust to outliers)
--wage_balance : “Balanced” if p90-p10 ≤ p90-p10_average wage, otherwise “Uneven”	


/*
Big-three still dominate—but not equally.
Galatasaray and Beşiktaş have almost identical absolute spreads (~€ 9.9 m), whereas Fenerbahçe’s gap is € 2.6 m smaller despite the highest total wage bill. That suggests a slightly flatter internal pyramid at Fener.

“Smaller” clubs can be more unequal.

Hatayspor and Kasımpaşa pay five-plus times their average salary to their top earner.

The raw gap is only ~€ 2.5 m, but relative to a very low mean wage it signals strong dependence on a single marquee player.

p90-p10 vs. max-min matters.
Başakşehir is flagged Balanced because once the single top outlier is removed, the 90-10 range (-€ 1.78 m) sits below the squad average. A club can look unbalanced in max-min terms yet still have a compact “core” wage structure.

Kayserispor, Göztepe, Hatayspor stand out for low absolute spread and Balanced tag, indicating deliberately flat salary ladders—useful for dressing-room harmony and FFP control.

Uneven mid-table cluster.
Trabzonspor, Alanyaspor, Samsunspor, etc., show 1.3–2.3 m mid-range gaps and 3–4× relative spreads, hinting at traditional star-plus-support roster design.
*/