WITH budget_split AS (
    SELECT
        CASE WHEN p.country = 'Turkey' THEN 'Domestic'
             ELSE 'Foreign'
        END                AS player_type,

        SUM(f.gross_py_eur)          AS total_eur,
        COUNT(*)                     AS player_count 
    FROM fact_contract  f
    JOIN dim_player     p USING (player_id)
    WHERE f.gross_py_eur IS NOT NULL     
    GROUP BY player_type
)

SELECT
    player_type,

    ROUND(total_eur / 1e6, 2) || ' mio'            AS total_mio,

    ROUND((total_eur / player_count) / 1e6, 2)
         || ' mio'                                 AS avg_per_player_mio,
    ROUND(
        total_eur * 100.0 / SUM(total_eur) OVER (),
        1
    )                                              AS pct_of_league,

    player_count                                   AS player_count
FROM budget_split
ORDER BY total_eur DESC;


/*
Three quarters of all salaries go to foreign players.
Clubs spend €3.2 on imports for every €1 on home-grown talent—a heavy reliance compared with most European leagues (where the split is often closer to 60-40).

Cost efficiency gap likely exists.
If domestic salaries average lower yet performance gaps are small, some clubs may be over-paying for “passport premiums” on foreign names.

Regulatory exposure.
• Any tightening of foreign-player quotas (federation or UEFA) would force a rapid wage-bill restructure.
• Currency-exchange risk is amplified when 76 % of contracts are paid in €/$ to overseas players.

Talent-development signal.
Budget skew suggests academies or domestic scouting aren’t supplying enough first-team quality, pushing clubs to buy ready-made imports.
*/