# What 10 SQL Queries Told Me About This Business

## Memo

### TL;DR

- **Revenue is declining because fewer orders are being placed, not because customers are spending less.** Daily revenue fell from roughly **₹6–8M** to **₹2.5–4M**, while AOV, payment success, cancellations, and refunds remained largely stable.
- **Customer retention is weakening for newer cohorts.** Month 1 retention dropped from **50% (March cohort)** to **18% (May cohort)**, suggesting the business is acquiring customers but struggling to keep them engaged.
- **Revenue is highly concentrated among high-value customers.** Customers with **₹20,000+ lifetime value contribute 88% of total revenue**, making retention of this segment critical.

---

# Insights

## 1. The decline in revenue is driven by fewer orders, not smaller baskets

**Based on:** [Q1 – Daily Business Summary](queries/q1_daily_business_summary.sql)

The first thing that stood out was the trend in daily revenue. Revenue declined from roughly **₹6–8M per day** during late March and early April to around **₹2.5–4M per day** through May and June. Order volume followed almost the same pattern.

What did **not** change was just as important. Average Order Value remained stable, as did payment success rates, cancellation rates, and refund amounts. That suggests customers who decide to buy are spending roughly the same amount as before, and operational metrics haven't deteriorated enough to explain the decline.

The implication is that the business is processing **fewer successful orders**, rather than generating less value from each customer. That shifts attention away from pricing or checkout optimization and toward demand generation.

**Monday action:** Compare traffic, new customer acquisition, and conversion trends around mid-April to identify whether the drop was driven by reduced traffic or lower visitor-to-purchase conversion before making changes to pricing or promotions.

---

## 2. Acquiring customers isn't enough if newer cohorts don't come back

**Based on:** [Q2 – Monthly Signup Cohort Retention](queries/02_monthly_cohort_retention.sql)

Customer acquisition increased during the period. Monthly cohort size grew from **1.7k customers in March** to **3.5k customers in May**. However, retention moved in the opposite direction.

Month 1 retention fell from **50%** for the March cohort to **43%** in April and **18%** in May. Month 2 retention also declined from **42%** to **18%**. While later cohorts haven't matured enough to evaluate Month 3 retention, the available data already points to weaker engagement among recently acquired customers.

This is consistent with the broader revenue trend. If fewer customers return after their first purchase, future order volume naturally declines even if acquisition remains healthy.

**Monday action:** Segment retention by acquisition channel, first product purchased, and onboarding experience to identify whether the decline is concentrated within a specific customer group.

---

## 3. The purchase funnel is consistent across channels

**Based on:** [Q3 – Funnel Conversion by Acquisition Channel](queries/03_funnel_by_acquisition.sql)

I expected to find one marketing channel performing significantly worse than the others, but that wasn't the case.

Organic generated the highest traffic (about **23k sessions**) while affiliate generated the least (about **4k sessions**). Despite this large difference in volume, the funnel behaved almost identically across channels. Roughly **40%** of product viewers added an item to cart, around **80%** continued to checkout, and approximately **85%** completed the purchase after reaching checkout.

This suggests there isn't a channel-specific leak in the purchase journey. The checkout experience appears to be working consistently regardless of acquisition source.

**Monday action:** Rather than redesigning the checkout funnel, compare acquisition costs and revenue by channel. If conversion is already similar across channels, improving the quality or quantity of incoming traffic is likely to have a larger impact than funnel optimization alone.

---

## 4. Revenue depends heavily on a small group of high-value customers

**Based on:** [Q8 – Customer Lifetime Value](queries/08_customer_LTV_bucket_share.sql)

One of the strongest findings was how concentrated revenue is across the customer base.

Customers with a lifetime value of **₹20,000 or more contribute 88% of total revenue**, while customers below **₹5,000** contribute only around **2%**. This indicates that a relatively small segment of customers drives the majority of the business.

This doesn't mean low-value customers aren't important—they are often future high-value customers—but it does suggest that retaining existing high-value customers should be a priority alongside acquiring new ones.

**Monday action:** Identify the acquisition channels, products, and behaviors associated with high-LTV customers and prioritize retention initiatives for this segment before expanding acquisition spend.

---

## 5. Operational issues exist, but they don't appear to be the primary business constraint

**Based on:** [Q6 – Payment Failure Analysis](queries/06_payment_failure_analysis.sql), [Q7 – Delivery SLA](queries/07_delivery_SLA_breach.sql)

The operational analyses identified opportunities for improvement without indicating that they explain the overall revenue decline.

UPI recorded the highest payment failure rate at **5.5%**, with **Gateway Timeout** responsible for around **24%** of failed transactions. On the logistics side, **EcomExpress Express** missed the 5-day SLA in **21%** of deliveries, compared with only **3.1%** for **Delhivery Standard**.

Both findings are operationally meaningful because they can affect customer experience. However, neither aligns closely enough with the broader revenue trends to conclude that they are the primary cause of declining sales.

**Monday action:** Quantify the downstream impact of operational issues by comparing return rates, refunds, repeat purchases, and churn for customers who experienced payment failures or delayed deliveries against those who did not.

---

# What I'd investigate next

- **What changed around mid-April?** Revenue and order volume declined noticeably after this period, but the current analysis doesn't explain whether the cause was lower traffic, weaker acquisition, or changing customer behavior.
- **Which acquisition channels produce high-LTV customers?** Revenue is highly concentrated among customers with ₹20k+ lifetime value, but the current dataset doesn't connect LTV with acquisition quality.
- **Do payment failures and delivery delays reduce repeat purchases?** Both issues affect customer experience, but their impact on retention and customer lifetime value still needs to be quantified.

---

# Methodology note

This analysis was built using **10 SQL queries** over the ecommerce PostgreSQL database. The queries covered daily business performance, cohort retention, funnel conversion, product and category performance, payment failures, delivery SLA, customer lifetime value, repeat purchase intervals, and marketing attribution.

Where appropriate, cancelled orders and in-transit shipments were excluded to avoid biasing business metrics. Funnel analysis was restricted to sessions after **19 April 2026**, when event instrumentation became available. For repeat purchase analysis, I excluded same-day repeat orders from the summary because they are more likely to represent split purchases within a single shopping session than genuine customer return behavior.
