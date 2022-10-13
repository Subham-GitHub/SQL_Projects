/*
----------------------------------
------       TASK 01        ------
----------------------------------
*/
CREATE WAREHOUSE iNEURON_assigments
WITH WAREHOUSE_SIZE = 'SMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE;

USE WAREHOUSE iNEURON_assigments;

CREATE DATABASE INEURON_TASK1;
USE DATABASE INEURON_TASK1;

CREATE OR REPLACE TABLE SHOPPING_HISTORY (
PRODUCT VARCHAR(50) NOT NULL,
QUANTITY INTEGER NOT NULL,
UNIT_PRICE INTEGER NOT NULL);

INSERT INTO SHOPPING_HISTORY VALUES ('milk',3,10),
('bread',7,3),
('bread',5,2);

SELECT 
    *
FROM
    SHOPPING_HISTORY;

SELECT 
    PRODUCT, SUM(QUANTITY * UNIT_PRICE) AS TOTAL_SALES
FROM
    SHOPPING_HISTORY
GROUP BY PRODUCT;

/*
----------------------------------
------       TASK 02        ------
----------------------------------
*/

CREATE DATABASE INEURON_TASK2;
USE DATABASE INEURON_TASK2;

CREATE OR REPLACE TABLE PHONES(
NAME VARCHAR(20) NOT NULL UNIQUE,
PHONE_NUMBER INTEGER NOT NULL UNIQUE);

CREATE TABLE CALLS (
    ID INTEGER NOT NULL,
    CALLER INTEGER NOT NULL,
    CALLEE INTEGER NOT NULL,
    DURATION INTEGER NOT NULL,
    UNIQUE (ID)
);

INSERT INTO PHONES VALUES ('Jack',1234),
('Lena',3333),
('Mark',9999),
('Anna',7582);

INSERT INTO CALLS VALUES (25,1234,7582,8),
(7,9999,7582,1),
(18,9999,3333,4),
(2,7582,3333,3),
(3,3333,1234,1),
(21,3333,1234,1);

SELECT 
    *
FROM
    PHONES;
SELECT 
    *
FROM
    CALLS;

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------
FRIST OF ALL WE HAVE TO BUILD/RETURN A TABLE WHICH CONTAINS ALL DATA BY USING JOINS BUT MOST IMPORTANTLY WE HAVE TO AGGREGATE THEM AS WELL BECAUSE OF REPEATED
COSTUMER IN CALLER/CALLEE COLUMN SO WE GET THE TABLE BY RUNNING THE QUERY BELOW
--------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

SELECT 
    P.NAME, SUM(C.DURATION) AS SUM_DURATION
FROM
    PHONES P
        INNER JOIN
    CALLS C ON P.PHONE_NUMBER = C.CALLER
GROUP BY NAME 
UNION SELECT 
    P.NAME, SUM(C.DURATION) AS SUM_DURATION
FROM
    PHONES P
        INNER JOIN
    CALLS C ON P.PHONE_NUMBER = C.CALLEE
GROUP BY NAME;

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------
NOW WE HAVE TO USE THE ABOVE QUERY AS A SUB QUERY, NOW AS PER OUR REQUIREMENT WE SELECT THE COLUMN AS REQUIRED TO SOLVE OUR PROBLEM STATEMENT AND BELOW RESULT
WILL GIVE US THE DESIRED RESULT
--------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

SELECT 
    NAME
FROM
    (SELECT 
        P.NAME, SUM(C.DURATION) AS SUM_DURATION
    FROM
        PHONES P
    INNER JOIN CALLS C ON P.PHONE_NUMBER = C.CALLER
    GROUP BY NAME UNION SELECT 
        P.NAME, SUM(C.DURATION) AS SUM_DURATION
    FROM
        PHONES P
    INNER JOIN CALLS C ON P.PHONE_NUMBER = C.CALLEE
    GROUP BY NAME) AS NEW_TABLE
GROUP BY NAME
HAVING SUM(SUM_DURATION) >= 10
ORDER BY NAME;

/*
----------------------------------
------       TASK 2.2       ------      >>> TEST CASES <<<
----------------------------------
*/
TRUNCATE TABLE CALLS;
TRUNCATE TABLE PHONES;

INSERT INTO PHONES VALUES ('John',6356),
('Addison',4315),
('Kate',8003),
('Ginny',9831);

INSERT INTO CALLS VALUES (65,8003,9831,7),
(100,9831,8003,3),
(145,4315,9831,18);

SELECT 
    *
FROM
    PHONES;
SELECT 
    *
FROM
    CALLS;

SELECT 
    NAME
FROM
    (SELECT 
        P.NAME, SUM(C.DURATION) AS SUM_DURATION
    FROM
        PHONES P
    INNER JOIN CALLS C ON P.PHONE_NUMBER = C.CALLER
    GROUP BY NAME UNION SELECT 
        P.NAME, SUM(C.DURATION) AS SUM_DURATION
    FROM
        PHONES P
    INNER JOIN CALLS C ON P.PHONE_NUMBER = C.CALLEE
    GROUP BY NAME) AS NEW_TABLE
GROUP BY NAME
HAVING SUM(SUM_DURATION) >= 10
ORDER BY NAME;

/*
----------------------------------
------       TASK 03        ------
----------------------------------
*/

CREATE DATABASE INEURON_TASK3;
USE DATABASE INEURON_TASK3;

CREATE TABLE TRANSACTIONS (
    AMOUNT INTEGER NOT NULL,
    DATE DATE NOT NULL
);

