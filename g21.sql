
/*
1. In Postgres/BigQuery, create a database/schema that can house your data
*/

CREATE DATABASE G21_RDB


/*
2. Write CREATE statements for each of your ERD tables. Save all the statements in one .sql file. 
Make sure to separate different statements with a ; . 
Also, make sure your code specifies PK and FK constraints.
3. Execute your CREATE statements on the platform of your choice (Postgres or BigQuery). 
If you choose BigQuery, you need to comment out the PK/FK constraint specifications.
*/

CREATE SCHEMA G21_RDB.g21_schema;

CREATE TABLE IF NOT EXISTS Individuals (
    individual_id INT AUTOINCREMENT PRIMARY KEY,
    country_id INT,
    field_of_expertise_id INT,
    award_id INT,
    name VARCHAR,
    iq INT,
    gender VARCHAR,
    birth_year INT,
    education VARCHAR,
    FOREIGN KEY (country_id) REFERENCES Country(country_id),
    FOREIGN KEY (field_of_expertise_id) REFERENCES Field_Of_Expertise(field_of_expertise_id),
    FOREIGN KEY (award_id) REFERENCES Award(award_id)
);

CREATE TABLE IF NOT EXISTS IF NOT EXISTS Award (
    award_id INT AUTOINCREMENT PRIMARY KEY,
    award_name STRING UNIQUE
);

CREATE TABLE IF NOT EXISTS Country (
	COUNTRY_ID INT AUTOINCREMENT PRIMARY KEY,
    COUNTRY_NAME VARCHAR,
	COST_OF_LIVING_INDEX FLOAT,
	RENT_INDEX FLOAT,
	GROCERIES_INDEX FLOAT,
	RESTAURANT_PRICE_INDEX FLOAT,
	LOCAL_PURCHASING_POWER FLOAT
);

CREATE TABLE IF NOT EXISTS Field_Of_Expertise (
    field_of_expertise_id INT AUTOINCREMENT PRIMARY KEY,
    field_name VARCHAR
);


CREATE TABLE IF NOT EXISTS Individuals_countries (
    individuals_cost_of_living_id INT AUTOINCREMENT PRIMARY KEY,
    country_id INT,
    individual_id INT,
    FOREIGN KEY (country_id) REFERENCES Country(country_id),
    FOREIGN KEY (individual_id) REFERENCES Individuals(individual_id)
);



/*
4. Import all your found datasets into your database; one table per dataset.*/
/*4.1 Create a schema for your datasets*/
/*4.2 Create a table in the datasets schema per dataset found*/
/*4.3 import your data using the import wizard using the guide posted on Canvas > Week 4 Module*/

CREATE SCHEMA datasets;

CREATE TABLE IF NOT EXISTS datasets.countries_index ( 
    rank INT,
    country VARCHAR,
    cost_of_living_index FLOAT,
    rent_index FLOAT,
    cost_of_living_plus_rent FLOAT,
    groceries_index FLOAT,
    resturant_price_index FLOAT,
    local_purchasing_power_index FLOAT
);

CREATE TABLE IF NOT EXISTS datasets.intelligent_people ( 
    names VARCHAR,
    country VARCHAR,
    field_of_expertise VARCHAR,
    iq_scores INT,
    achievements VARCHAR,
    notable_works VARCHAR,
    awards VARCHAR,
    education VARCHAR,
    influence VARCHAR,
    gender VARCHAR,
    birth_year INT  
);

/*
5. Perform data wrangling by writing SELECT statements to 
create a result set suitable for each of your database tables.
*/

SELECT DISTINCT awards
FROM datasets.intelligent_people
WHERE awards IS NOT NULL;





SELECT 
    CASE 
        WHEN country = 'United States' THEN 'USA' 
        WHEN country = 'United Kingdom' THEN 'UK'
        ELSE country
    END AS country,
    cost_of_living_index,
    rent_index,
    groceries_index,
    resturant_price_index,
    local_purchasing_power_index
FROM 
    datasets.countries_index;





SELECT field_of_expertise
FROM datasets.intelligent_people





SELECT 
    c.country_id,f.field_of_expertise_id,a.award_id,i.names,i.IQ_SCORES AS iq,i.gender,i.birth_year,i.education        
FROM 
    datasets.intelligent_people i

LEFT JOIN g21_schema.award a ON i.awards = a.award_name
LEFT JOIN g21_schema.country c ON i.country = c.country_name
LEFT JOIN g21_schema.field_of_expertise f ON i.field_of_expertise = f.field_name




SELECT i.individual_id, i.country_id
FROM individuals AS i



/*
6. To fill in your designed and created tables, write INSERT statements that 
take in the above SELECT statements.
*/

INSERT INTO g21_schema.award (award_name)
SELECT DISTINCT awards
FROM datasets.intelligent_people
WHERE awards IS NOT NULL;


INSERT INTO g21_schema.country (COUNTRY_NAME,COST_OF_LIVING_INDEX,RENT_INDEX,GROCERIES_INDEX,RESTAURANT_PRICE_INDEX,LOCAL_PURCHASING_POWER)
SELECT 
    CASE 
        WHEN country = 'United States' THEN 'USA' 
        WHEN country = 'United Kingdom' THEN 'UK'
        ELSE country
    END AS country,
    cost_of_living_index,
    rent_index,
    groceries_index,
    resturant_price_index,
    local_purchasing_power_index
FROM 
    datasets.countries_index;



INSERT INTO g21_schema.field_of_expertise (field_name)
SELECT DISTINCT field_of_expertise
FROM datasets.intelligent_people



INSERT INTO g21_schema.individuals (country_id,field_of_expertise_id,award_id,name,iq,gender,birth_year,education)
SELECT 
    c.country_id,f.field_of_expertise_id,a.award_id,i.names,i.IQ_SCORES AS iq,i.gender,i.birth_year,i.education        
FROM 
    datasets.intelligent_people i

LEFT JOIN g21_schema.award a ON i.awards = a.award_name
LEFT JOIN g21_schema.country c ON i.country = c.country_name
LEFT JOIN g21_schema.field_of_expertise f ON i.field_of_expertise = f.field_name


INSERT INTO g21_schema.individuals_countries (individual_id,country_id)
SELECT i.individual_id, i.country_id
FROM individuals AS i





/*
7. Finally query each filled table by writing a SELECT * FROM Table_Name LIMIT 10 . Take screenshots of your query and returned results. Use this templateLinks to an external site. to save your screenshots into a file. Download a .pdf version of the completed file. Please make sure to include a snapshot of your ERD diagram. Feel free to enhance and update your previously submitted ERD diagram.
*/
