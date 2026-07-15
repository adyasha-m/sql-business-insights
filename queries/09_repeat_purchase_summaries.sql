-- Q9: Repeat Purchase Summary
-- Owner: Adyasha  |  Last updated: 2026-07-15
-- Sanity check:
-- days_to_next_order >= 0 on every row.
-- median_days_to_next_order <= p90_days_to_next_order.
--
-- Note:
-- Same-day repeat orders are likely customers splitting a single shopping
-- session into multiple orders. Both versions are shown for comparison.

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

, summary_including_same_day as (

    select
        round(
            avg(rpi.days_to_next_order)
        , 2)                                                       as avg_days_to_next_order

      , round(
            (
                percentile_cont(0.5)
                    within group (
                        order by rpi.days_to_next_order
                    )
            )::numeric
        , 2)                                                       as median_days_to_next_order

      , round(
            (
                percentile_cont(0.9)
                    within group (
                        order by rpi.days_to_next_order
                    )
            )::numeric
        , 2)                                                       as p90_days_to_next_order

      , count(distinct rpi.customer_id)                            as customers_with_repeat_order

    from repeat_purchase_interval rpi

)

, summary_excluding_same_day as (

    select
        round(
            avg(rpi.days_to_next_order)
        , 2)                                                       as avg_days_to_next_order

      , round(
            (
                percentile_cont(0.5)
                    within group (
                        order by rpi.days_to_next_order
                    )
            )::numeric
        , 2)                                                       as median_days_to_next_order

      , round(
            (
                percentile_cont(0.9)
                    within group (
                        order by rpi.days_to_next_order
                    )
            )::numeric
        , 2)                                                       as p90_days_to_next_order

      , count(distinct rpi.customer_id)                            as customers_with_repeat_order

    from repeat_purchase_interval rpi

    where
        rpi.days_to_next_order > 0

)

select
    'including_same_day'                                           as version
  , sis.avg_days_to_next_order
  , sis.median_days_to_next_order
  , sis.p90_days_to_next_order
  , sis.customers_with_repeat_order

from summary_including_same_day sis

union all

select
    'excluding_same_day'                                           as version
  , ses.avg_days_to_next_order
  , ses.median_days_to_next_order
  , ses.p90_days_to_next_order
  , ses.customers_with_repeat_order

from summary_excluding_same_day ses;