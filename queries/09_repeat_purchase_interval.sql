-- Q9: Repeat Purchase Interval
-- Owner: Adyasha  |  Last updated: 2026-07-11
-- Sanity check:
-- days_to_next_order >= 0 on every row.
-- median_days_to_next_order <= p90_days_to_next_order.

with customer_orders as (

    select
        o.customer_id
      , o.order_id
      , o.created_at::date                                        as order_date
      , lead(o.created_at::date)
            over (
                partition by o.customer_id
                order by o.created_at
            )                                                      as next_order_date

    from ecom.orders o

    where
        lower(o.status) <> 'cancelled'

)

, repeat_purchase_interval as (

    select
        co.customer_id
      , co.order_id
      , co.order_date
      , co.next_order_date
      , (
            co.next_order_date
            - co.order_date
        )                                                          as days_to_next_order

    from customer_orders co

)

select
    rpi.customer_id
  , rpi.order_id
  , rpi.order_date
  , rpi.next_order_date
  , rpi.days_to_next_order

from repeat_purchase_interval rpi

order by
    rpi.customer_id
  , rpi.order_date;


-- Q9 Summary (Including Same-Day Repeat Orders)
-- Owner: Adyasha  |  Last updated: 2026-07-11
-- Sanity check:
-- days_to_next_order >= 0 on every row.
-- median_days_to_next_order <= p90_days_to_next_order.

with customer_orders as (

    select
        o.customer_id
      , o.order_id
      , o.created_at::date                                        as order_date
      , lead(o.created_at::date)
            over (
                partition by o.customer_id
                order by o.created_at
            )                                                      as next_order_date

    from ecom.orders o

    where
        lower(o.status) <> 'cancelled'

)

, repeat_purchase_interval as (

    select
        co.customer_id
      , (
            co.next_order_date
            - co.order_date
        )                                                          as days_to_next_order

    from customer_orders co

    where
        co.next_order_date is not null

)

select
    round(
        avg(rpi.days_to_next_order)
    , 2)                                                           as avg_days_to_next_order

  , round(
        (
            percentile_cont(0.5)
                within group (
                    order by rpi.days_to_next_order
                )
        )::numeric
    , 2)                                                           as median_days_to_next_order

  , round(
        (
            percentile_cont(0.9)
                within group (
                    order by rpi.days_to_next_order
                )
        )::numeric
    , 2)                                                           as p90_days_to_next_order

  , count(distinct rpi.customer_id)                               as customers_with_repeat_order

from repeat_purchase_interval rpi;


-- Q9 Summary (Excluding Same-Day Repeat Orders)
-- Owner: Adyasha  |  Last updated: 2026-07-11
-- Sanity check:
-- days_to_next_order >= 0 on every row.
-- median_days_to_next_order <= p90_days_to_next_order.
--
-- Interpretation:
-- Same-day repeat orders likely represent customers splitting a single
-- shopping session into multiple orders rather than true customer return
-- behaviour. This version is recommended for win-back email timing.

with customer_orders as (

    select
        o.customer_id
      , o.order_id
      , o.created_at::date                                        as order_date
      , lead(o.created_at::date)
            over (
                partition by o.customer_id
                order by o.created_at
            )                                                      as next_order_date

    from ecom.orders o

    where
        lower(o.status) <> 'cancelled'

)

, repeat_purchase_interval as (

    select
        co.customer_id
      , (
            co.next_order_date
            - co.order_date
        )                                                          as days_to_next_order

    from customer_orders co

    where
        co.next_order_date is not null
        and (
            co.next_order_date
            - co.order_date
        ) > 0

)

select
    round(
        avg(rpi.days_to_next_order)
    , 2)                                                           as avg_days_to_next_order

  , round(
        (
            percentile_cont(0.5)
                within group (
                    order by rpi.days_to_next_order
                )
        )::numeric
    , 2)                                                           as median_days_to_next_order

  , round(
        (
            percentile_cont(0.9)
                within group (
                    order by rpi.days_to_next_order
                )
        )::numeric
    , 2)                                                           as p90_days_to_next_order

  , count(distinct rpi.customer_id)                               as customers_with_repeat_order

from repeat_purchase_interval rpi;