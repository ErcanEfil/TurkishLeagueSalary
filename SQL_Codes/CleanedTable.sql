CREATE TABLE salaries_clean AS
WITH cleaned AS (
    SELECT
        player,
        (verified = 'Yes') AS verified,
        NULLIF(regexp_replace(gross_pw_eur,      '[^0-9.]', '', 'g'),'')::NUMERIC AS gross_pw_eur,
        NULLIF(regexp_replace(gross_py_eur,      '[^0-9.]', '', 'g'),'')::NUMERIC AS gross_py_eur,
        NULLIF(regexp_replace(bonus_py_eur,      '[^0-9.]', '', 'g'),'')::NUMERIC AS bonus_py_eur,
        NULLIF(regexp_replace(gross_remaining_eur,'[^0-9.]', '', 'g'),'')::NUMERIC AS gross_remaining_eur,
        NULLIF(regexp_replace(release_clause_eur,'[^0-9.]', '', 'g'),'')::NUMERIC AS release_clause_eur,
        to_date(signed_raw,     'Mon DD, YYYY') AS signed_on,
        to_date(expiration_raw, 'Mon DD, YYYY') AS expires_on,
        years_remaining_raw::SMALLINT           AS years_remaining,
        status,
        pos_group,
        pos_detail,
        age_raw::SMALLINT                       AS age,
        country,
        club_name
    FROM salaries_raw
)
SELECT *
FROM cleaned;

--Control 

SELECT COUNT(*) AS satir_sayisi, MIN(signed_on), MAX(expires_on) FROM salaries_clean;