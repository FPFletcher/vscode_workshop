view: users_cdp {
  sql_table_name: thelook_ecommerce.users ;;
  
  # PRIMARY KEY
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  
  # DEMOGRAPHIC DIMENSIONS
  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }
  
  dimension: age_tier {
    type: tier
    tiers: [18, 25, 35, 45, 55, 65]
    style: integer
    sql: ${age} ;;
  }
  
  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }
  
  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }
  
  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }
  
  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }
  
  dimension: postal_code {
    type: string
    sql: ${TABLE}.postal_code ;;
  }
  
  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }
  
  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }
  
  # DATE DIMENSIONS
  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  
  # CDP TRANSFORMATION 1: Customer Tenure
  dimension: customer_tenure_days {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${created_date}, DAY) ;;
  }
  
  dimension: customer_tenure_tier {
    type: tier
    tiers: [30, 90, 180, 365, 730]
    style: integer
    sql: ${customer_tenure_days} ;;
    description: "Customer lifetime: 0-30 days (New), 30-90 (Growing), 90-180 (Established), 180-365 (Loyal), 365+ (VIP)"
  }
  
  dimension: customer_lifecycle_stage {
    type: string
    sql: CASE
      WHEN ${customer_tenure_days} < 30 THEN '1. New (0-30 days)'
      WHEN ${customer_tenure_days} < 90 THEN '2. Growing (30-90 days)'
      WHEN ${customer_tenure_days} < 180 THEN '3. Established (90-180 days)'
      WHEN ${customer_tenure_days} < 365 THEN '4. Loyal (180-365 days)'
      ELSE '5. VIP (365+ days)'
    END ;;
  }
  
  # MEASURES
  measure: count {
    type: count
    drill_fields: [id, email, city, state, created_date]
  }
  
  measure: average_age {
    type: average
    sql: ${age} ;;
    value_format_name: decimal_1
  }
  
  measure: count_new_users {
    type: count
    filters: [customer_tenure_days: "<30"]
  }
  
  measure: count_returning_users {
    type: count
    filters: [customer_tenure_days: ">=30"]
  }
}
