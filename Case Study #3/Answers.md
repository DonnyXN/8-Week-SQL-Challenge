### A. Customer Journey

**Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.**

Customer 1:
This customer started off with a trial on August 1, 2020. Then moved on to the basic monthly plan after their trial ended on August 8, 2020.

![Alt text](image.png)


Customer 2:
This customer started off with a trial on September 20, 2020. Then moved on to the pro annual plan after their trial ended on September 27, 2020.

![Alt text](image-1.png)

Customer 11:
This customer started off with a trial on November 19, 2020. Then they canceled their plan after the trial on November 26, 2020.

![Alt text](image-2.png)

Customer 13:
This customer started off with a trial on December 15, 2020. Then moved on to the basic monthly plan after their trial ended on December 22, 2020. And on March 29, 2021 they upgraded to the pro monthly plan.

![Alt text](image-7.png)

Customer 15:
This customer started off with a trial on March 17, 2020. Upgraded to the pro monthly plan on March 24, 2020. But on April 29, 2020 they cancelled their subscription.

![Alt text](image-4.png)

Customer 16:
This customer started off with a trial on May 31, 2020. Then moved on to the basic monthly plan after their trial ended on June 7, 2020. And on October 21, 2021 they upgraded to the pro annual plan.

![Alt text](image-5.png)

Customer 18:
This customer started off with a trial on July 6, 2020. Then moved on to the pro monthly plan after their trial ended on July 13, 2020.

![Alt text](image-6.png)

Customer 19:
This customer started off with a trial on June 22, 2020. Then moved on to the pro monthly plan after their trial ended on June 29, 2020. And on August 29, 2020 they upgraded to the pro annual plan.

![Alt text](image-8.png)

---

### B. Data Analysis Questions

**1. How many customers has Foodie-Fi ever had?**

```sql
SELECT 
	COUNT(DISTINCT(customer_id)) AS customer_count
FROM 
	foodie_fi.subscriptions
```
![Alt text](image-9.png)

**2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value**

```sql

```


**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**
**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**
**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**
**6. What is the number and percentage of customer plans after their initial free trial?**
**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**
**8. How many customers have upgraded to an annual plan in 2020?**
**9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**
**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**
**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**