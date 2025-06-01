view: products {
  sql_table_name: looker-private-demo.ecomm.products ;;
  view_label: "Products"
  ### DIMENSIONS ###

  dimension: id {
    label: "ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: category {
    label: "Category"
    sql: TRIM(${TABLE}.category) ;;
    drill_fields: [item_name]
    hidden: yes
  }

  dimension: item_name {
    label: "Item Name"
    sql: TRIM(${TABLE}.name) ;;
    drill_fields: [id]
    hidden: yes
  }

  dimension: brand {
    hidden: yes
    label: "Brand"
    sql: TRIM(${TABLE}.brand) ;;
    link: {
      label: "Website"
      url: "http://www.google.com/search?q={{ value | encode_uri }}+clothes&btnI"
      icon_url: "http://www.google.com/s2/favicons?domain=www.{{ value | encode_uri }}.com"
    }
    link: {
      label: "Facebook"
      url: "http://www.google.com/search?q=site:facebook.com+{{ value | encode_uri }}+clothes&btnI"
      icon_url: "https://upload.wikimedia.org/wikipedia/commons/c/c2/F_icon.svg"
    }
    link: {
      label: "{{value}} Analytics Dashboard"
      url: "/dashboards-next/CRMxoGiGJUv4eGALMHiAb0?Brand%20Name={{ value | encode_uri }}"
      icon_url: "http://www.looker.com/favicon.ico"
    }

    action: {
      label: "Email Brand Promotion to Cohort"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "Last Chance! 20% off {{ value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "Dear Valued Customer,

        We appreciate your continue support and loyalty and wanted to show our appreciation. Offering a 15% discount on ALL products for our favorite brand {{ value }}.
        Just used code {{ value | upcase }}-MANIA on your next checkout!

        Your friends at the Look"
      }
    }
    action: {
      label: "Start Adwords Campaign"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://www.google.com/s2/favicons?domain=www.adwords.google.com"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        type: select
        name: "Campaign Type"
        option: { name: "Spend" label: "Spend" }
        option: { name: "Leads" label: "Leads" }
        option: { name: "Website Traffic" label: "Website Traffic" }
        required: yes
      }
      form_param: {
        name: "Campaign Name"
        type: string
        required: yes
        default: "{{ value }} Campaign"
      }

      form_param: {
        name: "Product Category"
        type: string
        required: yes
        default: "{{ value }}"
      }

      form_param: {
        name: "Budget"
        type: string
        required: yes
      }

      form_param: {
        name: "Keywords"
        type: string
        required: yes
        default: "{{ value }}"
      }
    }
  }

  dimension: retail_price {
    label: "Retail Price"
    type: number
    sql: ${TABLE}.retail_price ;;
    action: {
      label: "Update Price"
      url: "https://us-central1-sandbox-trials.cloudfunctions.net/ecomm_inventory_writeback"
      param: {
        name: "Price"
        value: "24"
      }
      form_param: {
        name: "Discount"
        label: "Discount Tier"
        type: select
        option: {
          name: "5% off"
        }
        option: {
          name: "10% off"
        }
        option: {
          name: "20% off"
        }
        option: {
          name: "30% off"
        }
        option: {
          name: "40% off"
        }
        option: {
          name: "50% off"
        }
        default: "20% off"
      }
      param: {
        name: "retail_price"
        value: "{{ retail_price._value }}"
      }
      param: {
        name: "inventory_item_id"
        value: "{{ inventory_items.id._value }}"
      }
      param: {
        name: "product_id"
        value: "{{ id._value }}"
      }
      param: {
        name: "security_key"
        value: "googledemo"
      }
    }
  }

  dimension: department {
    label: "Department"
    sql: TRIM(${TABLE}.department) ;;
  }

  dimension: sku {
    label: "SKU"
    sql: ${TABLE}.sku ;;
  }

  dimension: distribution_center_id {
    label: "Distribution Center ID"
    type: number
    sql: CAST(${TABLE}.distribution_center_id AS INT64) ;;
  }

  ## MEASURES ##

  measure: count {
    label: "Count"
    type: count
    drill_fields: [detail*]
  }

  measure: brand_count {
    label: "Brand Count"
    type: count_distinct
    sql: ${brand} ;;
    drill_fields: [brand, detail2*, -brand_count] # show the brand, a bunch of counts (see the set below), don't show the brand count, because it will always be 1
  }

  measure: category_count {
    label: "Category Count"
    alias: [category.count]
    type: count_distinct
    sql: ${category} ;;
    drill_fields: [category, detail2*, -category_count] # don't show because it will always be 1
  }

  measure: department_count {
    label: "Department Count"
    alias: [department.count]
    type: count_distinct
    sql: ${department} ;;
    drill_fields: [department, detail2*, -department_count] # don't show because it will always be 1
  }

  set: detail {
    fields: [id, item_name, brand, category, department, retail_price, customers.count, orders.count, order_items.count, inventory_items.count]
  }

  set: detail2 {
    fields: [category_count, brand_count, department_count, count, customers.count, orders.count, order_items.count, inventory_items.count, products.count]
  }

