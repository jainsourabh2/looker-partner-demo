view: order_items {
  sql_table_name: `looker-private-demo.ecomm.order_items`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: days_to_return {
    type: number
    sql: DATE_DIFF(${delivered_date},${returned_date},DAY);;
    description: "Number of days before a customer returned their product"
  }
  dimension: is_wardrobing_risk{
    description: "Wardrobing: Someone that is purchasing a product, wearing it and then returning.
    This is defined by people returning between 9 and 14 days and have more than 1 order"
    type: yesno
    sql: ${days_to_return}>=9 and ${days_to_return} < 14 ;;
  }

  measure: wardrobing_order_count {
    group_label: "Wardrobing Metrics"
    type: count
    filters: [is_wardrobing_risk: "Yes"]
  }

  measure: wardrobing_rate {
    group_label: "Wardrobing Metrics"
    type: number
    value_format_name: percent_2
    sql: 1.0*${wardrobing_order_count}/NULLIF(${count},0) ;;
  }

  measure: at_risk_revenue {
    group_label: "Wardrobing Metrics"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    filters: [is_wardrobing_risk: "Yes"]
  }


  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
