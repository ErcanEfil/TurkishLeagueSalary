CREATE TABLE salaries_raw (
    player                TEXT,
    verified              TEXT,
    gross_pw_eur          TEXT,
    gross_py_eur          TEXT,
    bonus_py_eur          TEXT,
    signed_raw            TEXT,
    expiration_raw        TEXT,
    years_remaining_raw   TEXT,
    gross_remaining_eur   TEXT,
    release_clause_eur    TEXT,
    status                TEXT,
    pos_group             TEXT,
    pos_detail            TEXT,
    age_raw               TEXT,
    country               TEXT,
    club_name             TEXT
);


COPY salaries_raw
FROM 'C:\Users\User\Desktop\TurkishLeagueSalary\CSVFile\turkish_superleague_salaries.csv'
DELIMITER ','
CSV HEADER
NULL 'NaN';

SELECT * FROM salaries_raw;