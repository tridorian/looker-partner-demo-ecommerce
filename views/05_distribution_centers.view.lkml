view: distribution_centers {
  view_label: "Distribution Centers"
  sql_table_name: looker-private-demo.ecomm.distribution_centers ;;
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

# === JAKARTA MALL TRANSFORMATIONS ===

  dimension: jakarta_mall {
    label: "Jakarta Mall Location"
    description: "Jakarta mall locations for BBW book fair events"
    type: string
    case: {
      when: {
        sql: ${name} = 'Los Angeles CA' ;; # 36,820 orders - Premium mall
        label: "Grand Indonesia Shopping Town"
      }
      when: {
        sql: ${name} = 'Chicago IL' ;; # 28,636 orders - High-traffic mall
        label: "Plaza Senayan"
      }
      when: {
        sql: ${name} = 'Houston TX' ;; # 25,809 orders - Family mall
        label: "Central Park Jakarta"
      }
      when: {
        sql: ${name} = 'Memphis TN' ;; # 24,347 orders - Mid-tier suburban
        label: "Mall @ Alam Sutera"
      }
      when: {
        sql: ${name} = 'Port Authority of New York/New Jersey NY/NJ' ;; # 21,649 orders
        label: "Summarecon Mall Serpong"
      }
      when: {
        sql: ${name} = 'Philadelphia PA' ;; # 20,896 orders
        label: "Gandaria City"
      }
      when: {
        sql: ${name} = 'Charleston SC' ;; # 19,342 orders
        label: "Pacific Place Jakarta"
      }
      when: {
        sql: ${name} = 'New Orleans LA' ;; # 15,441 orders
        label: "Senayan City"
      }
      when: {
        sql: ${name} = 'Mobile AL' ;; # 9,640 orders
        label: "Kota Kasablanka"
      }
      when: {
        sql: ${name} = 'Savannah GA' ;; # 9,201 orders
        label: "Mall Taman Anggrek"
      }
      else: "Other Jakarta Location"
    }
  }

  dimension: mall_tier {
    label: "Mall Tier"
    description: "Jakarta mall classification by target market and volume"
    type: string
    case: {
      when: {
        sql: ${jakarta_mall} IN ('Grand Indonesia Shopping Town', 'Plaza Senayan') ;; # 36K+ and 28K+ orders
        label: "Premium Mall (Tier 1)"
      }
      when: {
        sql: ${jakarta_mall} IN ('Central Park Jakarta', 'Mall @ Alam Sutera', 'Summarecon Mall Serpong') ;; # 20K-26K orders
        label: "High-Traffic Mall (Tier 2)"
      }
      when: {
        sql: ${jakarta_mall} IN ('Gandaria City', 'Pacific Place Jakarta', 'Senayan City') ;; # 15K-21K orders
        label: "Mid-Tier Mall (Tier 3)"
      }
      else: "Community Mall (Tier 4)" # Under 10K orders
    }
  }

  dimension: transportation_access {
    label: "Transportation Access"
    description: "Public transportation availability"
    type: string
    case: {
      when: {
        sql: ${jakarta_mall} = 'Grand Indonesia Shopping Town' ;;
        label: "MRT + TransJakarta + Taxi + Gojek"
      }
      when: {
        sql: ${jakarta_mall} = 'Plaza Senayan' ;;
        label: "MRT + TransJakarta + Taxi"
      }
      when: {
        sql: ${jakarta_mall} = 'Central Park Jakarta' ;;
        label: "TransJakarta + Bus + Gojek"
      }
      when: {
        sql: ${jakarta_mall} = 'Mall @ Alam Sutera' ;;
        label: "Car + Taxi + Gojek"
      }
      when: {
        sql: ${jakarta_mall} = 'Summarecon Mall Serpong' ;;
        label: "Car + Commuter Train + Gojek"
      }
      else: "Limited Public Transport"
    }
  }

  dimension: target_demographic {
    label: "Primary Demographic"
    type: string
    case: {
      when: {
        sql: ${jakarta_mall} = 'Grand Indonesia Shopping Town' ;; # Highest volume - business district
        label: "Business Professionals & Tourists"
      }
      when: {
        sql: ${jakarta_mall} = 'Plaza Senayan' ;; # Second highest - affluent area
        label: "Affluent Families & Professionals"
      }
      when: {
        sql: ${jakarta_mall} = 'Central Park Jakarta' ;; # Third highest - mixed
        label: "Young Professionals & Families"
      }
      when: {
        sql: ${jakarta_mall} = 'Mall @ Alam Sutera' ;; # Suburban families
        label: "Suburban Families with Children"
      }
      when: {
        sql: ${jakarta_mall} = 'Summarecon Mall Serpong' ;; # Bedroom community
        label: "Commuter Families & Students"
      }
      else: "Mixed Demographics"
    }
  }

  # measure: total_mall_orders {
  #   label: "Total Mall Orders"
  #   description: "Historical order volume by mall location"
  #   type: count_distinct
  #   sql: ${order_items.order_id} ;;
  # }

  # Performance ranking dimension
  dimension: mall_performance_rank {
    label: "Mall Performance Rank"
    type: number
    case: {
      when: {
        sql: ${jakarta_mall} = 'Grand Indonesia Shopping Town' ;;
        label: "1"
      }
      when: {
        sql: ${jakarta_mall} = 'Plaza Senayan' ;;
        label: "2"
      }
      when: {
        sql: ${jakarta_mall} = 'Central Park Jakarta' ;;
        label: "3"
      }
      when: {
        sql: ${jakarta_mall} = 'Mall @ Alam Sutera' ;;
        label: "4"
      }
      when: {
        sql: ${jakarta_mall} = 'Summarecon Mall Serpong' ;;
        label: "5"
      }
      else: "6"
    }
  }

  # Hide original US location fields during demo
  # dimension: name {
  #   hidden: yes
  # }

  # dimension: location {
  #   hidden: yes
  # }
}
