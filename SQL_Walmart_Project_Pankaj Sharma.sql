/*/Pankaj Sharma final project SQL/*/
-- Creating Database.
CREATE DATABASE walmart;

-- Using Database. 
USE walmart;

-- Importing walmart dataset after editing the column headers and changing date format to yyyy-mm-dd. 
SELECT * FROM walmart;

# Task 1: Analyze the total sales for each branch and compare the growth rate across months to find the top performer.
WITH cte AS (SELECT DISTINCT branch, 
	         DATE_FORMAT(date,'%m') AS month,
             ROUND(SUM(total)) AS total_sales_per_month
             FROM walmart
             GROUP BY branch, month
			 ORDER BY branch,month)
SELECT branch,
       month,
       total_sales_per_month,
       LEAD(total_sales_per_month,2) OVER (PARTITION BY branch) AS total_sales_in_3rd_month,
       ROUND((LEAD(total_sales_per_month,2) OVER (PARTITION BY branch) - total_sales_per_month)/total_sales_per_month*100,2) AS growth_rate
FROM cte;
       
#Task 2: Walmart needs to determine which product line contributes the highest profit to each branch. 
# Consideration: From the data it is clear that gross_income is the gross_profit on total (based on, gross income = total*gross_margin_percentage)
SELECT branch,
	   product_line,
       ROUND(SUM(gross_income)) AS income,
       RANK() OVER(PARTITION BY branch ORDER BY SUM(gross_income) DESC) AS product_line_rank
FROM walmart
GROUP BY branch,product_line
ORDER BY branch,product_line;

#Task 3: Classify customers into three tiers: High, Medium, and Low spenders based on their total purchase amounts.
# Consideration: Here as the customer_id is not provided. it is not possible to sum their purchases. I am considering product_line for classification.  
SELECT branch,
       product_line,
       ROUND(SUM(total)) AS total_sales,
       CASE WHEN ROUND(SUM(total)) > 20000 THEN 'High Spending'
            WHEN ROUND(SUM(total)) < 15000 THEN 'Low Spending'
            ELSE 'Medium Spending'
		END AS spending_level
FROM walmart
GROUP BY branch,product_line
ORDER BY branch,product_line;

#Task 4: Unusually high or low sales compared to the average for the product line
SELECT product_line,
       ROUND(AVG(total)) AS avg_sales,
       ROUND(MAX(total)) AS maximum_sale,
       ROUND(MIN(total)) AS minimim_sale
FROM walmart
GROUP BY product_line
ORDER BY product_line;

#Task 5: most popular payment method in each city to tailor marketing strategies
SELECT city,
       payment AS payment_method,
       COUNT(total) AS No_of_transactions,
       RANK() OVER(PARTITION BY city ORDER BY COUNT(total) DESC) AS rank_of_payment_method
FROM walmart
GROUP BY city,payment_method
ORDER BY city,payment_method;

#Task 6:  the sales distribution between male and female customers on a monthly basis. 
SELECT gender,
       DATE_FORMAT(date,'%m') AS month,
       ROUND(SUM(total)) AS total_sales
FROM walmart
GROUP BY gender,month
ORDER BY gender,month;

#Task 7: which product lines are preferred by different customer types
SELECT customer_type,
	   product_line,
       COUNT(product_line) AS no_of_customers,
       ROUND(SUM(total)) AS total_expenditure
FROM walmart
GROUP BY customer_type,product_line
ORDER BY customer_type,product_line;

#Task 8: identify customers who made repeat purchases within a specifictime frame (e.g., within 30 days).
# Consideration: There are no customer details. Hence counting product lines in 30 days period. 
WITH cte AS (SELECT product_line,
	                DATE_FORMAT(date,'%Y-%m-%d') AS dates,
					COUNT(product_line) AS no_of_purchases
             FROM walmart 
             GROUP BY product_line,dates
             ORDER BY product_line,dates)
SELECT product_line,
       SUM(no_of_purchases) AS total_purchases_between_1st_and_30th_day       
FROM cte
WHERE dates BETWEEN dates AND DATE_ADD(dates,INTERVAL 30 DAY)
GROUP BY product_line;

#Task 9:  top 5 customers who have generated the most sales revenue
#Consideration: There are no customer ids. Hence top 3 product lines by sales revenue. 
WITH ranked_revenue AS (
    SELECT product_line,
           ROUND(SUM(total)) AS total_revenue,
           RANK() OVER(ORDER BY SUM(total) DESC) AS revenue_rank
    FROM walmart
    GROUP BY product_line
)
SELECT product_line, total_revenue, revenue_rank
FROM ranked_revenue
WHERE revenue_rank <= 3;

#Task 10: which day of the week brings the highest sales.
SELECT DISTINCT DAYNAME(date) AS week_day,
	   ROUND(SUM(total)) AS total_sales
FROM walmart
GROUP BY week_day
ORDER BY total_sales DESC;