# === BOOK RETAIL TRANSFORMATIONS ===

  dimension: book_genre {
    label: "Book Genre"
    description: "Book categories mapped from fashion categories for BBW demo"
    type: string
    case: {
      when: {
        sql: ${category} = 'Tops & Tees' ;; # 1,588 items - largest category
        label: "Fiction & Literature"
      }
      when: {
        sql: ${category} = 'Shorts' ;; # 1,474 items
        label: "Children's Books"
      }
      when: {
        sql: ${category} = 'Sweaters' ;; # 1,435 items
        label: "Business & Economics"
      }
      when: {
        sql: ${category} = 'Fashion Hoodies & Sweatshirts' ;; # 1,402 items
        label: "Self-Help & Personal Development"
      }
      when: {
        sql: ${category} = 'Accessories' ;; # 1,331 items
        label: "Educational & Academic"
      }
      when: {
        sql: ${category} = 'Swim' ;; # 1,319 items
        label: "Young Adult & Teen"
      }
      when: {
        sql: ${category} = 'Sleep & Lounge' ;; # 1,239 items
        label: "Cooking & Food"
      }
      when: {
        sql: ${category} = 'Active' ;; # 1,168 items
        label: "Health & Fitness"
      }
      when: {
        sql: ${category} = 'Jeans' ;; # 1,069 items
        label: "History & Biography"
      }
      when: {
        sql: ${category} = 'Outerwear & Coats' ;; # 930 items
        label: "Science & Technology"
      }
      when: {
        sql: ${category} = 'Dresses' ;; # 902 items
        label: "Romance"
      }
      when: {
        sql: ${category} = 'Intimates' ;; # 854 items
        label: "Mystery & Thriller"
      }
      when: {
        sql: ${category} = 'Pants' ;; # 752 items
        label: "Art & Design"
      }
      when: {
        sql: ${category} = 'Suits & Sport Coats' ;; # 684 items
        label: "Language Learning"
      }
      when: {
        sql: ${category} = 'Underwear' ;; # 590 items
        label: "Travel & Adventure"
      }
      when: {
        sql: ${category} = 'Plus' ;; # 566 items
        label: "Religion & Spirituality"
      }
      when: {
        sql: ${category} = 'Socks' ;; # 494 items
        label: "Comics & Graphic Novels"
      }
      when: {
        sql: ${category} = 'Pants & Capris' ;; # 479 items
        label: "Psychology & Philosophy"
      }
      when: {
        sql: ${category} = 'Leggings' ;; # 475 items
        label: "Parenting & Family"
      }
      when: {
        sql: ${category} = 'Blazers & Jackets' ;; # 462 items
        label: "Reference & Dictionaries"
      }
      when: {
        sql: ${category} = 'Socks & Hosiery' ;; # 419 items
        label: "Fantasy & Sci-Fi"
      }
      when: {
        sql: ${category} = 'Maternity' ;; # 377 items
        label: "Pregnancy & Baby Care"
      }
      when: {
        sql: ${category} = 'Skirts' ;; # 356 items
        label: "Poetry & Drama"
      }
      when: {
        sql: ${category} = 'Suits' ;; # 135 items
        label: "Law & Legal Studies"
      }
      when: {
        sql: ${category} = 'Jumpsuits & Rompers' ;; # 56 items
        label: "Music & Entertainment"
      }
      when: {
        sql: ${category} = 'Clothing Sets' ;; # 22 items
        label: "Rare & Collectible Books"
      }
      else: "Other Books"
    }
  }

  dimension: book_title {
    label: "Book Title"
    description: "Realistic book titles based on existing product data"
    type: string
    case: {
      # Fiction & Literature (Tops & Tees)
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 0 ;;
        label: "The Alchemist - Paulo Coelho"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 1 ;;
        label: "To Kill a Mockingbird - Harper Lee"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 2 ;;
        label: "1984 - George Orwell"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 3 ;;
        label: "Pride and Prejudice - Jane Austen"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 4 ;;
        label: "The Great Gatsby - F. Scott Fitzgerald"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 5 ;;
        label: "One Hundred Years of Solitude"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 6 ;;
        label: "The Catcher in the Rye - J.D. Salinger"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 7 ;;
        label: "Beloved - Toni Morrison"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 8 ;;
        label: "The Lord of the Rings - J.R.R. Tolkien"
      }
      when: {
        sql: ${category} = 'Tops & Tees' AND ${id} % 10 = 9 ;;
        label: "Harry Potter Series - J.K. Rowling"
      }

      # Children's Books (Shorts)
      when: {
        sql: ${category} = 'Shorts' AND ${id} % 8 = 0 ;;
        label: "Where the Wild Things Are"
      }
      when: {
        sql: ${category} = 'Shorts' AND ${id} % 8 = 1 ;;
        label: "The Very Hungry Caterpillar"
      }
      when: {
        sql: ${category} = 'Shorts' AND ${id} % 8 = 2 ;;
        label: "Goodnight Moon"
      }
      when: {
        sql: ${category} = 'Shorts' AND ${id} % 8 = 3 ;;
        label: "Dr. Seuss Collection"
      }
      when: {
        sql: ${category} = 'Shorts' AND ${id} % 8 = 4 ;;
        label: "Winnie-the-Pooh Stories"
      }
      when: {
        sql: ${category} = 'Shorts' AND ${id} % 8 = 5 ;;
        label: "Disney Princess Collection"
      }
      when: {
        sql: ${category} = 'Shorts' AND ${id} % 8 = 6 ;;
        label: "National Geographic Kids"
      }
      when: {
        sql: ${category} = 'Shorts' AND ${id} % 8 = 7 ;;
        label: "Roald Dahl Collection"
      }

      # Business & Economics (Sweaters)
      when: {
        sql: ${category} = 'Sweaters' AND ${id} % 6 = 0 ;;
        label: "Rich Dad Poor Dad - Robert Kiyosaki"
      }
      when: {
        sql: ${category} = 'Sweaters' AND ${id} % 6 = 1 ;;
        label: "The 7 Habits of Highly Effective People"
      }
      when: {
        sql: ${category} = 'Sweaters' AND ${id} % 6 = 2 ;;
        label: "Think and Grow Rich - Napoleon Hill"
      }
      when: {
        sql: ${category} = 'Sweaters' AND ${id} % 6 = 3 ;;
        label: "The Lean Startup - Eric Ries"
      }
      when: {
        sql: ${category} = 'Sweaters' AND ${id} % 6 = 4 ;;
        label: "Good to Great - Jim Collins"
      }
      when: {
        sql: ${category} = 'Sweaters' AND ${id} % 6 = 5 ;;
        label: "The Intelligent Investor"
      }

      # Self-Help (Fashion Hoodies & Sweatshirts)
      when: {
        sql: ${category} = 'Fashion Hoodies & Sweatshirts' AND ${id} % 5 = 0 ;;
        label: "Atomic Habits - James Clear"
      }
      when: {
        sql: ${category} = 'Fashion Hoodies & Sweatshirts' AND ${id} % 5 = 1 ;;
        label: "The Power of Now - Eckhart Tolle"
      }
      when: {
        sql: ${category} = 'Fashion Hoodies & Sweatshirts' AND ${id} % 5 = 2 ;;
        label: "How to Win Friends and Influence People"
      }
      when: {
        sql: ${category} = 'Fashion Hoodies & Sweatshirts' AND ${id} % 5 = 3 ;;
        label: "The Subtle Art of Not Giving a F*ck"
      }
      when: {
        sql: ${category} = 'Fashion Hoodies & Sweatshirts' AND ${id} % 5 = 4 ;;
        label: "Mindset - Carol Dweck"
      }

      # Add quick mappings for other categories
      when: {
        sql: ${category} = 'Accessories' ;;
        label: "Educational Textbook Collection"
      }
      when: {
        sql: ${category} = 'Swim' ;;
        label: "Young Adult Novel Series"
      }
      when: {
        sql: ${category} = 'Sleep & Lounge' ;;
        label: "Cooking & Recipe Books"
      }
      when: {
        sql: ${category} = 'Active' ;;
        label: "Health & Fitness Guides"
      }
      when: {
        sql: ${category} = 'Jeans' ;;
        label: "Historical Biography"
      }
      when: {
        sql: ${category} = 'Outerwear & Coats' ;;
        label: "Science & Technology"
      }
      when: {
        sql: ${category} = 'Dresses' ;;
        label: "Romance Novel Collection"
      }
      when: {
        sql: ${category} = 'Intimates' ;;
        label: "Mystery & Thriller Series"
      }
      when: {
        sql: ${category} = 'Pants' ;;
        label: "Art & Design Books"
      }
      when: {
        sql: ${category} = 'Suits & Sport Coats' ;;
        label: "Language Learning Guides"
      }
      when: {
        sql: ${category} = 'Underwear' ;;
        label: "Travel & Adventure Stories"
      }
      else: "Book Collection"
    }
  }

  dimension: book_publisher {
    label: "Publisher"
    description: "Book publishers mapped from brand data with realistic volumes"
    type: string
    case: {
      # Major international publishers (high volume)
      when: {
        sql: ${brand} = 'Levi\'s' ;; # 23,876 items - largest brand
        label: "Penguin Random House"
      }
      when: {
        sql: ${brand} = 'Allegra K' ;; # 10,000 items
        label: "HarperCollins Publishers"
      }
      when: {
        sql: ${brand} = 'Columbia' ;; # 9,767 items
        label: "Gramedia Pustaka Utama"
      }
      when: {
        sql: ${brand} = 'Dockers' ;; # 9,584 items
        label: "Scholastic Corporation"
      }
      when: {
        sql: ${brand} = 'Ray-Ban' ;; # 8,676 items
        label: "Oxford University Press"
      }
      when: {
        sql: ${brand} = 'Carhartt' ;; # 8,378 items
        label: "Mizan Pustaka"
      }
      when: {
        sql: ${brand} = 'Champion' ;; # 7,127 items
        label: "National Geographic Books"
      }
      when: {
        sql: ${brand} = 'Hanes' ;; # 4,932 items
        label: "Cambridge University Press"
      }

      # Mid-tier publishers (medium volume)
      when: {
        sql: ${brand} = 'Lee' ;; # 3,934 items
        label: "DK Publishing"
      }
      when: {
        sql: ${brand} = 'TrendsBlue' ;; # 3,859 items
        label: "Macmillan Publishers"
      }
      when: {
        sql: ${brand} = 'Russell Athletic' ;; # 2,761 items
        label: "Pearson Education"
      }
      when: {
        sql: ${brand} = 'Patty' ;; # 2,612 items
        label: "Simon & Schuster"
      }
      when: {
        sql: ${brand} = 'Calvin Klein' ;; # 2,600 items
        label: "Wiley Publishing"
      }
      when: {
        sql: ${brand} = 'Dickies' ;; # 2,519 items
        label: "McGraw-Hill Education"
      }
      when: {
        sql: ${brand} = 'Speedo' ;; # 2,302 items
        label: "Bloomsbury Publishing"
      }
      when: {
        sql: ${brand} = 'Duofold' ;; # 2,227 items
        label: "Hachette Book Group"
      }

      # Indonesian local publishers (medium volume)
      when: {
        sql: ${brand} = 'U.S. Polo Assn.' ;; # 2,066 items
        label: "Penerbit Erlangga"
      }
      when: {
        sql: ${brand} = 'FineBrandShop' ;; # 2,035 items
        label: "Bentang Pustaka"
      }
      when: {
        sql: ${brand} = 'Haggar' ;; # 1,708 items
        label: "Republika Penerbit"
      }
      when: {
        sql: ${brand} = 'Alki\'i' ;; # 1,699 items
        label: "Penerbit Andi"
      }
      when: {
        sql: ${brand} = 'Scarfand' ;; # 1,557 items
        label: "Tiga Serangkai"
      }
      when: {
        sql: ${brand} = 'Gold Toe' ;; # 1,339 items
        label: "Penerbit Qanita"
      }
      when: {
        sql: ${brand} = 'Burnside' ;; # 1,320 items
        label: "Noura Books"
      }
      when: {
        sql: ${brand} = 'Fruit of the Loom' ;; # 1,300 items
        label: "Penerbit Ufuk"
      }

      # Specialty publishers (lower volume but important niches)
      when: {
        sql: ${brand} = 'Hurley' ;; # 1,183 items
        label: "Lonely Planet"
      }
      when: {
        sql: ${brand} = 'adidas' ;; # 1,175 items
        label: "Manning Publications"
      }
      when: {
        sql: ${brand} = 'Tommy Hilfiger' ;; # 1,119 items
        label: "O'Reilly Media"
      }
      when: {
        sql: ${brand} = 'Port Authority' ;; # 1,072 items
        label: "Vintage Books"
      }
      when: {
        sql: ${brand} = 'Next Level' ;; # 1,067 items
        label: "Anchor Books"
      }
      when: {
        sql: ${brand} = 'Injinji' ;; # 1,049 items
        label: "Addison-Wesley"
      }
      when: {
        sql: ${brand} = 'American Apparel' ;; # 1,003 items
        label: "Prentice Hall"
      }
      when: {
        sql: ${brand} = 'Nautica' ;; # 986 items
        label: "Thames & Hudson"
      }
      when: {
        sql: ${brand} = 'VIP BOUTIQUE' ;; # 975 items
        label: "Chronicle Books"
      }
      when: {
        sql: ${brand} = 'Volcom' ;; # 943 items
        label: "Workman Publishing"
      }

      # Small but specialized publishers
      when: {
        sql: ${brand} = 'Nike' ;; # 376 items - surprisingly small in this dataset
        label: "Taschen"
      }
      when: {
        sql: ${brand} = 'Under Armour' ;; # 476 items
        label: "MIT Press"
      }
      when: {
        sql: ${brand} = 'PUMA' ;; # 97 items
        label: "Phaidon Press"
      }

      # Default for unmapped brands
      else: "Independent Publisher"
    }
  }

  dimension: book_language {
    label: "Book Language"
    type: string
    case: {
      when: {
        sql: ${book_publisher} IN ('Gramedia Pustaka', 'Mizan Pustaka', 'Local Indonesian Publisher') ;;
        label: "Bahasa Indonesia"
      }
      when: {
        sql: ${book_genre} = 'Language Learning' ;;
        label: "Multi-language"
      }
      else: "English"
    }
  }

  dimension: book_format {
    label: "Book Format"
    type: string
    case: {
      when: {
        sql: ${book_genre} = "Children's Books" ;;
        label: "Illustrated Hardcover"
      }
      when: {
        sql: ${book_genre} IN ('Reference & Dictionaries', 'Educational & Academic') ;;
        label: "Hardcover"
      }
      when: {
        sql: ${book_genre} = 'Comics & Graphic Novels' ;;
        label: "Graphic Novel"
      }
      else: "Paperback"
    }
  }

  dimension: book_price_tier_idr {
    label: "Book Price Tier (IDR)"
    type: tier
    sql: ${retail_price} * 15000 ;; # Convert USD to IDR for demo
    tiers: [50000, 100000, 200000, 350000, 500000]
    style: integer
    value_format: "\"Rp \"#,##0"
  }

  # Hide original fashion-related dimensions during demo
  # dimension: category {
  #   hidden: yes
  # }

  # dimension: brand {
  #   hidden: yes
  # }

  # dimension: item_name {
  #   hidden: yes
  #   }

  dimension: book_type {
    label: "Book Format"
    type: string
    case: {
      when: {
        sql: ${item_name} LIKE '%Hardcover%' ;;
        label: "Hardcover"
      }
      when: {
        sql: ${item_name} LIKE '%Paperback%' ;;
        label: "Paperback"
      }
      when: {
        sql: ${item_name} LIKE '%Children%' ;;
        label: "Children's Illustrated"
      }
      else: "Paperback"
    }
  }

# Book-specific pricing tiers
  dimension: price_tier_books {
    label: "Book Price Tier (IDR)"
    type: tier
    sql: ${retail_price} * 15000 ;; # Convert to IDR
    tiers: [50000, 100000, 200000, 350000, 500000]
    style: integer
  }
}
