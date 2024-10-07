
-- Question 2: What is the most difficult award to achieve?
-- We can find the answer to this question by figuring out which
-- award is the least frequent among our intelligent individuals.

WITH award_name AS (
    SELECT award_name, award_id
    FROM award
),
award_freq AS (
    SELECT award_id, COUNT(*) AS award_count
    FROM individuals
    GROUP BY award_id
)
SELECT a.award_name, af.award_count
FROM award_name a
JOIN award_freq af ON a.award_id = af.award_id
ORDER BY af.award_count ASC;