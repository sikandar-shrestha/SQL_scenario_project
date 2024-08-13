use DB1;

---------- scenario 1 --------------------------------------------------------------
/*
Table : person_data
-------------------
persons		fruit
-------------------
p1			apple
p1			banana
p1			mango
p2			banana
p2			apple
p3			mango
p3			apple
-------------------

output:- Only p2 (who likes only banana and apple)
*/
--------------------------------------------------------------------------------
select * from person_data;

insert into person_data(persons,fruit) 
values
('p1','apple'),
('p1','banana'),
('p1','mango'),
('p2','banana'),
('p2','apple'),
('p3','mango'),
('p3','apple');

select * from person_data;

select distinct t1.persons from person_data as t1
	inner join person_data as t2 on t1.persons=t2.persons
    where t1.fruit='banana' and t2.fruit='apple';
    
select persons from person_data
group by persons
having count(*)=2;

select tbl1.persons
from (select distinct t1.persons from person_data as t1
	inner join person_data as t2 on t1.persons=t2.persons
    where t1.fruit='banana' and t2.fruit='apple') as tbl1
join 
	(select persons from person_data
group by persons
having count(*)=2) as tbl2
on tbl1.persons=tbl2.persons
where tbl2.persons is not null;


--------- scenario 2 -----------------------------------
select * from salestable;

insert into salestable(num_sold,fruit,sale_date)
values
(10,'apples','2022-12-18'),
(8,'oranges','2022-12-18'),
(5,'apple','2022-12-19'),
(5,'oranges','2022-12-19'),
(7,'apples','2022-12-20'),
(10,'oranges','2022-12-20');

select * from salestable;

select sale_date,
		num_sold,
        lead(num_sold) over(partition by sale_date order by sale_date) as sold1
from salestable;

select sale_date,
		num_sold,
        sold1,
        (num_sold-sold1) as diff
from 
		(select sale_date,
				num_sold,
				lead(num_sold) over(partition by sale_date order by sale_date) as sold1
		from salestable) as tb
where sold1 is not null; 


-- ----------- scenario 3 ---------------------------------------
/*
table: sp_val
task: Replace all special values and get the table w/o special values  

val1
----
111
222
333
444

*/
-- ===================================================================================
select * from sp_val;


insert into sp_val(val1)
values
(111),
(222),
('*'),
(333),
(444),
('???');


select * from sp_val;

SELECT 
    REGEXP_REPLACE(val1, '\\*|\\?\\?\\?$', '') AS val1
FROM 
    sp_val;
    

-- ======================== scenario 4 ================================================
/*
table: emp
-------------------------------------
name 	age 	dept 		sal
-------------------------------------
ram 	20 		finance 	50000
sudeep 	25 		sales 		30000
suresh 	22 		finance 	50000
pradeep 28 		finance 	20000
iqbal 	22 		sales 		20000
--------------------------------------
Find average salary of employees for each department and order employees
with a department by age.
*/
-- ==============================================================================
select * from emp;

select dept,
	   name,
       age,
       avg(sal) over (partition by dept) as avg_sal
from emp
order by dept, age desc;


-- ========================================scenario 5===========================================================
/*
Table: country_data
---------------------------
country			population
--------------------------
Brazil			10000
India			15000
US				20000
UK				12000
Europe			12000
----------------------------
Output:
1) 1st row should have india in country column.
2) 2nd row should have highest population irrespective of country.
3) 3rd row should have lowest population.
*/
-- ==============================================================================================================

insert into country_data(country,population)
values
('Brazil',10000),
('India',15000),
('US',20000),
('UK',12000),
('Europe',12000);

select * from country_data;



select country as data
from country_data where country='India'
union select max(population) as max_pop
		from country_data
union select min(population) as min_pop
		from country_data;
        
        
-- ================================= scenario 6 ========================================================
/*
Table: mobile_data
-----------------------------------------------
user_id	mobilenumber	msg_type	mob_date
-----------------------------------------------
1		9988445566		outgoing	2022-jan-23
2		8899445566		incoming	2022-feb-01
3		7799884455		outgoing	2022-jan-23
1		6698112244		outgoing	2022-feb-02
1		5598445566	    incoming	2022-jan-24
1		1199885544		outgoing	2022-feb-05
------------------------------------------------
Output: 
----------------------------
user_id	 mon_data	diff
----------------------------
1		feb			1
1		jan			0
------------------------
*/
-- ===============================================================================================================
select * from mobile_data;

INSERT INTO mobile_data(user_id, mobilenumber, msg_type, mob_date)
VALUES
(1, 9988445566, 'outgoing', '2022-jan-23'),
(2, 8899445566, 'incoming', '2022-feb-01'),
(3, 7799884455, 'outgoing', '2022-jan-23'),
(1, 6698112244, 'outgoing', '2022-feb-02'),
(1, 5598445566, 'incoming', '2022-jan-24'),
(1, 1199885544, 'outgoing', '2022-feb-05');


select * from mobile_data;

SELECT 
    *,
    DATE_FORMAT(STR_TO_DATE(mob_date, '%Y-%b-%d'), '%b') AS mon_data
