-- Q7: Delivery SLA Breach by Carrier × Shipping Method
-- Owner: Adyasha  |  Last updated: 2026-07-11
-- Sanity check:
-- avg_delivery_days <= p90_delivery_days for every row.
-- late_rate between 0 and 1.
-- Shipments with delivered_at is null are excluded (in transit).

with shipment_delivery as (

    select
        sc.carrier_name                                             as carrier
      , sm.method_name                                              as shipping_method
      , (
            s.delivered_at::date
            - s.shipped_at::date
        )                                                           as delivery_days

    from ecom.shipments s

    inner join ecom.shipping_carriers sc
        on s.carrier_id = sc.carrier_id

    inner join ecom.shipping_methods sm
        on s.shipping_method_id = sm.shipping_method_id

    where
        s.delivered_at is not null

)

select
    sd.carrier
  , sd.shipping_method
  , count(*)                                                        as delivered_orders
  , round(
        avg(sd.delivery_days)
    , 2)                                                            as avg_delivery_days
  , round(
        (
            percentile_cont(0.5)
                within group (
                    order by sd.delivery_days
                )
        )::numeric
    , 2)                                                            as median_delivery_days
  , round(
        (
            percentile_cont(0.9)
                within group (
                    order by sd.delivery_days
                )
        )::numeric
    , 2)                                                            as p90_delivery_days
  , count(*)
        filter (
            where sd.delivery_days > 5
        )                                                           as late_deliveries
  , round(
        (
            count(*)
                filter (
                    where sd.delivery_days > 5
                )::numeric
        )
        / nullif(
              count(*)
            , 0
          )
    , 4)                                                            as late_rate

from shipment_delivery sd

group by
    sd.carrier
  , sd.shipping_method

order by
    late_rate desc
  , avg_delivery_days desc;