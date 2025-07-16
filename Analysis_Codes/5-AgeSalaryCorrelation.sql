SELECT
    ROUND(
        CORR(p.age, f.gross_py_eur)::NUMERIC, 
        3                                      
    ) AS age_salary_corr
FROM fact_contract  f
JOIN dim_player     p USING (player_id);


SELECT
    p.age                                            AS age,         

    ROUND( AVG(f.gross_py_eur) / 1e6 , 2 ) AS avg_salary_mio,

    ROUND( MIN(f.gross_py_eur) / 1e6 , 2 ) AS min_salary_mio,
    ROUND( MAX(f.gross_py_eur) / 1e6 , 2 ) AS max_salary_mio,

    COUNT(*) AS player_count

FROM fact_contract  f
JOIN dim_player     p USING (player_id)
WHERE p.age IS NOT NULL            
  AND f.gross_py_eur IS NOT NULL   
GROUP BY p.age
ORDER BY p.age;


/*
Correlation coefficient: +0.36 – salary rises with age but with plenty of scatter; performance, role and club wealth still dominate pay.

Density: 75 % of all salaries remain below €1 m until age 27; beyond that, ~55 % of contracts break the €1 m line.

Super-earners: every €7 m+ contract sits between 26 and 32 – the sweet-spot where star value and resale prospects intersect.
*/


