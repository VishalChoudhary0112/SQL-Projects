########################################################### RESTAURANTS ###########################################################

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