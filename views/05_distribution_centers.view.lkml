view: distribution_centers {
  view_label: "Distribution Centers"
  sql_table_name: bigquery-public-data.thelook_ecommerce.distribution_centers ;;
  dimension: location {
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
    hidden: yes
  }

  dimension: latitude {
    label: "Latitude"
    sql: ${TABLE}.latitude ;;
    hidden: yes
  }

  dimension: longitude {
    label: "Longitude"
    sql: ${TABLE}.longitude ;;
    hidden: yes
  }

  dimension: id {
    label: "ID"
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    label: "Name"
    sql: ${TABLE}.name ;;
    hidden: yes
  }

  # Hide original US location fields during demo
  # dimension: name {
  #   hidden: yes
  # }

  # dimension: location {
  #   hidden: yes
  # }
}
