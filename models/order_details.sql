{{ config(materialized='table') }}

-- order_details: one enriched row per order line — customer, warehouse,
-- promotion and product attributes joined onto the raw order feed. This model
-- powers the finance revenue dashboards and the analysts' discount / margin
-- queries, so dropping a column here can break things far outside this repo.
-- That is exactly what Blast Radius flags on the pull request.

select
    order_id,
    order_date,
    order_status,
    order_total,
    cost_of_delivery,
    customer_id,
    cust_email,
    warehouse_id,
    warehouse_name,
    promotion_name,
    product_id,
    product_name,
    unit_price,
    quantity,
    line_total,
    discount_amount,
    discount_percent,
    updated_at
from {{ ref('raw_order_details') }}
