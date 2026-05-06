view: order_items_cdp {
  sql_table_name: thelook_ecommerce.order_items ;;
  
  # PRIMARY KEY
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  
  # FOREIGN KEYS
  dimension: order_id {
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }
  
  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }
  
  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }
  
  dimension: inventory_item_id {
    type: number
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }
  
  # REVENUE DIMENSIONS
  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
  }
  
  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }
  
  # DATE DIMENSIONS
  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  
  dimension_group: shipped {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.shipped_at ;;
  }
  
  dimension_group: delivered {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.delivered_at ;;
  }
  
  dimension_group: returned {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
  }
  
  # MEASURES
  measure: count {
    type: count
    drill_fields: [id, created_date, sale_price]
  }
  
  measure: total_revenue {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [order_id, user_id, sale_price, created_date]
  }
  
  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }
  
  measure: count_returned {
    type: count
    filters: [returned_date: "-NULL"]
  }
  
  measure: return_rate {
    type: number
    sql: 1.0 * ${count_returned} / NULLIF(${count}, 0) ;;
    value_format_name: percent_2
  }
}
