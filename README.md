# Introduction
⚽️ A deep dive into Turkish Süper Lig payrolls! This project breaks down 💶 club budgets, 📊 wage‑gap metrics, and 🏆 squads that shine with balanced salary structures. From star‑studded giants to newly promoted underdogs, we reveal which teams master their wage pyramids—and which ones set off financial alarm bells in the dressing room.
💡
🔍 SQL queries? Check them out here: [Analysis_Codes](/Analysis_Codes/).


# Background

Driven by a desire to bring clarity to the often‑opaque world of football wages, this study began as a quest to identify where payroll imbalances lurk and how they shape competitive dynamics in the Turkish Süper Lig by surfacing the biggest earners, the widest pay gaps, and the most balanced rosters.

### The questions I wanted to answer through my SQL queries were: 
    1- What is each club's total annual wage bill?

    2- How large is the intra‑club wage gap, and how is pay distributed?

    3- Which positions command the highest pay across the league?

    4- Who are the top ten highest‑earning players?

    5- What is the correlation between salary and age?

    6- How balanced are wages between domestic and foreign players?   

# Tools I Used

For my deep dive into the Turkish League Salaries, I harnessed the power of several key tools:

**SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights.

**PostgreSQL:** The chosen database-management system, ideal for handling the job-posting data.

**Visual Studio Code:** My go-to for database management and executing SQL queries.

**Git & GitHub:** Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.


# The Analysis

Each query for this project aimed at investigating specific aspects of the Turkish League salaries. Here’s how I approached each question:

### 1. Total Salaries Per Club

To surface the clubs with the biggest payrolls, I summed every player’s gross yearly salary (gross_py_eur) by club. The query also returns the average salary per player and the squad size, helping benchmark spending efficiency.


```sql
SELECT
    c.club_name,
    CONCAT(TO_CHAR(ROUND(SUM(f.gross_py_eur) / 1000000, 2), 'FM999G990D00'), ' Mio') AS total_salary_mio,
    CONCAT(TO_CHAR(ROUND(AVG(f.gross_py_eur) / 1000000, 2), 'FM999G990D00'), ' Mio') AS avg_salary_per_player_mio,
    COUNT(*) AS player_count
FROM fact_contract  f
JOIN dim_club c USING (club_id)
GROUP BY c.club_name
ORDER BY SUM(f.gross_py_eur) DESC;
```

Running this statement highlights the highest‑spending clubs and reveals how much, on average, each squad member earns.

**Fenerbahçe (€90.9 m)** and **Galatasaray (€79.3 m)** dominate spending, jointly absorbing almost 30 % of the league’s total payroll.

**Beşiktaş (€66.2 m)** stands as a solid third; together the top three clubs account for more than half of all salaries paid.

The remaining 14 clubs sit at or below ≈ €17 m, with Adana Demirspor bottoming out at €5 m.

**Skewed distribution:** The mean club budget (€25.8 m) is far higher than the median (€15 m), indicating that a handful of heavy spenders pull the whole distribution to the right.

**Cost per player:** Each of the top three clubs spends > €2 m per player, whereas half of the league is below €0.65 m.

**High variance:** The standard deviation is nearly the same magnitude as the mean, underscoring sharp disparities from club to club.

![Total Salaries Per Club](assets/Total_Salaries.png)

### 2. Spread and Statistical Analysis of Salaries

To uncover how evenly (or unevenly) each club distributes its payroll, I computed the average salary, the standard deviation, and the coefficient of variation **(CV = σ / μ).** A higher CV flags a wider spread between high and low‑earning squad members.

```sql
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
```
Running this query highlights the clubs with the largest salary spreads and the relative equality of their wage structures.

**Average CV ≈ 0.97** — the league sits on the cusp between “moderate” and “high” pay dispersion.

**Financial Fair Play risk:** High‑CV clubs face sharper cost‑cutting pressure if revenues dip (e.g., missing European qualification).

**Balance matters:** Kasımpaşa and Bodrum require urgent payroll re‑balancing; Beşiktaş and Galatasaray should monitor their widening gaps. Conversely, Fenerbahçe, Konyaspor, and Kayserispor prove that balanced wage pyramids are achievable at any budget size.

