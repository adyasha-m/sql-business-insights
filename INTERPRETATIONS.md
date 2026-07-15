## Q1 — Daily Business Summary with DoD and Same-Weekday WoW

**What the query does:** Tracks daily revenue, orders, AOV, payment and cancellation rates, refunds, and compares revenue against the previous day and the same weekday last week.

**Pattern choice:** Aggregated daily metrics in a CTE, then used `lag()` window functions to calculate DoD and WoW revenue changes without re-scanning the data.

**Business interpretation:** Revenue drops from roughly **₹6–8M/day** to **₹2.5–4M/day**, and orders follow the same trend. Meanwhile, AOV and operational metrics like paid order rate, cancellation rate, and refunds stay fairly steady, suggesting customers are spending about the same when they buy. The bigger issue seems to be **fewer orders**, not smaller baskets or checkout problems.

**What I'd ask next:** Did traffic or new customer acquisition fall around mid-April? I'd first check traffic and acquisition trends before deciding whether promotions are needed.

## Q2 — Monthly Signup Cohort Retention

**What the query does:** Tracks monthly customer cohorts and measures how many return to place an order in Months 1, 2, and 3 after signing up.

**Pattern choice:** Assigned each customer to a signup cohort, joined to non-cancelled orders, and used conditional aggregation to calculate retained users and retention rates for each month.

**Business interpretation:** New customer signups grew from **1.7k in March** to **3.5k in May**, but Month 1 retention fell from **50% → 43% → 18%**. Month 2 retention also dropped from **42% to 18%**, suggesting newer cohorts are becoming less engaged after signup. Month 3 retention can't be fairly compared yet since later cohorts haven't had enough time to mature.

**What I'd ask next:** What changed after March: marketing channels, onboarding, product experience, or customer quality? I'd also break retention down by acquisition channel to see if one source is driving the decline.

## Q3 — Funnel Conversion by Acquisition Channel

**What the query does :** Measures how sessions from each acquisition channel progress through the purchase funnel, from product view to purchase.

**Pattern choice :** Used conditional aggregation with `filter` to count sessions at each funnel stage in a single pass over `session_events`, using first-touch attribution from `session_channels`. Funnel analysis is restricted to sessions from **2026-04-19 onwards**, when event tracking was introduced.

**Business interpretation :** Organic contributes the most traffic (**~23k sessions**), while affiliate contributes the least (**~4k sessions**). However, every channel follows almost the same funnel of around **40%** of product viewers add to cart, **80%** continue to checkout, and **85%** complete the purchase. This suggests there isn't a channel-specific leak; the funnel is performing consistently across acquisition sources.

**What I'd ask next:** If conversion is similar across channels, what's driving the large difference in session volume? I'd compare acquisition costs and revenue by channel to identify where increasing traffic would have the biggest business impact.

## Q4 — Top Products by Net Revenue (After Refunds)

**What the query does:** Calculates gross revenue, returns, refunds, and net revenue for each product to identify the products contributing the most profit after refunds.

**Pattern choice:** Aggregated product revenue, returns, and refunds separately using three CTEs, then joined them in the final query to avoid double-counting revenue from one-to-many joins.

**Business interpretation:** The highest-performing products generate around **₹900k** in net revenue, with refunds having only a small impact on their rankings. Across the catalog, the average return rate is just **2.5%**, and many products have **no returns or refunds**, suggesting returns aren't a major driver of lost revenue overall.

**What I'd ask next:** Which product categories have the highest return rates, and are those returns concentrated in a handful of products?

## Q5 — Category Health: Purchases → Returns

**What the query does:** Summarizes sales and returns by product category to identify which categories drive the most revenue and which experience the highest return rates.

**Pattern choice:** Calculated sales and returns in separate CTEs, then joined them by category. This avoids double-counting and correctly maps returns through `return_items → product_variants → products → categories`.

**Business interpretation:** Smartwatches generate by far the most revenue (**₹59.7M**), followed by Headphones (**₹38.1M**) and Speakers (**₹33.0M**). Return rates are remarkably consistent across categories, ranging only from **2.44% to 3.11%**, with Accessories having the highest rate and Bedding the lowest. Since returns vary very little, the biggest differentiator between categories is **sales volume**, not product returns.

**What I'd ask next:** Are the high-return categories also the most profitable after accounting for refunds? I'd also look at return reasons to see whether specific categories have recurring quality or sizing issues.

## Q6 — Payment Failure Analysis (Method × Top Error Code)

**What the query does:** Compares payment methods by failure rate and identifies the most common error behind failed transactions for each method.

