{% macro create_raw_tables() %}
  {% set raw_db  = adapter.quote(target.database) %}
  {% set raw_sch = adapter.quote(target.schema) %}
  {% set full    = raw_db ~ '.' ~ raw_sch %}

  {# ── Schema (must exist before any objects can be created inside it) #}
  {% do run_query("CREATE SCHEMA IF NOT EXISTS " ~ raw_db ~ "." ~ raw_sch) %}

  {# ── File format & stage ─────────────────────────────────────────── #}
  {{ log("Setting up file format and S3 stage in " ~ full ~ "...", true) }}
  {% do run_query("CREATE FILE FORMAT IF NOT EXISTS " ~ full ~ ".csv_ff TYPE = 'csv'") %}

  {% do run_query("
    CREATE STAGE IF NOT EXISTS " ~ full ~ ".s3load
      COMMENT = 'Quickstarts S3 Stage Connection'
      url = 's3://sfquickstarts/frostbyte_tastybytes/'
      file_format = " ~ full ~ ".csv_ff
  ") %}

  {# ── country ─────────────────────────────────────────────────────── #}
  {{ log("Creating and loading raw table: country", true) }}
  {% do run_query("
    CREATE TABLE IF NOT EXISTS " ~ full ~ ".country (
      country_id       NUMBER(18,0),
      country          VARCHAR,
      iso_currency     VARCHAR(3),
      iso_country      VARCHAR(2),
      city_id          NUMBER(19,0),
      city             VARCHAR,
      city_population  VARCHAR
    )
  ") %}
  {% do run_query("COPY INTO " ~ full ~ ".country FROM @" ~ full ~ ".s3load/raw_pos/country/") %}

  {# ── franchise ────────────────────────────────────────────────────── #}
  {{ log("Creating and loading raw table: franchise", true) }}
  {% do run_query("
    CREATE TABLE IF NOT EXISTS " ~ full ~ ".franchise (
      franchise_id  NUMBER(38,0),
      first_name    VARCHAR,
      last_name     VARCHAR,
      city          VARCHAR,
      country       VARCHAR,
      e_mail        VARCHAR,
      phone_number  VARCHAR
    )
  ") %}
  {% do run_query("COPY INTO " ~ full ~ ".franchise FROM @" ~ full ~ ".s3load/raw_pos/franchise/") %}

  {# ── location ─────────────────────────────────────────────────────── #}
  {{ log("Creating and loading raw table: location", true) }}
  {% do run_query("
    CREATE TABLE IF NOT EXISTS " ~ full ~ ".location (
      location_id      NUMBER(19,0),
      placekey         VARCHAR,
      location         VARCHAR,
      city             VARCHAR,
      region           VARCHAR,
      iso_country_code VARCHAR,
      country          VARCHAR
    )
  ") %}
  {% do run_query("COPY INTO " ~ full ~ ".location FROM @" ~ full ~ ".s3load/raw_pos/location/") %}

  {# ── menu ─────────────────────────────────────────────────────────── #}
  {{ log("Creating and loading raw table: menu", true) }}
  {% do run_query("
    CREATE TABLE IF NOT EXISTS " ~ full ~ ".menu (
      menu_id                      NUMBER(19,0),
      menu_type_id                 NUMBER(38,0),
      menu_type                    VARCHAR,
      truck_brand_name             VARCHAR,
      menu_item_id                 NUMBER(38,0),
      menu_item_name               VARCHAR,
      item_category                VARCHAR,
      item_subcategory             VARCHAR,
      cost_of_goods_usd            NUMBER(38,4),
      sale_price_usd               NUMBER(38,4),
      menu_item_health_metrics_obj VARIANT
    )
  ") %}
  {% do run_query("COPY INTO " ~ full ~ ".menu FROM @" ~ full ~ ".s3load/raw_pos/menu/") %}

  {# ── truck ────────────────────────────────────────────────────────── #}
  {{ log("Creating and loading raw table: truck", true) }}
  {% do run_query("
    CREATE TABLE IF NOT EXISTS " ~ full ~ ".truck (
      truck_id           NUMBER(38,0),
      menu_type_id       NUMBER(38,0),
      primary_city       VARCHAR,
      region             VARCHAR,
      iso_region         VARCHAR,
      country            VARCHAR,
      iso_country_code   VARCHAR,
      franchise_flag     NUMBER(38,0),
      year               NUMBER(38,0),
      make               VARCHAR,
      model              VARCHAR,
      ev_flag            NUMBER(38,0),
      franchise_id       NUMBER(38,0),
      truck_opening_date DATE
    )
  ") %}
  {% do run_query("COPY INTO " ~ full ~ ".truck FROM @" ~ full ~ ".s3load/raw_pos/truck/") %}

  {# ── order_header ─────────────────────────────────────────────────── #}
  {{ log("Creating and loading raw table: order_header", true) }}
  {% do run_query("
    CREATE TABLE IF NOT EXISTS " ~ full ~ ".order_header (
      order_id               NUMBER(38,0),
      truck_id               NUMBER(38,0),
      location_id            FLOAT,
      customer_id            NUMBER(38,0),
      discount_id            VARCHAR,
      shift_id               NUMBER(38,0),
      shift_start_time       TIME(9),
      shift_end_time         TIME(9),
      order_channel          VARCHAR,
      order_ts               TIMESTAMP_NTZ(9),
      served_ts              VARCHAR,
      order_currency         VARCHAR(3),
      order_amount           NUMBER(38,4),
      order_tax_amount       VARCHAR,
      order_discount_amount  VARCHAR,
      order_total            NUMBER(38,4)
    )
  ") %}
  {% do run_query("COPY INTO " ~ full ~ ".order_header FROM @" ~ full ~ ".s3load/raw_pos/order_header/") %}

  {# ── order_detail ─────────────────────────────────────────────────── #}
  {{ log("Creating and loading raw table: order_detail", true) }}
  {% do run_query("
    CREATE TABLE IF NOT EXISTS " ~ full ~ ".order_detail (
      order_detail_id            NUMBER(38,0),
      order_id                   NUMBER(38,0),
      menu_item_id               NUMBER(38,0),
      discount_id                VARCHAR,
      line_number                NUMBER(38,0),
      quantity                   NUMBER(5,0),
      unit_price                 NUMBER(38,4),
      price                      NUMBER(38,4),
      order_item_discount_amount VARCHAR
    )
  ") %}
  {% do run_query("COPY INTO " ~ full ~ ".order_detail FROM @" ~ full ~ ".s3load/raw_pos/order_detail/") %}

  {# ── customer_loyalty ─────────────────────────────────────────────── #}
  {{ log("Creating and loading raw table: customer_loyalty", true) }}
  {% do run_query("
    CREATE TABLE IF NOT EXISTS " ~ full ~ ".customer_loyalty (
      customer_id        NUMBER(38,0),
      first_name         VARCHAR,
      last_name          VARCHAR,
      city               VARCHAR,
      country            VARCHAR,
      postal_code        VARCHAR,
      preferred_language VARCHAR,
      gender             VARCHAR,
      favourite_brand    VARCHAR,
      marital_status     VARCHAR,
      children_count     VARCHAR,
      sign_up_date       DATE,
      birthday_date      DATE,
      e_mail             VARCHAR,
      phone_number       VARCHAR
    )
  ") %}
  {% do run_query("COPY INTO " ~ full ~ ".customer_loyalty FROM @" ~ full ~ ".s3load/raw_customer/customer_loyalty/") %}

{% endmacro %}