FROM 
    mobile_data;
    

SELECT 
    *,
    DATE_FORMAT(STR_TO_DATE(mob_date, '%Y-%b-%d'), '%b') AS mon_data
FROM 
    mobile_data
where msg_type ='outgoing';


select * from 
(
select user_id, mon_data, (out_num - diff) as diff1
from 
(
select user_id, mon_data, out_num, lead(out_num) over (partition by msg_type) as diff
from 
(
select user_id, msg_type, mon_data, count(*) as out_num
from
(
select *, date_format(str_to_date(mob_date,'%Y-%b-%d'),'%b') as mon_data
from mobile_data
) as a
where msg_type='outgoing'
group by user_id, msg_type, mon_data
order by user_id, mon_data
) as b
) as c
) as d
where (diff1 <> 0 or diff1 is not null);

-- ============================================ scenario 7 ================================================================================== 
/*
Table: temperature_data
-------------------------------------
city	tdate			temperature
-------------------------------------
Bang	12-16-2021		35 
Hyd		06-05-2022		43
che		07-20-2020		46
Mum		02-19-2019		40
del		04-27-2023		45
Bang	11-16-2021		45	
Hyd		07-05-2022		25
che		09-20-2020		50
Mum		05-19-2019		20
Del		05-27-2023		30
------------------------------------
Need to write a query to get below output without using "order by".
(output consists only 2 records having maximum tempertures along with their year)

Output:
-----------------------------
Year		Max Temperature
------------------------------
2020		45
2023		43
------------------------------
Can you please help me in this?
*/
-- ====================================================================================================================================
select * from temperature_data;

insert into temperature_data(city,tdate,temperature)
values
('Bang',	'12-16-2021', 35 ),
('Hyd	',	'06-05-2022'	,	43),
('che'	,	'07-20-2020'	,	46),
('Mum'	,	'02-19-2019'	,	40),
('del'	,	'04-27-2023'	,	45),
('Bang'	,'11-16-2021'		,45),	
('Hyd'	,	'07-05-2022'	,	25),
('che'	,	'09-20-2020'	,	50),
('Mum'	,	'05-19-2019'	,	20),
('Del'	,	'05-27-2023'	,	30);

select * from temperature_data;



select year,
		max(temperature)
from ( select * ,
			  date_format(str_to_date(tdate,'%m-%d-%Y'),'%Y') as year
		from temperature_data
	 ) as a
group by year limit 2;

select year,
		max(temperature)
from ( select * ,
			  date_format(str_to_date(tdate,'%m-%d-%Y'),'%Y') as year
		from temperature_data
	 ) as a
group by year ;

-- =============================scenario 8 =======================================================================================================
/*
Table: b1
-------------
bname
-------------
Hema
Sai
Gomathi
Gayatri
Liyansh
Shah
Anu
Elango
India
Oli
-------------
Fetch name column.
Condition only those name start with a vowel and ends with vowel.

*/
-- ====================================================================================================================================
select * from b1;


insert into b1(bname) values
('Hema'),
('Sai'),
('Gomathi'),
('Gayatri'),
('Liyansh'),
('Shah'),
('Anu'),
('Elango'),
('India'),
('Oli');


select bname
from b1
where left(lower(bname),1) in ('a','e','i','o','u')
	  and 
      right(lower(bname),1) in ('a','e','i','o','u')
;




-- ==================================scenario 9 ==================================================================================================
/*
Table: market
---------------------------------------------
market_id	market_name		amt		location
---------------------------------------------
101			D-mart			500		chennai
102			super store		300		chennai
103			coludera		300		chennai
105			super store		200		pondy
104			walmart	alter	100		pondy		
---------------------------------------------
find top 2 performing markets in each and every location based on amt.
*/
-- ====================================================================================================================================
select * from market;

insert into market(market_id, market_name, amt, location) values
(101,'D-mart',500,'chennai'),
(102,'super store',300,'chennai'),
(103,'coludera',300,'chennai'),
(105,'super store',200,'pondy'),
(104,'walmart',100,'pondy');


select * from market;

-- 1st method ( partition by )
SELECT market_id, market_name, amt, location
FROM (
    SELECT 
        market_id, 
        market_name, 
        amt, 
        location,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY amt DESC) as rn
    FROM market
) AS ranked
WHERE rn <= 2;

/*
Output: top 2 performing markets in each & every location based on amt.
------------------------------------------------
market_id	market_name		amt		location
------------------------------------------------
101			super store		500		chennai
102			super store 	300		chennai
105			super store		200		pondy
104			walmart			100		pondy
------------------------------------------------
*/

select location,
market_name,
amt
from market
where concat(location, amt) in (
								select concat(location,max(amt))
                                from market
                                group by location
                                );
/*
Output:top 1 performing markets in each & every location based on amt.
--------------------------------
location	market_name		amt
--------------------------------
chennai		D-mart	alter	500
pondy	    super store		200
-------------------------------
*/