**Pattern choice:** Used one CTE to summarize attempts and failures by payment method, and another to rank error codes using `row_number()`, ensuring only the most frequent error per method is returned.

**Business interpretation:** UPI has the highest failure rate (**5.5%**), with **Gateway Timeout** accounting for **24%** of its failed payments, pointing to a reliability issue rather than user behavior. For Wallet, Netbanking, and Card, the leading failures are **Bank Decline** or **Fraud**, each contributing roughly **27–30%** of failures. Overall, no single error dominates, suggesting payment failures have multiple underlying causes.

**What I'd ask next:** Do customers who experience a payment failure eventually complete their purchase using another method, or do they abandon the order? I'd also compare customer retention and churn between users who experienced payment failures and those who didn't to measure the business impact.

## Q7 — Delivery SLA Breach by Carrier × Shipping Method

**What the query does:** Compares delivery performance across carrier and shipping method combinations using average, median, p90 delivery time, and the share of orders that miss the 5-day SLA.

**Pattern choice:** Calculated delivery days for completed shipments, then used `percentile_cont()` to capture the median and 90th percentile alongside average delivery time and SLA breach rate.

**Business interpretation:** **EcomExpress Express** has the weakest SLA performance, with **21%** of deliveries taking more than 5 days, closely followed by its Same Day service (**20%**). In contrast, **Delhivery Standard** is the most reliable, with only **3.1%** of deliveries missing the SLA and the lowest average delivery time (**3.16 days**). Overall, Delhivery consistently outperforms the other carriers, while EcomExpress shows the biggest opportunity for operational improvement.

**What I'd ask next:** Are late deliveries leading to higher return, refund, or cancellation rates? If so, I'd quantify the business impact and identify whether the delays are concentrated in specific regions or warehouses.

## Q8 — Customer LTV + Bucket Share of Revenue

**What the query does:** Calculates lifetime value for every customer, groups them into LTV buckets, and shows how much of the business's total revenue each bucket contributes.

**Pattern choice:** Aggregated customer-level metrics first, assigned LTV buckets using a `case` statement, then used window functions to calculate each bucket's share of total revenue without an extra aggregation step.

**Business interpretation:** Revenue is heavily concentrated among high-value customers. The **₹20,000+ LTV** bucket contributes **88% of total revenue**, while the **₹5,000–19,999** bucket contributes **9.5%**. Customers spending below **₹5,000** together account for only about **2%** of revenue, making the business highly dependent on retaining and growing its highest-value customers.

**What I'd ask next:** What channels or products bring in these high-LTV customers, and how does their retention compare with the lower-value segments? If we can identify what makes them different, we can target acquisition and loyalty efforts more effectively.

## Q9 — Repeat Purchase Interval

**What the query does:** Measures the time between consecutive purchases for each customer and summarizes how long customers typically take to place another order.

**Pattern choice:** Used the `lead()` window function to pair each order with the customer's next order, then excluded same-day repeat purchases from the summary since they likely represent split checkouts rather than customers returning to buy again.

**Business interpretation:** Excluding same-day orders, customers return after an average of **10.6 days**, with a **median of 6 days** and **90%** returning within **27 days**. Including same-day orders reduces the median to just **1 day** and the average to **6.3 days**, confirming that many "repeat purchases" are actually multiple orders from the same shopping session.

**What I'd ask next:** How does the repeat interval vary by customer segment, acquisition channel, or first product purchased?

## Q10 — Attribution Comparison: First-Touch vs Last-Touch Revenue by Channel

**What the query does:** Compares revenue attribution under first-touch and last-touch models to understand which channels introduce customers versus which channels ultimately drive conversions.

**Pattern choice:** Ranked attribution touches for each order using `row_number()` over the customer's touch history before the purchase, then attributed every non-cancelled order under both first-touch and last-touch models before comparing the revenue split across channels.

**Business interpretation:** The attribution model changes the revenue mix, but only slightly. Under **first-touch**, **Paid** accounts for **36%** of revenue versus **35%** under last-touch, while **Email** grows from **6.3%** to **7.1%** under last-touch. **Organic** remains the largest channel at around **40%** under both models, suggesting it consistently drives customer acquisition, while Email appears to play a slightly stronger role closer to conversion. Overall, the marketing mix is fairly stable, but some channels contribute differently depending on where they influence the customer journey.

**What I'd ask next:** How many marketing touches does a customer typically have before purchasing? I'd also compare the average time between the first touch, last touch, and purchase to understand which channels introduce customers early versus help close the sale