**Relegation link:** All four relegated teams rank within the top eight for wage inequality—highlighting the sporting cost of financial imbalance.

![CVofSalaries](assets/CVofSalaries.png)

### 3. Payment Per Positions

To pinpoint which positions command the biggest slice of the wage pie, I summed every player’s gross yearly salary by position group (pos_group). The query also reveals the average pay per player in that role and its share of the league-wide payroll.

```sql
SELECT
    p.pos_group AS position,
    CONCAT(TO_CHAR(ROUND( SUM(f.gross_py_eur) / 1e6 , 2 )::NUMERIC,'FM999G990D00'),' mio') AS total_salary_mio,
    CONCAT(TO_CHAR(ROUND( (SUM(f.gross_py_eur) / COUNT(*)) / 1e6 , 2 )::NUMERIC,'FM999G990D00'),' mio') AS avg_per_player_mio,
    ROUND(SUM(f.gross_py_eur) * 100.0 / SUM(SUM(f.gross_py_eur)) OVER (),1) AS pct_of_overall
FROM fact_contract f
JOIN dim_player  p USING (player_id)
GROUP BY p.pos_group
ORDER BY SUM(f.gross_py_eur) DESC;
```

Executing this query ranks forwards, midfielders, defenders, and goalkeepers by total spend and average salary, spotlighting where clubs invest the most.

**Forwards (≈ 45 % of payroll):** Almost half of the total wage bill is poured into attackers—clubs are betting heavily on goal production.

**Defenders (≈ 29 %):** A solid second place; high‑profile centre‑backs drive most of the cost in this group.

**Midfielders (≈ 20 %):** Cheaper than attack in aggregate, but still earn more per head (€0.86 m) than defenders (€0.79 m).

**Goalkeepers (≈ 6 %):** Command the smallest slice and the lowest average pay (€0.43 m).

![TotalPositionSalary](assets/ByTotalPosition.png)

![SpecificPositionSalary](assets/PositionSalaries.png)


To discover which role each club pays the most, the following query sums salaries by position group inside every club, ranks them, and returns the top‑paid position.

```sql
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
        SUM(f.gross_py_eur) AS pos_total_eur,  
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
    pos_group AS top_paid_position,
    CONCAT(TO_CHAR(ROUND(pos_total_eur / 1e6 , 2)::NUMERIC,'FM999G990D00'),' mio') AS pos_salary_mio,
    ROUND(pos_total_eur * 100.0 / club_total_eur , 1) AS pct_of_club
FROM club_pos
WHERE rnk = 1
ORDER BY pos_total_eur DESC;

SELECT
    p.pos_detail AS position,                
    CONCAT(TO_CHAR(ROUND( SUM(f.gross_py_eur) / 1e6 , 2 )::NUMERIC,'FM999G990D00'),' mio') AS total_salary_mio,
    CONCAT(TO_CHAR(ROUND( (SUM(f.gross_py_eur) / COUNT(*)) / 1e6 , 2 )::NUMERIC,'FM999G990D00'),' mio') AS avg_per_player_mio,
    ROUND(SUM(f.gross_py_eur) * 100.0 / SUM(SUM(f.gross_py_eur)) OVER (),1) AS pct_of_overall
FROM fact_contract f
JOIN dim_player  p USING (player_id)
GROUP BY p.pos_detail
ORDER BY SUM(f.gross_py_eur) DESC;
```

Insight: Only three clubs **—Trabzonspor, Kayserispor and Goztepe—** allocate a larger share of their wage bill to defenders; every other team channels the biggest slice into its forward line.


### 4. Most Expensive 10 Players

To surface the ten most expensive contracts in the league, I simply order every valid salary in descending order and limit the output to ten rows:

```sql
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
```

Running this query yields a snapshot of the league’s true elite earners—helpful for benchmarking star wages and gauging how top‑heavy each club’s payroll might be.

**Risk concentration:** Losing or under‑performing a €10 m‑a‑year star wipes out a big chunk of wage ROI; squad depth and contingency planning are critical.

**Future wage inflation:** Heavy reliance on 30‑plus players foreshadows costly renewals; clubs must either budget for raises or start succession scouting early.

**Local‑talent gap:** No Turkish player cracks the top‑10; strengthening domestic academy‑to‑first‑team pipelines could ease FX exposure and FFP pressure.

