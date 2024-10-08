
/* ------ BUS205 Deliverable 4 ------------ */
/*
Group number: Group 21
Team members: Dexter Corley, Walker Hughes, Nihal Karim
*/
/*
Metrics Outline:
1. Does IQ correlate with a countries’ cost of living?: 
        We can compute the average IQ of individuals from each country
        and then correlate these averages with the corresponding country's cost of living index.
2. What is the most difficult award to achieve?: 
        We can find the answer to this question by figuring out which award
        is the least frequent among our intelligent individuals.
3. Is there a particular field of expertise that has a significantly higher count of self taught 
individuals than the average?:
    We investigate this question in two steps: 
        1. We calculate the total number of individuals in each field who are a) self-taught,
        or b) classically educated (defined as those who are not self-taught)
        2. For those two groups (self-taught and classically educated), we calculate the percentage of individuals
        in each group in each field of expertise.

*/
/*------- Queries ------------*/
/*
1. Does IQ correlate with a countries’ cost of living?: 
        We can compute the average IQ of individuals from each country
        and then correlate these averages with the corresponding country's cost of living index.
*/
--Compute the average IQ per country
WITH AvgIQPerCountry AS (
    SELECT
        i.COUNTRY_ID,
        AVG(i.IQ) AS Avg_IQ
    FROM
        INDIVIDUALS i
    GROUP BY
        i.COUNTRY_ID
),

--Separate country data based on cost of living categories
CountryData AS (
    SELECT
        c.COUNTRY_ID,
        c.COUNTRY_NAME,
        c.COST_OF_LIVING_INDEX,
        CASE
            WHEN c.COST_OF_LIVING_INDEX >= 70 THEN 'High'
            WHEN c.COST_OF_LIVING_INDEX >= 50 THEN 'Medium'
            ELSE 'Low'
        END AS Cost_Of_Living_Category
    FROM
        COUNTRY c
),

--Join the average IQ data with country data
AvgIQAndCostOfLiving AS (
    SELECT
        cd.COUNTRY_NAME,
        cd.COST_OF_LIVING_INDEX,
        cd.Cost_Of_Living_Category,
        a.Avg_IQ
    FROM
        AvgIQPerCountry a
    JOIN
        CountryData cd ON a.COUNTRY_ID = cd.COUNTRY_ID
)

--Calculate the correlation coefficient
SELECT
    CORR(Avg_IQ, COST_OF_LIVING_INDEX) AS Correlation
FROM
    AvgIQAndCostOfLiving;

/*
Result: Correlation is -0.2022308942
Weak correlation, showing small negative relationship between IQ and cost of living
*/


/*
2. What is the most difficult award to achieve?: 
        We can find the answer to this question by figuring out which award
        is the least frequent among our intelligent individuals.
*/

WITH award_name AS (
    SELECT award_name, award_id
    FROM award
),
award_freq AS (
    SELECT award_id, COUNT(*) AS award_count
    FROM individuals
    GROUP BY award_id
)
SELECT CASE a.award_name
    WHEN 'N/A' THEN 'Unknown' ELSE a.award_name END as AwardName, 
    RANK() OVER (ORDER BY af.award_count ASC) AS MostDifficult
FROM award_name a
JOIN award_freq af ON a.award_id = af.award_id



/*
3. Is there a particular field of expertise that has a significantly higher count of self taught
individuals than the average?:

We investigate this question in two steps: 
    1. We calculate the total number of individuals in each field who are a) self-taught, or b) classically educated (defined as those who are not self-taught)
    2. For those two groups (self-taught and classically educated), we calculate the percentage of individuals in each group in each field of expertise.

FINDINGS:
    -- We find that in *every* field of expertise, there are more classically educated individuals represented than self-taught individuals.
    -- We find that Physics is the only field of expertise where there is a greater proportion of self-educated individuals than classically educated individuals between the two groups.
    -- We find that the proportions of self-taught and classically educated individuals by field of expertise are very similar, and differ at most by 3% in the case of Physics.
*/
-- CTE for self-taught individuals
WITH self_taught_individuals AS (
    SELECT * 
    FROM individuals
    WHERE education = 'Self-taught'
-- CTE for classically educated individuals
), non_self_taught_individuals AS (
    SELECT * 
    FROM individuals
    WHERE education <> 'Self-taught'
-- CTE for number of self-taught individuals by field of expertise
), self_taught_by_field AS (
    SELECT fe.field_of_expertise_id, 
        MAX(fe.field_name) AS field_name,
        COUNT(DISTINCT individual_id) AS num_self_taught
    FROM self_taught_individuals st
    LEFT JOIN field_of_expertise fe USING(field_of_expertise_id)
    GROUP BY fe.field_of_expertise_id
-- CTE for number of classically educated individuals by field of expertise
), non_self_taught_by_field AS (
    SELECT fe.field_of_expertise_id, 
        MAX(fe.field_name) AS field_name,
        COUNT(DISTINCT individual_id) AS num_not_self_taught
    FROM non_self_taught_individuals st
    LEFT JOIN field_of_expertise fe USING(field_of_expertise_id)
    GROUP BY fe.field_of_expertise_id
)
SELECT st.field_of_expertise_id,
    st.field_name,
    st.num_self_taught,
    -- proportion of self-taught individuals in each field of expertise
    ROUND(st.num_self_taught::NUMERIC / (SELECT SUM(num_self_taught) FROM self_taught_by_field), 2) AS percent_self_taught,
    nst.num_not_self_taught,
    -- proportion of classically educated individuals in each field of expertise
    ROUND(nst.num_not_self_taught::NUMERIC / (SELECT SUM(num_not_self_taught) FROM non_self_taught_by_field), 2) AS percent_not_self_taught,
    -- bool indicating if a greater proportion of the self-educated individuals studied in a field of expertise than the 
    -- portion of classically educated individuals in that field
    CASE
        WHEN percent_self_taught > percent_not_self_taught THEN 'True'
        ELSE 'False'
    END AS higher_proportion_are_self_taught
FROM self_taught_by_field st
    JOIN non_self_taught_by_field nst USING(field_of_expertise_id, field_name)
ORDER BY st.field_of_expertise_id ASC;
