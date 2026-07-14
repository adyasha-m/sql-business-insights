-- Q3: Funnel Conversion by Acquisition Channel
-- Owner: Adyasha  |  Last updated: 2026-07-09
-- Sanity check:
-- sessions >= product_view_sessions >= add_to_cart_sessions
-- >= begin_checkout_sessions >= purchase_sessions.
-- All conversion rates are between 0 and 1.

with funnel_by_channel as (

    select
        coalesce(sc.channel, 'direct')                                  as channel
      , count(distinct s.session_id)                                    as sessions
      , count(distinct s.session_id)
            filter (
                where se.event_type = 'product_view'
            )                                                           as product_view_sessions
      , count(distinct s.session_id)
            filter (
                where se.event_type = 'add_to_cart'
            )                                                           as add_to_cart_sessions
      , count(distinct s.session_id)
            filter (
                where se.event_type = 'begin_checkout'
            )                                                           as begin_checkout_sessions
      , count(distinct s.session_id)
            filter (
                where se.event_type = 'purchase'
            )                                                           as purchase_sessions

    from ecom.sessions s

    left join ecom.session_channels sc
        on s.session_id = sc.session_id

    left join ecom.session_events se
        on s.session_id = se.session_id

    where
        s.started_at >= '2026-04-19'

    group by
        coalesce(sc.channel, 'direct')

)

select
    fbc.channel
  , fbc.sessions
  , fbc.product_view_sessions
  , fbc.add_to_cart_sessions
  , fbc.begin_checkout_sessions
  , fbc.purchase_sessions

  , round(
        fbc.add_to_cart_sessions::numeric
        / nullif(
              fbc.product_view_sessions
            , 0
          )
    , 4)                                                                as view_to_cart_rate

  , round(
        fbc.begin_checkout_sessions::numeric
        / nullif(
              fbc.add_to_cart_sessions
            , 0
          )
    , 4)                                                                as cart_to_checkout_rate

  , round(
        fbc.purchase_sessions::numeric
        / nullif(
              fbc.begin_checkout_sessions
            , 0
          )
    , 4)                                                                as checkout_to_purchase_rate

  , round(
        fbc.purchase_sessions::numeric
        / nullif(
              fbc.sessions
            , 0
          )
    , 4)                                                                as session_to_purchase_rate

from funnel_by_channel fbc

order by
    fbc.sessions desc;