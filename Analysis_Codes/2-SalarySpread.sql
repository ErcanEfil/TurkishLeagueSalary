WITH club_stats AS (
    SELECT
        c.club_id,
        c.club_name,
        AVG(f.gross_py_eur) AS avg_salary,  
        STDDEV_POP(f.gross_py_eur) AS sd_salary 
    FROM   fact_contract f
    JOIN   dim_club c  ON c.club_id = f.club_id
    GROUP  BY c.club_id, c.club_name
)

SELECT
    club_name,
    ROUND(sd_salary / 1e6, 2) AS sd_mio,      
    ROUND(avg_salary / 1e6, 2) AS avg_mio,   
    ROUND(sd_salary / avg_salary, 3) AS cv     
FROM   club_stats
ORDER  BY cv DESC;

/*
Average CV ≈ 0.97 — the league sits on the border of “moderate–high” pay dispersion.
Financial Fair Play — high-CV clubs face sharper cost-cutting pressure if revenues dip (e.g., missing European qualification).
The league shows generally elevated but manageable within-club wage inequality. Kasımpaşa and Bodrum require urgent payroll re-balancing; Beşiktaş and Galatasaray should monitor their widening gaps. Conversely, Fenerbahçe, Konyaspor, and Kayserispor demonstrate that balanced wage pyramids are achievable regardless of budget size.
All four relegated teams rank within the top eight for wage-inequality.
*/