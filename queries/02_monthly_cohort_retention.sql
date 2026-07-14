-- Q2: Monthly Signup Cohort Retention
-- Owner: Adyasha  |  Last updated: 2026-07-09
-- Sanity check:
-- cohort_size equals count(distinct customer_id) from ecom.customers.
-- All retention rates are between 0 and 1.

with customer_cohorts as (

    select
        c.customer_id
      , date_trunc('month', c.created_at)                            as cohort_month

    from ecom.customers c

)

, customer_orders as (

    select distinct
        o.customer_id
      , date_trunc('month', o.created_at)                            as order_month

    from ecom.orders o

    where lower(o.status) <> 'cancelled'

)

select
    cc.cohort_month
  , count(distinct cc.customer_id)                                   as cohort_size

  , count(
        distinct case
            when co.order_month = cc.cohort_month + interval '1 month'
                then cc.customer_id
        end
    )                                                                 as m1_retained

  , count(
        distinct case
            when co.order_month = cc.cohort_month + interval '2 month'
                then cc.customer_id
        end
    )                                                                 as m2_retained

  , count(
        distinct case
            when co.order_month = cc.cohort_month + interval '3 month'
                then cc.customer_id
        end
    )                                                                 as m3_retained

  , round(
        count(
            distinct case
                when co.order_month = cc.cohort_month + interval '1 month'
                    then cc.customer_id
            end
        )::numeric
        / nullif(
              count(distinct cc.customer_id)
            , 0
          )
    , 4)                                                              as m1_retention_rate

  , round(
        count(
            distinct case
                when co.order_month = cc.cohort_month + interval '2 month'
                    then cc.customer_id
            end
        )::numeric
        / nullif(
              count(distinct cc.customer_id)
            , 0
          )
    , 4)                                                              as m2_retention_rate

  , round(
        count(
            distinct case
                when co.order_month = cc.cohort_month + interval '3 month'
                    then cc.customer_id
            end
        )::numeric
        / nullif(
              count(distinct cc.customer_id)
            , 0
          )
    , 4)                                                              as m3_retention_rate

from customer_cohorts cc

left join customer_orders co
    on cc.customer_id = co.customer_id

group by
    cc.cohort_month

order by
    cc.cohort_month;