INSERT INTO TRANSACTIONS VALUES (1000,'2020-01-06'),
(-10,'2020-01-14'),
(-75,'2020-01-20'),
(-5,'2020-01-25'),
(-4,'2020-01-29'),
(2000,'2020-03-10'),
(-75,'2020-03-12'),
(-20,'2020-03-15'),
(40,'2020-03-15'),
(-50,'2020-03-17'),
(200,'2020-10-10'),
(-200,'2020-10-10');

SELECT 
    *
FROM
    TRANSACTIONS;

/*
---------------------------------
------       TASK 3.1      ------   >>> TEST CASES <<<
---------------------------------
*/
WITH CREDITS AS 
(SELECT M,SUM(AMOUNT)AS TOTAL FROM (SELECT AMOUNT, YEAR(DATE) AS Y, MONTH(DATE) AS M FROM TRANSACTIONS WHERE AMOUNT<0 ORDER BY Y,M)
GROUP BY M,Y
HAVING TOTAL<-100
ORDER BY M,Y)
SELECT SUM(AMOUNT)-((12-(SELECT COUNT(*) AS NON_CHARGES FROM CREDITS))*5) AS BALANCE FROM TRANSACTIONS;


/*
STEP 1:TASK TO FIND OUT CREDITS
*/
WITH CREDITS AS (SELECT AMOUNT, YEAR(DATE) AS Y, MONTH(DATE) AS M FROM TRANSACTIONS WHERE AMOUNT<0 ORDER BY Y,M)

/*
STEP 2:TASK TO FIND OUT SUM OF CREDITS MONTHLY
*/
SELECT  M ,SUM(AMOUNT)AS TOTAL FROM CREDITS 
GROUP BY M,Y;

/*
ALTERNATE METHOD WHEN CRITERIA IS GREATER THAN 3 TRANSACTION AND SUM OF CREDIT IS GREATER THAN 100
*/

/*    STEP 1:   */

WITH CRED_TABLE AS (SELECT AMOUNT, YEAR(DATE) AS Y, MONTH(DATE) AS M FROM TRANSACTIONS WHERE AMOUNT<0 ORDER BY Y,M)
SELECT COUNT(AMOUNT) AS TOTAL_TRANS, SUM(AMOUNT) AS TOTAL_CREDIT FROM CRED_TABLE GROUP BY Y,M;

/*    STEP 2:   */

WITH M_CRED AS (WITH CRED_TABLE AS (SELECT AMOUNT, YEAR(DATE) AS Y, MONTH(DATE) AS M FROM TRANSACTIONS WHERE AMOUNT<0 ORDER BY Y,M)
SELECT COUNT(AMOUNT) AS TOTAL_TRANS, SUM(AMOUNT) AS TOTAL_CREDIT FROM CRED_TABLE GROUP BY Y,M HAVING TOTAL_TRANS>=3 AND TOTAL_CREDIT<=-100)
SELECT SUM(AMOUNT)-(5*(12-(SELECT COUNT(TOTAL_TRANS) FROM M_CRED))) AS BALANCE FROM TRANSACTIONS;

/* ONE MORE */

WITH DESIRED_TABLE AS (SELECT SUM(AMOUNT) AS TOTAL_TRANS,COUNT(AMOUNT) AS NO_OF_TRANS
FROM TRANSACTIONS
WHERE AMOUNT<0
GROUP BY YEAR(DATE),MONTH(DATE)
HAVING TOTAL_TRANS<=-100 AND NO_OF_TRANS>=3)
SELECT SUM(AMOUNT)-(5*(12-(SELECT COUNT(*) FROM DESIRED_TABLE))) AS BALANCE FROM TRANSACTIONS;

/*
---------------------------------
-------   TASK 3.2        -------      >>> TEST CASES <<<
---------------------------------
*/

TRUNCATE TRANSACTIONS;

INSERT INTO TRANSACTIONS VALUES (1,'2020-06-29'),
(35,'2020-02-20'),
(-50,'2020-02-03'),
(-1,'2020-02-26'),
(-200,'2020-08-01'),
(-44,'2020-02-07'),
(-5,'2020-02-25'),
(1,'2020-06-29'),
(1,'2020-06-29'),
(-100,'2020-12-29'),
(-100,'2020-12-30'),
(-100,'2020-12-31');

WITH DESIRED_TABLE AS (SELECT SUM(AMOUNT) AS TOTAL_TRANS,COUNT(AMOUNT) AS NO_OF_TRANS
FROM TRANSACTIONS
WHERE AMOUNT<0
GROUP BY YEAR(DATE),MONTH(DATE)
HAVING TOTAL_TRANS<=-100 AND NO_OF_TRANS>=3)
SELECT SUM(AMOUNT)-(5*(12-(SELECT COUNT(*) FROM DESIRED_TABLE))) AS BALANCE FROM TRANSACTIONS;

/*
---------------------------------
-------   TASK 3.3        -------      >>> TEST CASES <<<
---------------------------------
*/

TRUNCATE TRANSACTIONS;

INSERT INTO TRANSACTIONS VALUES (6000,'2020-04-03'),
(5000,'2020-04-02'),
(4000,'2020-04-01'),
(3000,'2020-03-01'),
(2000,'2020-02-01'),
(1000,'2020-01-01');

WITH DESIRED_TABLE AS (SELECT SUM(AMOUNT) AS TOTAL_TRANS,COUNT(AMOUNT) AS NO_OF_TRANS
FROM TRANSACTIONS
WHERE AMOUNT<0
GROUP BY YEAR(DATE),MONTH(DATE)
HAVING TOTAL_TRANS<=-100 AND NO_OF_TRANS>=3)
SELECT SUM(AMOUNT)-(5*(12-(SELECT COUNT(*) FROM DESIRED_TABLE))) AS BALANCE FROM TRANSACTIONS;
