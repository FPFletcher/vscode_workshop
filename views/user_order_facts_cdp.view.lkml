view: user_order_facts_cdp {
  derived_table: {
    sql: 
      SELECT
        user_id,
        COUNT(DISTINCT order_id) as lifetime_orders,
        SUM(sale_price) as lifetime_revenue,
        MIN(created_at) as first_order_date,
        MAX(created_at) as latest_order_date,
        COUNT(DISTINCT DATE(created_at)) as days_with_orders
      FROM thelook_ecommerce.order_items
      GROUP BY user_id
    ;;
  }
  
  # PRIMARY KEY
  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }
  
  # CDP TRANSFORMATION 2: Repeat Purchase Behavior
  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }
  
  dimension: repeat_purchase_tier {
    type: tier
    tiers: [1, 2, 5, 10, 20]
    style: integer
    sql: ${lifetime_orders} ;;
  }
  
  dimension: customer_type {
    type: string
    sql: CASE
      WHEN ${lifetime_orders} = 1 THEN '1. One-Time Buyer'
      WHEN ${lifetime_orders} = 2 THEN '2. Repeat Buyer'
      WHEN ${lifetime_orders} <= 5 THEN '3. Regular Customer'
      WHEN ${lifetime_orders} <= 10 THEN '4. Loyal Customer'
      ELSE '5. VIP Customer'
    END ;;
  }
  
  # CDP TRANSFORMATION 3: User Segment (Lifetime Spend)
  dimension: lifetime_revenue {
    type: number
    sql: ${TABLE}.lifetime_revenue ;;
    value_format_name: usd
  }
  
  dimension: ltv_segment {
    type: string
    sql: CASE
      WHEN ${lifetime_revenue} < 50 THEN '1. Low Value ($0-50)'
      WHEN ${lifetime_revenue} < 150 THEN '2. Medium Value ($50-150)'
      WHEN ${lifetime_revenue} < 300 THEN '3. High Value ($150-300)'
      WHEN ${lifetime_revenue} < 500 THEN '4. Premium ($300-500)'
      ELSE '5. VIP ($500+)'
    END ;;
  }
  
  dimension_group: first_order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.first_order_date ;;
  }
  
  dimension_group: latest_order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.latest_order_date ;;
  }
  
  dimension: days_since_last_order {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${latest_order_date}, DAY) ;;
  }
  
  dimension: recency_segment {
    type: string
    sql: CASE
      WHEN ${days_since_last_order} <= 30 THEN '1. Active (0-30 days)'
      WHEN ${days_since_last_order} <= 90 THEN '2. Recent (30-90 days)'
      WHEN ${days_since_last_order} <= 180 THEN '3. Lapsing (90-180 days)'
      ELSE '4. Dormant (180+ days)'
    END ;;
  }
  
  dimension: days_with_orders {
    type: number
    sql: ${TABLE}.days_with_orders ;;
  }
  
  # MEASURES
  measure: total_lifetime_revenue {
    type: sum
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
  }
  
  measure: average_lifetime_revenue {
    type: average
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
  }
  
  measure: average_lifetime_orders {
    type: average
    sql: ${lifetime_orders} ;;
    value_format_name: decimal_1
  }
}
