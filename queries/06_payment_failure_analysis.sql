-- Q6: Which payment methods fail most, and what is the most common reason?
-- Owner: Adyasha  |  Last updated: 2026-07-09
-- Sanity check:
-- failure_rate between 0 and 1.
-- top_error_share_of_failures between 0 and 1.

with payment_summary as (

    select
        pm.method_name                                              as payment_method
      , count(*)                                                    as attempts
      , count(*)
            filter (
                where pt.status = 'failed'
            )                                                       as failures

    from ecom.payment_transactions pt

    inner join ecom.payment_intents pi
        on pt.payment_intent_id = pi.payment_intent_id

    inner join ecom.payment_methods pm
        on pi.payment_method_id = pm.payment_method_id

    group by
        pm.method_name

)

, error_rankings as (

    select
        pm.method_name                                              as payment_method
      , pt.error_code
      , pt.error_message
      , count(*)                                                    as error_count
      , row_number() over (
            partition by pm.method_name
            order by count(*) desc
        )                                                           as rn

    from ecom.payment_transactions pt

    inner join ecom.payment_intents pi
        on pt.payment_intent_id = pi.payment_intent_id

    inner join ecom.payment_methods pm
        on pi.payment_method_id = pm.payment_method_id

    where
        pt.status = 'failed'

    group by
        pm.method_name
      , pt.error_code
      , pt.error_message

)

select
    ps.payment_method
  , ps.attempts
  , ps.failures
  , round(
        ps.failures::numeric
        / nullif(
              ps.attempts
            , 0
          )
    , 4)                                                            as failure_rate
  , er.error_code                                                   as top_error_code
  , er.error_message                                                as top_error_message
  , round(
        er.error_count::numeric
        / nullif(
              ps.failures
            , 0
          )
    , 4)                                                            as top_error_share_of_failures

from payment_summary ps

inner join error_rankings er
    on ps.payment_method = er.payment_method

where
    er.rn = 1

order by
    failure_rate desc
  , ps.failures desc;