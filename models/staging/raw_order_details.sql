{{ config(materialized='view') }}

-- Raw order-line feed from the order-entry system. A real project would source()
-- straight from the warehouse; it is trimmed to a passthrough here so the demo
-- stays focused on `order_details` — the model whose columns downstream depends on.

select *
from {{ source('order_entry', 'order_details') }}
