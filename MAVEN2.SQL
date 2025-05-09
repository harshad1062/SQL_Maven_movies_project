USE MAVENMOVIES;

-- How many times each movie has been rented out?

SELECT F.FILM_ID,F.TITLE, COUNT(*) AS COUNT_OF_MOVIES
FROM RENTAL AS R LEFT JOIN INVENTORY AS INV
ON R.INVENTORY_ID = INV.INVENTORY_ID
LEFT JOIN FILM AS F
ON INV.FILM_ID = F.FILM_ID
GROUP BY INV.FILM_ID
ORDER BY COUNT_OF_MOVIES DESC;

-- REVENUE PER FILM (TOP 10 GROSSERS)
SELECT RENTAL_ID_TRANSACTIONS.TITLE,SUM(P.AMOUNT) AS GROSS_REVENUE
FROM (SELECT R.RENTAL_ID,F.FILM_ID,F.TITLE
FROM RENTAL AS R LEFT JOIN INVENTORY AS INV
ON R.INVENTORY_ID = INV.INVENTORY_ID
LEFT JOIN FILM AS F
ON INV.FILM_ID = F.FILM_ID) AS RENTAL_ID_TRANSACTIONS
LEFT JOIN PAYMENT AS P
ON RENTAL_ID_TRANSACTIONS.RENTAL_ID = P.RENTAL_ID
GROUP BY RENTAL_ID_TRANSACTIONS.TITLE
ORDER BY GROSS_REVENUE DESC
LIMIT 10;

-- Most Spending Customer so that we can send him/her rewards or debate points

SELECT P.CUSTOMER_ID,SUM(AMOUNT) AS SPENDING, C.FIRST_NAME,C.LAST_NAME,STORE_ID
FROM PAYMENT AS P LEFT JOIN CUSTOMER AS C
ON P.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY P.CUSTOMER_ID
ORDER BY SPENDING DESC
LIMIT 10;


SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,C.EMAIL,SUM(P.AMOUNT) AS REVENUE
FROM PAYMENT AS P LEFT JOIN CUSTOMER AS C 
ON P.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID;


-- Which Store has historically brought the most revenue?
SELECT S.STORE_ID,SUM(P.AMOUNT) AS REVENUE_PER_STORE
FROM PAYMENT AS P LEFT JOIN STAFF AS S
ON P.STAFF_ID=S.STAFF_ID
GROUP BY S.STORE_ID
ORDER BY REVENUE_PER_STORE desc;

-- How many rentals we have for each month
SELECT  extract(MONTH FROM RENTAL_DATE) AS MONTH_NUMBER, extract(MONTH FROM RENTAL_DATE) AS YEAR_NAME, COUNT(*) AS NUMBER_OF_RENTALS
FROM RENTAL
GROUP BY  extract(YEAR FROM RENTAL_DATE), extract(MONTH FROM RENTAL_DATE);

-- Reward users who have rented at least 30 times (with details of customers)

SELECT R.CUSTOMER_ID,COUNT(*) AS NUM_OF_RENTAL,C.FIRST_NAME
FROM RENTAL AS R LEFT JOIN CUSTOMER AS C
ON R.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY R.CUSTOMER_ID
HAVING NUM_OF_RENTAL >=30;

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

SELECT *
FROM FILM
WHERE SPECIAL_FEATURES LIKE  "%Behind the scenes%";

-- unique movie ratings and number of movies

SELECT RATING,COUNT(*) AS count_of_movies
FROM FILM
GROUP BY RATING
order by count_of_movies desc;

-- Could you please pull a count of titles sliced by rental duration?

select rental_duration,count(film_id) as num_of_film 
from film
group by rental_duration;

-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION

SELECT RATING,COUNT(*) AS count_of_movies,MIN(LENGTH),ROUND(AVG(LENGTH),0) AS AVG_FILM_LENGTH,MAX(LENGTH),ROUND(AVG(RENTAL_DURATION),0) AS AVG_RETAL_DURATION
FROM FILM
GROUP BY RATING
order by count_of_movies desc;

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?

SELECT REPLACEMENT_COST,COUNT(*) AS NUMBER_OF_FILM, AVG(RENTAL_RATE),MIN(RENTAL_RATE),MAX(RENTAL_RATE)
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;

-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

SELECT R.CUSTOMER_ID,COUNT(*) AS NUM_OF_RENTAL,C.FIRST_NAME
FROM RENTAL AS R LEFT JOIN CUSTOMER AS C
ON R.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY R.CUSTOMER_ID
HAVING NUM_OF_RENTAL <=15;

-- CATEGORIZE MOVIES AS PER LENGTH

SELECT *,
CASE 
    WHEN LENGTH < 60 THEN "SORT MOVIES"
    WHEN LENGTH BETWEEN 60 AND 90 THEN "MEDIUM LENGTH"
    WHEN LENGTH >90 THEN "LONG LENGTH"
    ELSE"ERROR"
END AS MOVIE_LENGTH_CATEGORY
FROM FILM;

-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC
select * from film;
SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;

-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”

select *, 
case
    when store_id =1 and active =1 then "store 1 active"
    when store_id =1 and active =0 then "store 1 inactive"
    when store_id =2 and active =1 then "store 2 active"
    when store_id =2 and active =0 then "store 2 inactive"
    else "error"
    end as store_and_staus
from customer;

-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

SELECT INV.INVENTORY_ID,INV.STORE_ID,F.TITLE,F.DESCRIPTION
FROM INVENTORY
AS INV INNER JOIN FILM AS F
ON INV.FILM_ID=F.FILM_ID
;

-- Actor first_name, last_name and number of movies

SELECT A.ACTOR_ID, A.FIRST_NAME, A.LAST_NAME, COUNT(*) AS NUM_OF_MOVIES
FROM ACTOR AS A LEFT JOIN FILM_ACTOR AS FC
ON A.ACTOR_ID = FC.ACTOR_ID
group by A.ACTOR_ID;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”
-- ONE WAY
SELECT FC.FILM_ID,COUNT(*) AS ACTORS_COUNT
FROM ACTOR AS A LEFT JOIN FILM_ACTOR AS FC
ON A.ACTOR_ID = FC.ACTOR_ID
group by FC.FILM_ID
ORDER BY FC.FILM_ID ;

SELECT F.FILM_ID,F.TITLE, COUNT(*) AS NUM_OF_ACTOR
FROM FILM AS F LEFT JOIN FILM_ACTOR AS FC
ON F.FILM_ID = FC.FILM_ID
group by F.FILM_ID;

-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”
    
SELECT A.ACTOR_ID,A.FIRST_NAME,A.LAST_NAME,F.TITLE
FROM ACTOR AS A LEFT JOIN FILM_ACTOR AS FC
ON A.ACTOR_ID=FC.ACTOR_ID LEFT JOIN FILM AS F
ON FC.FILM_ID=F.FILM_ID; 

-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”

SELECT distinct TITLE,F.DESCRIPTION
FROM FILM AS F INNER JOIN INVENTORY AS INV
ON F.FILM_ID = INV.FILM_ID
WHERE INV.STORE_ID = 2;

-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

-- UNION(MERGE TWO DIFF TABLE WITHOUT KEY )

(SELECT FIRST_NAME,LAST_NAME,"STAFF_MEMBER" AS DESIGNATION
FROM STAFF
union
SELECT FIRST_NAME,LAST_NAME,"ADVISOR_MEMBER" AS DESIGNATION
FROM ADVISOR);