-- ==================================scenario 10 ========================================================================================
/*
Table: emp_data
--------------------------
employee		salary
-------------------------
A				10
B         		10
C 				9
D 				8
F 				8
G 				7
H 				6
------------------------
Question: Query to display the top 10 salary but the salary should not be repeated.
		  In the above query only C, G, & H should be displayed.	
Output: 
---------
employee
--------
C 
G 
H 
-----------
*/
-- ====================================================================================================================================
CREATE TABLE `DB1`.`emp_data` (
  `employee` VARCHAR(10) NOT NULL,
  `salary` DOUBLE NOT NULL);


select * from emp_data;

insert into emp_data(employee, salary) values
('A',10),
('B' ,10),
('C' ,9),
('D',8),
('F',8),
('G',7),
('H',6);

select employee
from emp_data
where salary 
in (select salary
	from emp_data
    group by salary
    having count(employee)=1
    );



-- ==================================scenario 11 ==================================================================================================
/*
Table1: product
-------------------------------------------------------
prod_id		prod_name		prod_desc		prod_price 
--------------------------------------------------------
p1			prod1			prod1			10
p2			prod2			prod2			20
p3			prod3			prod3			30
p4			prod4			prod4			40
p5			prod5			prod5			50
---------------------------------------------------------

Table2: customer
-------------------------------------------------------
cust_id		name			region			address
--------------------------------------------------------
c1			cust1			ind			mumbai
c2			cust2			us			california
c3			cust3			uk			buckingham place
c4			cust4			ind			chennai
c5			cust5			us			alaska
---------------------------------------------------------

Table3: transactions
--------------------------------------------------------------------------------------
cust_id		txn_id			txn_amt			prod_name		prod_id		purchase_date 
--------------------------------------------------------------------------------------
c1			T1				100				prod1			p1			2022-12-02
c1			T2				500				prod4			p1			2022-12-02
c2			T3				100				prod2			p2			2022-12-05
c3			T4				100				prod4			p3			2022-12-08
c4			T5				100				prod3			p4			2022-12-09
c5			T1				600				prod1			p1			2022-12-10
---------------------------------------------------------------------------------------

Query below questions:
1) product which has been purchased by large number of consumers.
2) product which has not been sold so far.
3) customer who has purchased any product more than once per day.
*/
-- ====================================================================================================================================
CREATE TABLE `scene11`.`product` (
  `prod_id` varchar(5) NOT NULL,
  `prod_name` VARCHAR(45) NOT NULL,
  `prod_desc` VARCHAR(45) NOT NULL,
  `prod_price` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`prod_id`));
  
  use scene11;
  
  select * from product;
  
  insert into product(prod_id, prod_name, prod_desc, prod_price) values
('p1','prod1','prod1',10),
('p2','prod2','prod2',20),
('p3','prod3','prod3',30),
('p4','prod4','prod4',40),
('p5','prod5','prod5',50);


CREATE TABLE `scene11`.`customer` (
  `cust_id` VARCHAR(5) NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `region` VARCHAR(45) NOT NULL,
  `address` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`cust_id`));

select * from customer;

insert into customer(cust_id, name, region, address) values
('c1','cust1','ind'	,'mumbai'),
('c2','cust2','us','california'),
('c3','cust3','uk','buckingham place'),
('c4','cust4','ind','chennai'),
('c5','cust5','us','alaska');


CREATE TABLE `scene11`.`transactions` (
  `cust_id` VARCHAR(5) NOT NULL,
  `txn_id` VARCHAR(5) NOT NULL,
  `txn_amt` DOUBLE NOT NULL,
  `prod_name` VARCHAR(45) NOT NULL,
  `prod_id` VARCHAR(5) NOT NULL,
  `purchase_date` VARCHAR(45) NOT NULL);



select * from transactions;

insert into transactions(cust_id, txn_id, txn_amt, prod_name, prod_id, purchase_date) values
('c1',			'T1',				100,				'prod1',			'p1',			'2022-12-02'),
('c1',			'T2',				500,				'prod4',			'p1',			'2022-12-02'),
('c2',			'T3',				100,				'prod2',			'p2',			'2022-12-05'),
('c3',			'T4',				100,				'prod4',			'p3',			'2022-12-08'),
('c4',			'T5',				100,				'prod3',			'p4',			'2022-12-09'),
('c5',			'T1',				600,				'prod1',			'p1',			'2022-12-10');


-- Q1) product which has been purchased by large number of consumers.

select prod_id
from transactions
group by prod_id
having count(prod_id)>1;

-- Q2) product which has not been sold so far.
select p.prod_id
from product p
left join transactions t on p.prod_id = t.prod_id
where t.prod_id is null;

-- Q3) customer who has purchased any product more than once per day.
select cust_id
from transactions
group by cust_id
having count(purchase_date) > 1;

-- ==================================scenario 12 ==================================================================================================
/*
Table: 

*/

-- ====================================================================================================================================




-- ==================================scenario 13 ==================================================================================================
/*
Table: 

*/

-- ====================================================================================================================================




-- ==================================scenario 14 ==================================================================================================
/*
Table: 

*/

-- ====================================================================================================================================



