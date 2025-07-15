CREATE TABLE dim_club (
    club_id  SERIAL PRIMARY KEY,
    club_name TEXT UNIQUE
);

CREATE TABLE dim_player (
    player_id    SERIAL PRIMARY KEY,
    player_name  TEXT      NOT NULL,
    country      TEXT      NOT NULL,
    age          SMALLINT,
    pos_group    CHAR(1),
    pos_detail   TEXT,
    UNIQUE (player_name, country, age)
);


CREATE TABLE fact_contract (
    contract_id        SERIAL PRIMARY KEY,
    player_id          INTEGER REFERENCES dim_player(player_id),
    club_id            INTEGER REFERENCES dim_club(club_id),
    verified           BOOLEAN,
    signed_on          DATE,
    expires_on         DATE,
    years_remaining    SMALLINT,
    gross_pw_eur       NUMERIC(12,2),
    gross_py_eur       NUMERIC(12,2),
    bonus_py_eur       NUMERIC(12,2),
    gross_remaining_eur NUMERIC(12,2),
    release_clause_eur  NUMERIC(15,2),
    status             TEXT
);

INSERT INTO dim_club (club_name)
SELECT DISTINCT club_name FROM salaries_clean;


INSERT INTO dim_player (player_name, country, age, pos_group, pos_detail)
SELECT DISTINCT player,
                country,
                age,
                pos_group,
                pos_detail
FROM salaries_clean;

ALTER TABLE fact_contract
    ADD CONSTRAINT fact_contract_player_id_fkey
    FOREIGN KEY (player_id)
    REFERENCES dim_player (player_id);

INSERT INTO fact_contract (
    player_id, club_id, verified, signed_on, expires_on, years_remaining,
    gross_pw_eur, gross_py_eur, bonus_py_eur, gross_remaining_eur,
    release_clause_eur, status)
SELECT
    p.player_id,
    c.club_id,
    s.verified,
    s.signed_on,
    s.expires_on,
    s.years_remaining,
    s.gross_pw_eur,
    s.gross_py_eur,
    s.bonus_py_eur,
    s.gross_remaining_eur,
    s.release_clause_eur,
    s.status
FROM salaries_clean s
JOIN dim_player p ON (p.player_name = s.player AND p.country = s.country)
JOIN dim_club   c ON (c.club_name  = s.club_name);


CREATE INDEX idx_fact_contract_expires ON fact_contract(expires_on);
CREATE INDEX idx_fact_contract_club ON fact_contract(club_id);

