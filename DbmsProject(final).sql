######################################################## Part 1 – Sales and Delivery:#########################################################


# Question 1: Find the top 3 customers who have the maximum number of orders.
select distinct customer_name,cd.cust_id,count(order_id)over(partition by cd.cust_id) as no_order
from cust_dimen cd join market_fact mf
on cd.cust_id=mf.cust_id
join orders_dimen od
on mf.ord_id=od.ord_id
order by no_order desc
limit 3;


-- --------------------------------------------------------------------------------------------------
# Question 2: Create a new column DaysTakenForDelivery that contains the date difference between 
# Order_Date and Ship_Date.
select od.order_id,order_date,ship_date,
datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y')) as DaysTakenForDelivery
from orders_dimen od join shipping_dimen sd
on od.order_id=sd.order_id
order by DaysTakenForDelivery desc;


-- --------------------------------------------------------------------------------------------------
# Question 3: Find the customer whose order took the maximum time to get delivered.

select distinct cd.cust_id,customer_name,mf.ord_id
from cust_dimen cd join market_fact mf
on cd.cust_id=mf.cust_id
where mf.ord_id=
(select ord_id
from orders_dimen od join shipping_dimen sd
on od.order_id=sd.order_id
order by datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y')) desc
limit 1);

-- --------------------------------------------------------------------------------------------------
# Question 4: Retrieve total sales made by each product from the data (use Windows function).
select distinct prod_id,round(sum(sales)over(partition by prod_id),2) as TotalSales
from market_fact;


-- --------------------------------------------------------------------------------------------------
# Question 5: Retrieve the total profit made from each product from the data (use windows function).
select distinct prod_id,round(sum(profit)over(partition by prod_id),2) as TotalProfit
from market_fact;


-- --------------------------------------------------------------------------------------------------
# Question 6: Count the total number of unique customers in January and how many of them came back every 
# month over the entire year in 2011

with temp as
(select  distinct c.cust_id as Unique_January,
Month(str_to_date(o.Order_Date, '%d-%m-%Y')) as Months
from cust_dimen c 
join market_fact m
on c.cust_id=m.cust_id
join orders_dimen o 
on m.ord_id=o.ord_id
where year(str_to_date(o.Order_Date, '%d-%m-%Y'))=2011 and Month(str_to_date(o.Order_Date, '%d-%m-%Y'))=1) 


select count(distinct Unique_January) as `Unique customers in January`,
count(distinct CameBack) as `Came Back Every Month`
from temp 
cross join
(select Unique_January as CameBack
from temp 
where Unique_January in 
(select distinct c.cust_id 
from cust_dimen c 
join market_fact m
on c.cust_id=m.cust_id
join orders_dimen o 
on m.ord_id=o.ord_id
where year(str_to_date(o.Order_Date, '%d-%m-%Y'))=2011 and Month(str_to_date(o.Order_Date, '%d-%m-%Y')) between 2 and 12
order by Month(str_to_date(o.Order_Date, '%d-%m-%Y'))))temp1;


########################################################### PART 2 : RESTAURANTS ###########################################################

--                          Questions based on performances of different restaurants, based on different options.

# Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.

select distinct alcohol,count(userID)over(partition by alcohol) as visit_count 
from geoplaces2 gp join rating_final rf
on gp.placeID=rf.placeID;


-- ---------------------------------------------------------------------------
# Question 2: -Let's find out the average rating according to alcohol and price 
# so that we can understand the rating in respective price categories as well.

select alcohol,price,avg(rating) as AVGrating
from geoplaces2 g join rating_final r
on g.placeID=r.placeID
group by alcohol,price
order by alcohol,price;


-- ---------------------------------------------------------------------------
# Question 3: Let’s write a query to quantify that what are the parking availability as 
# well in different alcohol categories along with the total number of restaurants.

select distinct alcohol,parking_lot,count(parking_lot) as Total_restaurants
from geoplaces2 g join chefmozparking cp
on g.placeid=cp.placeid
group by alcohol,parking_lot
order by alcohol;


-- ---------------------------------------------------------------------------
# Question 4: -Also take out the percentage of different cuisine in each alcohol type.

with temp as
(select alcohol,rcuisine,count(rcuisine) as countz
from geoplaces2 g join chefmozcuisine cc
on g.placeid=cc.placeid
group by alcohol,rcuisine 
order by alcohol)

select alcohol,rcuisine,countz,total,round((countz/total)*100,2) as percentage
from
(select alcohol,rcuisine,countz,sum(countz)over(partition by alcohol) as total from temp
group by alcohol,rcuisine)t
group by alcohol,rcuisine;


--                                 Let us now look at a different prospect of the data to check state-wise rating.

# Questions 5: - let’s take out the average rating of each state.
select distinct state,avg(rating)over(partition by state order by state) as avg_rating
from geoplaces2 g join rating_final rf
on g.placeid=rf.placeid;

-- ---------------------------------------------------------------------------
# Questions 6: -' Tamaulipas' Is the lowest average rated state. 
# Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.

select  t.placeid,name,alcohol,price,other_services,smoking_area,rcuisine,rating from (
select * from geoplaces2 where state='tamaulipas')t join rating_final r using(placeid) join chefmozcuisine
using(placeid) join chefmozparking using (placeid)
order by  rating;

-- ---------------------------------------------------------------------------
# Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and 
# tried Mexican or Italian types of cuisine, and also their budget level is low.
# We encourage you to give it a try by not using joins.

select  up.userID,avg(weight)over() as AvgWeight,food_rating,service_rating
from userprofile up,rating_final rt
where up.userID=rt.userID 
and budget ="low"
and up.userid in
(select userid from usercuisine where rcuisine in ('italian', 'mexican') and  rt.placeID in(
select placeID from geoplaces2 where name="kfc"));


##################################################################################################################

## Part 3:  Triggers 

# Question 1: Create two called Student_details and Student_details_backup.Insert some records into Student details.
# Problem:
# Let’s say you are studying SQL for two weeks. In your institute, there is an employee who has been maintaining the 
# student’s details and Student Details Backup tables. He / She is deleting the records from the Student details after
# the students completed the course and keeping the backup in the student details backup table by inserting the records 
# every time. You are noticing this daily and now you want to help him/her by not inserting the records for backup purpose 
# when he/she delete the records.write a trigger that should be capable enough to insert the student details in the backup 
# table whenever the employee deletes records from the student details table.
# Note: Your query should insert the rows in the backup table before deleting the records from student details.

## SOLUTION :


-- Creating a stundent information table :
CREATE TABLE  student_info
(
		student_id int primary key,
		student_name varchar(20),
		mail_id varchar(20),
		mobile int
); 

-- Creating a stundent information backup table :
create table student_info_backup
(  
		student_id int primary key,
		student_name varchar(20),
		mail_id varchar(20),
		mobile int
); 

-- Inserting student details into student_info table :
insert into student_info values
(1,'ABC','ABC@gmail.com',1234),
(2,'CBD','CBD@gmail.com',4567),
(3,'DFG','DFG@gmail.com',3737),
(4,'HJK','HJK@gmail.com',9898),
(5,'POPY','POPY@gmail.com',7878);


-- Creating a trigger to insert student details in backup before deletion from Student_info table :
create trigger before_deleting
before delete 
on student_info
for each row
insert into student_info_backup values(
old.student_id,old.student_name,old.mail_id,old.mobile);


-- CHECKING : 
delete from student_info where student_id=4;

-- Checking Updated values in both table :
select * from student_info_backup;
select * from student_info;