**Club concentration:** Fenerbahçe owns 6 of 10 spots (positions 5‑10), while Galatasaray and Beşiktaş claim two each—making Fener the single‑largest spender at the elite end.

**Age profile:** Average age is 31 years 3 months; only Victor Osimhen (26) and Youssef En‑Nesyri (27) are under 30, signalling clubs prefer peak‑age certainty over future upside.

![Top10Player](assets/Top10Players.png)


### 5. Correlation Between Salary and Age

To measure how pay scales with age, I first calculate the Pearson correlation between a player’s age and their gross salary. Then I aggregate salary statistics for each age year to visualise patterns.

```sql
SELECT
    ROUND(CORR(p.age, f.gross_py_eur)::NUMERIC, 3) AS age_salary_corr
FROM fact_contract  f
JOIN dim_player p USING (player_id);
```

**Correlation coefficient: +0.36** — salary rises with age but there’s plenty of scatter; performance, role, and club wealth still dominate pay.

```sql
SELECT
    p.age AS age,         
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
```

![AgeSalary](assets/AgeSalaryRelationship.png)

**Density:** 75 % of all salaries remain below €1 m until age 27; beyond that, roughly 55 % of contracts break the €1 m line.

**Super‑earners:** Every €7 m+ contract falls between ages 26 and 32—the sweet‑spot where star value and resale prospects intersect.

### 6. Domestic VS Foreign Players

To gauge how payroll is split between home‑grown and imported talent, I sum total salaries by nationality bucket and compute per‑player averages and league‑wide shares.

```sql
WITH budget_split AS (
    SELECT
        CASE WHEN p.country = 'Turkey' THEN 'Domestic'
             ELSE 'Foreign'
        END AS player_type,
        SUM(f.gross_py_eur) AS total_eur,
        COUNT(*) AS player_count 
    FROM fact_contract  f
    JOIN dim_player p USING (player_id)
    WHERE f.gross_py_eur IS NOT NULL     
    GROUP BY player_type
)

SELECT
    player_type,
    ROUND(total_eur / 1e6, 2) || ' mio' AS total_mio,
    ROUND((total_eur / player_count) / 1e6, 2) || ' mio' AS avg_per_player_mio,
    ROUND(total_eur * 100.0 / SUM(total_eur) OVER (), 1) AS pct_of_league,
    player_count  AS player_count
FROM budget_split
ORDER BY total_eur DESC;
```

**Three‑quarters of the entire wage bill flows to foreign players**—far heavier than the ~60‑40 splits common in most European leagues.

**Cost ratio:** Clubs spend roughly €3.2 on imports for every €1 on home‑grown talent, underscoring deep reliance on overseas recruits.

**Efficiency gap:** If domestic players deliver comparable output for lower wages, some teams may be paying a costly “passport premium.”

**Regulatory exposure:** Any tightening of foreign‑player quotas (federation or UEFA) would force a rapid wage‑bill restructure; FX risk is amplified when 76 % of contracts are paid in €/$ to overseas players.

**Talent‑development signal:** The budget skew hints that academies and domestic scouting aren’t supplying enough first‑team quality, pushing clubs toward ready‑made imports.

![DomesticForeignVS](assets/ForeignDomesticVS.png)

# Conclusion

### Insights

**Club Wage Bills:** Fenerbahçe and Galatasaray alone absorb nearly 30 % of all salaries, and the top three clubs spend more than half of the league’s payroll.

**Intra‑Club Wage Spread:** The average CV sits at 0.97; Kasımpaşa and Bodrum top the inequality chart, while Fenerbahçe and Kayserispor boast the most balanced structures.

**Pay by Position:** Forwards eat up about 45 % of total wages, defenders 29 %, midfielders 20 %, and goalkeepers just 6 %.

**Top‑Paid Players:** Ten super‑earners make €6.7–10 m each; Fenerbahçe holds six of those contracts, and the group’s average age is 31.

**Age‑Salary Correlation:** A mild positive coefficient (+0.36) shows pay rises into the 26‑32 peak window, where every €7 m+ deal is located.

**Domestic vs Foreign:** Foreign players take 76 % of payroll—roughly €3.2 spent on imports for every €1 on home‑grown talent.