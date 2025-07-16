SELECT
    p.pos_group AS position,

    CONCAT(
        TO_CHAR(
            ROUND( SUM(f.gross_py_eur) / 1e6 , 2 )::NUMERIC,
            'FM999G990D00'
        ),
        ' mio'
    ) AS total_salary_mio,


    CONCAT(
        TO_CHAR(
            ROUND( (SUM(f.gross_py_eur) / COUNT(*)) / 1e6 , 2 )::NUMERIC,
            'FM999G990D00'
        ),
        ' mio'
    ) AS avg_per_player_mio,


    ROUND(
        SUM(f.gross_py_eur) * 100.0
        / SUM(SUM(f.gross_py_eur)) OVER (),
        1
    ) AS pct_of_overall

FROM fact_contract f
JOIN dim_player  p USING (player_id)
GROUP BY p.pos_group
ORDER BY SUM(f.gross_py_eur) DESC;



WITH club_tot AS (
    SELECT
        club_id,
        SUM(gross_py_eur) AS club_total_eur 
    FROM fact_contract
    GROUP BY club_id
),


club_pos AS (
    SELECT
        c.club_name,
        p.pos_group,

        SUM(f.gross_py_eur)                    AS pos_total_eur,  
        t.club_total_eur,                                       
        RANK() OVER (
            PARTITION BY c.club_name
            ORDER BY SUM(f.gross_py_eur) DESC
        ) AS rnk
    FROM fact_contract f
    JOIN dim_club   c USING (club_id)
    JOIN dim_player p USING (player_id)
    JOIN club_tot   t USING (club_id)
    GROUP BY c.club_name, p.pos_group, t.club_total_eur
)


SELECT
    club_name,
    pos_group                       AS top_paid_position,

    CONCAT(
        TO_CHAR(
            ROUND(pos_total_eur / 1e6 , 2)::NUMERIC,
            'FM999G990D00'
        ),
        ' mio'
    )                                AS pos_salary_mio,


    ROUND(pos_total_eur * 100.0 / club_total_eur , 1)
                                      AS pct_of_club

FROM club_pos
WHERE rnk = 1
ORDER BY pos_total_eur DESC;

SELECT
    p.pos_detail AS position,                
    CONCAT(
        TO_CHAR(
            ROUND( SUM(f.gross_py_eur) / 1e6 , 2 )::NUMERIC,
            'FM999G990D00'
        ),
        ' mio'
    ) AS total_salary_mio,

    CONCAT(
        TO_CHAR(
            ROUND( (SUM(f.gross_py_eur) / COUNT(*)) / 1e6 , 2 )::NUMERIC,
            'FM999G990D00'
        ),
        ' mio'
    ) AS avg_per_player_mio,

    ROUND(
        SUM(f.gross_py_eur) * 100.0
        / SUM(SUM(f.gross_py_eur)) OVER (),
        1
    ) AS pct_of_overall

FROM fact_contract f
JOIN dim_player  p USING (player_id)
GROUP BY p.pos_detail
ORDER BY SUM(f.gross_py_eur) DESC;


/*
Almost half the total wage bill is poured into forwards. Clubs are betting heavily on goal production.
A solid second place; centre-backs drive most of the cost
Mid park is cheaper than attack but still above defenders on a per-head basis.
Keepers receive the smallest slice and lowest average pay.


Attack costs the most, by far.
Central forwards + wingers consume ~34 % of total payroll. Clubs prioritise match-winners.

Centre-backs are the “defensive big spend”.
Defensive solidity is valued almost as highly as goals; CBs alone cost > LB+RB+GK combined.

Full-backs & Goalkeepers look cheap—opportunity market?
Average LB/RB salaries (0.85 m / 0.60 m) suggest room to gain an edge by investing slightly more here while rivals focus on other roles.

Second-Striker anomaly.
The 7.42 m € per SS signals a tiny group of marquee contracts. Any club considering that role must budget for star-level wages—or develop from within.

Midfield spread is balanced.
CM, DM, AM buckets each sit ~0.8–1.0 m average, indicating an established pay band; negotiations above 1.2 m start pushing into “elite” territory.
*/
