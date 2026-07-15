-- Q10: Attribution Comparison - First-Touch vs Last-Touch Revenue by Channel
-- Owner: Adyasha  |  Last updated: 2026-07-15
-- Sanity check:
-- Total revenue under first_touch equals total revenue under last_touch
-- and equals total non-cancelled revenue from ecom.orders (within 0.5%).
-- Orders without attribution touches are bucketed as 'direct'.

with customer_touches as (

    select
        o.order_id
      , at.channel
      , at.touched_at
      , row_number() over (
            partition by o.order_id
            order by at.touched_at
        )                                                          as first_touch_rank
      , row_number() over (
            partition by o.order_id
            order by at.touched_at desc
        )                                                          as last_touch_rank

    from ecom.orders o

    inner join ecom.sessions s
        on o.customer_id = s.customer_id

    inner join ecom.attribution_touches at
        on s.session_id = at.session_id

    where
        lower(o.status) <> 'cancelled'
        and at.touched_at <= o.created_at

)

, first_touch as (

    select
        ct.order_id
      , ct.channel

    from customer_touches ct

    where
        ct.first_touch_rank = 1

)

, last_touch as (

    select
        ct.order_id
      , ct.channel

    from customer_touches ct

    where
        ct.last_touch_rank = 1

)

, attributed_orders as (

    select
        'first_touch'                                              as attribution_model
      , coalesce(ft.channel, 'direct')                             as channel
      , o.order_id
      , o.total                                                    as revenue

    from ecom.orders o

    left join first_touch ft
        on o.order_id = ft.order_id

    where
        lower(o.status) <> 'cancelled'

    union all

    select
        'last_touch'                                               as attribution_model
      , coalesce(lt.channel, 'direct')                             as channel
      , o.order_id
      , o.total                                                    as revenue

    from ecom.orders o

    left join last_touch lt
        on o.order_id = lt.order_id

    where
        lower(o.status) <> 'cancelled'

)

, attribution_summary as (

    select
        ao.attribution_model
      , ao.channel
      , sum(ao.revenue)                                            as revenue
      , count(distinct ao.order_id)                                as orders

    from attributed_orders ao

    group by
        ao.attribution_model
      , ao.channel

)

select
    ats.attribution_model
  , ats.channel
  , round(ats.revenue, 2)                                          as revenue
  , ats.orders
  , round(
        ats.revenue
        / nullif(
              sum(ats.revenue)
                  over (
                      partition by ats.attribution_model
                  )
            , 0
          )
    , 4)                                                           as share_of_revenue

from attribution_summary ats

order by
    ats.attribution_model
  , ats.revenue desc;