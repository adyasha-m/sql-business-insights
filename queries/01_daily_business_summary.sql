-- Q1: Daily Business Summary with DoD and Same-Weekday WoW
-- Owner: Adyasha  |  Last updated: 2026-07-08
-- Sanity check:
-- paid_order_rate between 0 and 1 on every row.
-- sum(orders) equals count(*) from ecom.orders for the same date window.

with daily_orders as (

    select
        o.created_at::date                                              as order_date
      , count(distinct o.order_id)                                      as orders
      , coalesce(sum(o.total), 0)                                       as revenue
      , coalesce(sum(orf.refund_amount), 0)                             as refunds_amount
      , round(
            coalesce(
                count(
                    distinct case
                        when o.payment_status = 'paid'
                            then o.order_id
                    end
                )::numeric
                / nullif(count(distinct o.order_id), 0)
              , 0
            )
        , 2)                                                            as paid_order_rate
      , round(
            coalesce(
                count(
                    distinct case
                        when o.status = 'cancelled'
                            then o.order_id
                    end
                )::numeric
                / nullif(count(distinct o.order_id), 0)
              , 0
            )
        , 2)                                                            as cancelled_order_rate
      , round(
            coalesce(
                sum(o.total)
                / nullif(count(distinct o.order_id), 0)
              , 0
            )
        , 2)                                                            as aov

    from ecom.orders o

    left join ecom.order_refunds orf
        on o.order_id = orf.order_id

    group by
        o.created_at::date

)

select
    do.order_date
  , do.revenue
  , do.orders
  , do.aov
  , do.paid_order_rate
  , do.cancelled_order_rate
  , do.refunds_amount
  , round(
        (
            do.revenue
            - lag(do.revenue, 1) over (
                  order by do.order_date
              )
        )
        / nullif(
              lag(do.revenue, 1) over (
                  order by do.order_date
              )
            , 0
          )
    , 4)                                                                as revenue_vs_yesterday_pct
  , round(
        (
            do.revenue
            - lag(do.revenue, 7) over (
                  order by do.order_date
              )
        )
        / nullif(
              lag(do.revenue, 7) over (
                  order by do.order_date
              )
            , 0
          )
    , 4)                                                                as revenue_vs_last_weekday_pct

from daily_orders do

order by
    do.order_date desc;