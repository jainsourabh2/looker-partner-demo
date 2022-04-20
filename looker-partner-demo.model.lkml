connection: "looker-private-demo"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }

datagroup: ecommerce_etl_demo {
  sql_trigger: SELECT max(created_at) FROM looker-private-demo.ecomm.order_items ;;
  max_cache_age: "24 hours"
}

persist_with: ecommerce_etl_demo

access_grant: can_view_orders_explore {
  user_attribute: country
  allowed_values: ["USA"]
}

explore: order_items {

  label: "Total Orders Analysis with Users"
  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  join: inventory_items {
    view_label: "Inventory Items"
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: order_facts {
    type: left_outer
    view_label: "Orders"
    relationship: many_to_one
    sql_on: ${order_facts.order_id} = ${order_items.order_id} ;;
  }

  join: user_order_facts {
    view_label: "Users Facts"
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${order_items.user_id} ;;
  }

}
