-- Q5: Which categories generate the most revenue, and which have the highest return rates?
-- Owner: Adyasha  |  Last updated: 2026-07-09
-- Sanity check:
-- return_rate_pct between 0 and 100.
-- returns <= orders_with_category for every category.
-- sum(revenue) ≈ sum(line_total) from paid orders.

with category_sales as (

    select
        c.category_name                                              as category
      , count(distinct o.order_id)                                   as orders_with_category
      , sum(oi.qty)                                                  as units_sold
      , sum(oi.line_total)                                           as revenue

    from ecom.orders o

    inner join ecom.order_items oi
        on o.order_id = oi.order_id

    inner join ecom.product_variants pv
        on oi.variant_id = pv.variant_id

    inner join ecom.products p
        on pv.product_id = p.product_id

    inner join ecom.categories c
        on p.category_id = c.category_id

    where
        o.payment_status = 'paid'

    group by
        c.category_name

)

, category_returns as (

    select
        c.category_name                                              as category
      , count(distinct rr.order_id)                                  as returns

    from ecom.return_requests rr

    inner join ecom.return_items ri
        on rr.return_id = ri.return_id

    inner join ecom.product_variants pv
        on ri.variant_id = pv.variant_id

    inner join ecom.products p
        on pv.product_id = p.product_id

    inner join ecom.categories c
        on p.category_id = c.category_id

    group by
        c.category_name

)

select
    cs.category
  , cs.orders_with_category
  , cs.units_sold
  , cs.revenue
  , coalesce(cr.returns, 0)                                          as returns
  , round(
        100.0
        * coalesce(cr.returns, 0)
        / nullif(
              cs.orders_with_category
            , 0
          )
    , 2)                                                             as return_rate_pct

from category_sales cs

left join category_returns cr
    on cs.category = cr.category

order by
    cs.revenue desc;