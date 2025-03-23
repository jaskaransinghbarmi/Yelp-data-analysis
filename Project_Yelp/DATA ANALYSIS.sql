--find no of businesses in each category
with cte as(
select business_id, trim(A.value) as category 
from tbl_yelp_businesses,
lateral split_to_table(CATEGORIES,',') A 
)
select category, count(*)
from cte 
group by category
order by 2 desc

-- find top 10 users who reviewed the most businesses in the restaurants category
select r.user_id, count(distinct r.business_id)
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id
where b.categories ilike '%Restaurant%'
group by 1
order by 2 desc


-- find the most popular categories of business based on number of reviews
with cte as(
select business_id, trim(A.value) as category 
from tbl_yelp_businesses,
lateral split_to_table(CATEGORIES,',') A 
)
select category,count(*) as no_of_reviews from cte 
inner join tbl_yelp_reviews y on y.business_id=cte.business_id
group by category
order by 2 desc

--find top 3 most recent reviews for each business
with cte as(
select r.*,b.name,
row_number() over(partition by r.business_id order by review_date desc) as rn
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id
)
select * from cte 
where rn<=3

--find the month with the highest no of reviews
select month(review_date) as review_month, count(*) as no_of_reviews
from tbl_yelp_reviews
group by 1
order by 2 desc

-- find the percentage of 5 star reviews for each business
select b.business_id, b.name, count(*) as total_reviews,
count(case when r.review_stars=5 then 1 else 0 end) as star_5reviews,
star_5reviews*100/total_reviews as perc
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id
group by 1,2

--find the top 5 most reviewed businesses in each city
with cte as (
select b.city, b.business_id,b.name,count (*)
as total_reviews
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id
group by 1,2,3
)
select * from cte
qualify row_number () over (partition by city order by total_reviews desc) <=5

--find the average rating of businesses that have at least 100 reviews

select b.business_id,b.name, count(*) as total_reviews
,avg (review_stars) as avg_rating from tbl_yelp_reviews r
inner Join tbl_yelp_businesses b on r.business_id=b.business_id
group by 1,2
having count(*)>=100

--list the top 10 users who have written the most reviews, along with the businesses they have reviewed
with cte as(
select r.user_id, count(*) as total_reviews
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id
group by 1
order by 2 desc
limit 10
)
select user_id,business_id
from tbl_yelp_reviews where user_id in (select user_id from cte)
group by 1,2
order by user_id

--find top 10 businesses with the highest positive sentiment reviews
select r.business_id,b.name, count (*)
as total_reviews
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id where sentiments='Positive'
group by 1,2
order by 3 desc
Limit 10