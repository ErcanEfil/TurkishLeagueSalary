SELECT
    p.player_name AS player,
    c.club_name AS club,
    p.age,
    p.country,
    f.gross_py_eur AS salary_eur,
    ROUND(f.gross_py_eur / 1e6, 2) || ' mio' AS salary_mio
FROM fact_contract  f
JOIN dim_player p USING (player_id)
JOIN dim_club c USING (club_id)
WHERE gross_py_eur IS NOT NULL
ORDER BY f.gross_py_eur DESC
LIMIT 10;



/*
Risk concentration – Losing / under-performing a €10 m star wipes out a large share of wage ROI; contingency depth is crucial.

Future wage inflation – Heavy reliance on 30-plus players suggests looming turnover costs; extensions will require at least current levels, or replacement scouting must start early.

Negotiation benchmark – Agents for near-elite players will anchor at the €7 m zone, knowing that is the second plateau.

Local talent development – No Turkish player in top-10: investing in domestic academy-to-star pipeline could reduce foreign-exchange exposure and FFP pressure.

Fenerbahçe holds 6 / 10 names (incl. positions 5-10), Galatasaray & Beşiktaş 2-er.
→ Fener is the single-biggest wage spender at the very top tier.

	Average age 31 y 3 m; only Osimhen (26) and En-Nesyri (27) are under 30.
→ Clubs pay premium for proven, peak-age talent rather than prospect value.

	9 different countries; Brazil the only duplicate. Indicates that top-tier salary slots are largely filled by imports rather than domestic stars.

*/    

