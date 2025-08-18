view: users {
  sql_table_name: looker-private-demo.ecomm.users ;;
  view_label: "Users"
  ## Demographics ##

  dimension: id {
    label: "ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    tags: ["user_id"]
  }

  dimension: first_name {
    label: "First Name"
    hidden: yes
    sql: CONCAT(UPPER(SUBSTR(${TABLE}.first_name,1,1)), LOWER(SUBSTR(${TABLE}.first_name,2))) ;;

  }

  dimension: last_name {
    label: "Last Name"
    hidden: yes
    sql: CONCAT(UPPER(SUBSTR(${TABLE}.last_name,1,1)), LOWER(SUBSTR(${TABLE}.last_name,2))) ;;
  }

  dimension: name {
    label: "Name"
    sql: concat(${first_name}, ' ', ${last_name}) ;;
  }

  dimension: age {
    label: "Age"
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: over_21 {
    label: "Over 21"
    type: yesno
    sql:  ${age} > 21;;
  }

  dimension: age_tier {
    label: "Age Tier"
    type: tier
    tiers: [0, 10, 20, 30, 40, 50, 60, 70]
    style: integer
    sql: ${age} ;;
  }

  dimension: gender {
    label: "Gender"
    sql: ${TABLE}.gender ;;
  }

  dimension: gender_short {
    label: "Gender Short"
    sql: LOWER(SUBSTR(${gender},1,1)) ;;
  }

  dimension: user_image {
    label: "User Image"
    sql: ${image_file} ;;
    html: <img src="{{ value }}" width="220" height="220"/>;;
  }

  dimension: email {
    label: "Email"
    sql: ${TABLE}.email ;;
    tags: ["email"]

    link: {
      label: "User Lookup Dashboard"
      url: "/dashboards-next/ayalascustomerlookupdb?Email={{ value | encode_uri }}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
    action: {
      label: "Email Promotion to Customer"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "Thank you {{ users.name._value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "Dear {{ users.first_name._value }},

        Thanks for your loyalty to the Look.  We'd like to offer you a 10% discount
        on your next purchase!  Just use the code LOYAL when checking out!

        Your friends at the Look"
      }
    }
    required_fields: [name, first_name]
  }

  dimension: image_file {
    label: "Image File"
    hidden: yes
    sql: concat('https://docs.looker.com/assets/images/',${gender_short},'.jpg') ;;
  }

  ## Demographics ##

  dimension: city {
    label: "City"
    sql: ${TABLE}.city ;;
    drill_fields: [zip]
  }

  dimension: state {
    label: "State"
    sql: ${TABLE}.state ;;
    map_layer_name: us_states
    drill_fields: [zip, city]
    hidden: yes
  }

  dimension: zip {
    label: "Zip"
    type: zipcode
    sql: ${TABLE}.zip ;;
    drill_fields: [name]
  }

  dimension: uk_postcode {
    label: "UK Postcode"
    sql: case when ${TABLE}.country = 'UK' then regexp_replace(${zip}, '[0-9]', '') else null end;;
    map_layer_name: uk_postcode_areas
    drill_fields: [city, zip]
  }

  dimension: country {
    label: "Country"
    map_layer_name: countries
    drill_fields: [state, city]
    sql: CASE WHEN ${TABLE}.country = 'UK' THEN 'United Kingdom'
           ELSE ${TABLE}.country
           END
       ;;
    hidden: yes
  }

  dimension: location {
    label: "Location"
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: approx_latitude {
    label: "Approx Latitude"
    type: number
    sql: round(${TABLE}.latitude,1) ;;
  }

  dimension: approx_longitude {
    label: "Approx Longitude"
    type: number
    sql:round(${TABLE}.longitude,1) ;;
  }

  dimension: approx_location {
    label: "Approx Location"
    type: location
    drill_fields: [location]
    sql_latitude: ${approx_latitude} ;;
    sql_longitude: ${approx_longitude} ;;
    link: {
      label: "Google Directions from {{ distribution_centers.name._value }}"
      url: "{% if distribution_centers.location._in_query %}https://www.google.com/maps/dir/'{{ distribution_centers.latitude._value }},{{ distribution_centers.longitude._value }}'/'{{ approx_latitude._value }},{{ approx_longitude._value }}'{% endif %}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.google.com"
    }

  }

  ## Other User Information ##

  dimension_group: created {
    label: "Created"
    type: time
#     timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.created_at ;;
  }

  dimension: history {
    label: "History"
    sql: ${TABLE}.id ;;
    html: <a href="/explore/thelook_event/order_items?fields=order_items.detail*&f[users.id]={{ value }}">Order History</a>
      ;;
  }

  dimension: traffic_source {
    label: "Traffic Source"
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: ssn {
    label: "SSN"
    # dummy field used in next dim, generate 4 random numbers to be the last 4 digits
    hidden: yes
    type: string
    sql: CONCAT(CAST(FLOOR(10*RAND()) AS INT64),CAST(FLOOR(10*RAND()) AS INT64),
                CAST(FLOOR(10*RAND()) AS INT64),CAST(FLOOR(10*RAND()) AS INT64));;
  }

  dimension: ssn_last_4 {
    label: "SSN Last 4"
    description: "Only users with sufficient permissions will see this data"
    type: string
    sql: ${ssn} ;;
# FIX - Need to add user attribute
#    sql: CASE WHEN '{{_user_attributes["can_see_sensitive_data"]}}' = 'Yes'
#                THEN ${ssn}
#                ELSE '####' END;;
  }

  ## MEASURES ##

  measure: count {
    label: "Count"
    type: count
    drill_fields: [detail*]
  }

  measure: count_percent_of_total {
    label: "Count (Percent of Total)"
    type: percent_of_total
    sql: ${count} ;;
    drill_fields: [detail*]
  }

  measure: average_age {
    label: "Average Age"
    type: average
    value_format_name: decimal_2
    sql: ${age} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [id, name, email, age, created_date, orders.count, order_items.count]
  }

# === INDONESIAN CUSTOMER TRANSFORMATIONS ===

  dimension: jakarta_district {
    label: "Jakarta District"
    description: "Jakarta administrative districts"
    type: string
    case: {
      when: {
        sql: ${city} = 'Los Angeles' ;;
        label: "Central Jakarta"
      }
      when: {
        sql: ${city} = 'Chicago' ;;
        label: "South Jakarta"
      }
      when: {
        sql: ${city} = 'New York' ;;
        label: "West Jakarta"
      }
      when: {
        sql: ${city} = 'Houston' ;;
        label: "East Jakarta"
      }
      when: {
        sql: ${city} = 'San Francisco' ;;
        label: "North Jakarta"
      }
      when: {
        sql: ${city} = 'Memphis' ;;
        label: "Tangerang"
      }
      when: {
        sql: ${city} = 'Charleston' ;;
        label: "Bekasi"
      }
      else: "Greater Jakarta Area"
    }
  }

  dimension: customer_segment_jakarta {
    label: "Jakarta Customer Segment"
    description: "Customer segments specific to Jakarta book market"
    type: string
    case: {
      when: {
        sql: ${age} BETWEEN 18 AND 25 AND ${gender} = 'F' ;;
        label: "Young Female Professionals"
      }
      when: {
        sql: ${age} BETWEEN 25 AND 40 AND ${jakarta_district} LIKE '%Jakarta%' ;;
        label: "Jakarta Families"
      }
      when: {
        sql: ${age} BETWEEN 18 AND 30 AND ${traffic_source} = 'Search' ;;
        label: "Digital Native Students"
      }
      when: {
        sql: ${age} > 40 AND ${gender} = 'M' ;;
        label: "Established Male Professionals"
      }
      when: {
        sql: ${age} > 40 AND ${gender} = 'F' ;;
        label: "Established Female Professionals"
      }
      when: {
        sql: ${age} BETWEEN 13 AND 17 ;;
        label: "Teen Readers"
      }
      else: "Other Segments"
    }
  }

  dimension: traffic_source_indonesia {
    label: "Customer Acquisition Channel"
    description: "How customers found out about BBW Jakarta events"
    type: string
    case: {
      when: {
        sql: ${traffic_source} = 'Facebook' ;;
        label: "Instagram/Facebook"
      }
      when: {
        sql: ${traffic_source} = 'Search' ;;
        label: "Google Search"
      }
      when: {
        sql: ${traffic_source} = 'Email' ;;
        label: "WhatsApp/Email"
      }
      when: {
        sql: ${traffic_source} = 'Organic' ;;
        label: "Word of Mouth"
      }
      when: {
        sql: ${traffic_source} = 'Display' ;;
        label: "Online Advertising"
      }
      else: "Other Digital"
    }
  }

  dimension: reading_preference {
    label: "Reading Preference"
    description: "Inferred reading preferences based on demographics"
    type: string
    case: {
      when: {
        sql: ${customer_segment_jakarta} = 'Jakarta Families' ;;
        label: "Children's & Family Books"
      }
      when: {
        sql: ${customer_segment_jakarta} LIKE '%Professional%' ;;
        label: "Business & Self-Help"
      }
      when: {
        sql: ${customer_segment_jakarta} = 'Digital Native Students' ;;
        label: "Fiction & Young Adult"
      }
      when: {
        sql: ${customer_segment_jakarta} = 'Teen Readers' ;;
        label: "Young Adult & Fantasy"
      }
      else: "Mixed Interests"
    }
  }

  # Indonesian context for existing fields
  dimension: country_indonesia {
    label: "Country"
    type: string
    sql: 'Indonesia' ;;
  }

  dimension: state_dki {
    label: "Province"
    type: string
    sql: 'DKI Jakarta' ;;
  }

  # Hide original US-specific fields during demo
  # dimension: country {
  #   hidden: yes
  # }

  # dimension: state {
  #   hidden: yes
  # }
}
