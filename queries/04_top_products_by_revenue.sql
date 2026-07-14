-- Q4: Which products generate the highest net revenue after accounting for refunds and returns?
-- Owner: Adyasha  |  Last updated: 2026-07-09
-- Sanity check:
-- sum(gross_revenue) ≈ sum(qty * unit_price) from order_items.
-- net_revenue <= gross_revenue for every product.

with order_product_revenue as (

    select
        oi.order_id
      , pv.product_id
      , p.product_name
      , c.category_name                                             as category
      , sum(oi.qty * oi.unit_price)                                 as product_revenue
      , sum(oi.qty)                                                 as units_sold

    from ecom.order_items oi

    left join ecom.product_variants pv
        on oi.variant_id = pv.variant_id

    left join ecom.products p
        on pv.product_id = p.product_id

    left join ecom.categories c
        on p.category_id = c.category_id

    group by
        oi.order_id
      , pv.product_id
      , p.product_name
      , c.category_name

)

, order_totals as (

    select
        opr.order_id
      , sum(opr.product_revenue)                                    as order_revenue

    from order_product_revenue opr

    group by
        opr.order_id

)

, product_refunds as (

    select
        opr.product_id
      , sum(
            orf.refund_amount
            * (
                opr.product_revenue
                / nullif(
                      ot.order_revenue
                    , 0
                  )
              )
        )                                                            as refunds_amount

    from order_product_revenue opr

    inner join order_totals ot
        on opr.order_id = ot.order_id

    inner join ecom.order_refunds orf
        on opr.order_id = orf.order_id

    group by
        opr.product_id

)

, product_returns as (

    select
        pv.product_id
      , count(distinct rr.return_id)                                as returns_count

    from ecom.return_items ri

    inner join ecom.return_requests rr
        on ri.return_id = rr.return_id

    inner join ecom.product_variants pv
        on ri.variant_id = pv.variant_id

    group by
        pv.product_id

)

select
    opr.product_id
  , opr.product_name
  , opr.category
  , sum(opr.product_revenue)                                        as gross_revenue
  , count(distinct opr.order_id)                                    as orders_count
  , sum(opr.units_sold)                                             as units_sold
  , coalesce(pr.returns_count, 0)                                   as returns_count
  , round(
        coalesce(pr.returns_count, 0)::numeric
        / nullif(
              count(distinct opr.order_id)
            , 0
          )
    , 4)                                                            as return_rate
  , round(
        coalesce(pf.refunds_amount, 0)
    , 2)                                                            as refunds_amount
  , round(
        sum(opr.product_revenue)
        - coalesce(pf.refunds_amount, 0)
    , 2)                                                            as net_revenue

from order_product_revenue opr

left join product_returns pr
    on opr.product_id = pr.product_id

left join product_refunds pf
    on opr.product_id = pf.product_id

group by
    opr.product_id
  , opr.product_name
  , opr.category
  , pr.returns_count
  , pf.refunds_amount

order by
    net_revenue desc;