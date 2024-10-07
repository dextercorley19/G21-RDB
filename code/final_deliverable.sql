
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
         [Metric definition]
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
        [Metric definition]
*/


