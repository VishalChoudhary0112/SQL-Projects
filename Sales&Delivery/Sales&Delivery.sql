######################################################## Sales and Delivery:#########################################################


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