-- Q8: Customer Lifetime Value (LTV) + Bucket Share of Revenue
-- Owner: Adyasha  |  Last updated: 2026-07-11
-- Sanity check:
-- sum(total_revenue) across all customers equals revenue from ecom.orders
-- (excluding cancelled orders), within 0.5%.
-- ltv_bucket_share_of_revenue summed across distinct buckets equals 1.0.

with customer_ltv as (

    select
        o.customer_id
      , min(o.created_at::date)                                      as first_order_date
      , max(o.created_at::date)                                      as last_order_date
      , count(distinct o.order_id)                                   as total_orders
      , sum(o.total)                                                 as total_revenue
      , round(avg(o.total), 2)                                       as aov

    from ecom.orders o

    where
        lower(o.status) <> 'cancelled'

    group by
        o.customer_id

)

, customer_buckets as (

    select
        cl.customer_id
      , cl.first_order_date
      , cl.last_order_date
      , cl.total_orders
      , cl.total_revenue
      , cl.aov
      , case
            when cl.total_revenue < 1000
                then '0-999'
            when cl.total_revenue < 5000
                then '1000-4999'
            when cl.total_revenue < 20000
                then '5000-19999'
            else '20000+'
        end                                                         as ltv_bucket

    from customer_ltv cl

)

select
    cb.customer_id
  , cb.first_order_date
  , cb.last_order_date
  , cb.total_orders
  , cb.total_revenue
  , cb.aov
  , cb.ltv_bucket
  , round(
        sum(cb.total_revenue)
            over (
                partition by cb.ltv_bucket
            )
        / nullif(
              sum(cb.total_revenue)
                  over ()
            , 0
          )
    , 4)                                                            as ltv_bucket_share_of_revenue

from customer_buckets cb

order by
    cb.total_revenue desc;