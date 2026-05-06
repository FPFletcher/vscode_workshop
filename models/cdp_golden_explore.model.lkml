connection: "ffrancois_-_ecomm_trial"

include: "/views/*.view.lkml"

# CDP GOLDEN EXPLORE
explore: cdp_golden_explore {
  label: "🌟 CDP Golden Explore - Customer 360"
  description: "Complete customer data platform with demographics, behavior, segmentation, and period-over-period analysis"

  from: users_cdp
  view_name: users_cdp

  # Join Order Items for transaction-level data
  join: order_items_cdp {
    type: left_outer
    sql_on: ${users_cdp.id} = ${order_items_cdp.user_id} ;;
    relationship: one_to_many
  }

  # Join Orders for order-level data
  join: orders_cdp {
    type: left_outer
    sql_on: ${order_items_cdp.order_id} = ${orders_cdp.order_id} ;;
    relationship: many_to_one
  }

  # Join User Facts for CDP metrics (RFM, LTV, Segments)
  join: user_order_facts_cdp {
    type: left_outer
    sql_on: ${users_cdp.id} = ${user_order_facts_cdp.user_id} ;;
    relationship: one_to_one
  }

  # CDP TRANSFORMATION 4: Period over Period Analysis
  join: pop_metrics {
    from: order_items_cdp
    type: left_outer
    sql_on: ${users_cdp.id} = ${pop_metrics.user_id}
      AND ${pop_metrics.created_date} >= DATE_SUB(${order_items_cdp.created_date}, INTERVAL 1 MONTH)
      AND ${pop_metrics.created_date} < ${order_items_cdp.created_date} ;;
    relationship: one_to_many
  }
}
