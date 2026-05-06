view: orders_cdp {
  sql_table_name: thelook_ecommerce.orders ;;
  
  # PRIMARY KEY
  dimension: order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.order_id ;;
  }
  
  # FOREIGN KEY
  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
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
  
  # MEASURES
  measure: count {
    type: count
    drill_fields: [order_id, created_date, status]
  }
  
  measure: count_completed {
    type: count
    filters: [status: "Complete"]
  }
  
  measure: count_pending {
    type: count
    filters: [status: "Pending"]
  }
  
  measure: count_cancelled {
    type: count
    filters: [status: "Cancelled"]
  }
}
