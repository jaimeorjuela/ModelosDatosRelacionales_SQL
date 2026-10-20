-- =====================================================================
-- Archivo de control SQL*Loader - Oracle 19c
-- Carga: credit_card_fraud_detection_2026-1.csv  -->  CREDIT_CARD_FRAUD
--
-- Ejecucion (desde la carpeta donde estan el .ctl y el .csv):
--
--   sqlldr userid=usuario/clave@//host:1521/servicio ^
--          control=02_load_credit_card_fraud.ctl ^
--          log=credit_card_fraud.log ^
--          bad=credit_card_fraud.bad ^
--          discard=credit_card_fraud.dsc
--
-- (en Linux/macOS use \ en lugar de ^ para continuar la linea)
-- =====================================================================
OPTIONS (SKIP=1, ERRORS=100, ROWS=5000)   -- SKIP=1 omite la fila de encabezados
LOAD DATA
CHARACTERSET UTF8
INFILE 'credit_card_fraud_detection_2026.csv'
BADFILE 'credit_card_fraud.bad'
DISCARDFILE 'credit_card_fraud.dsc'
APPEND                                     -- use TRUNCATE para vaciar la tabla antes de cargar
INTO TABLE credit_card_fraud
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    transaction_id,
    customer_id,
    card_id,
    merchant_id,
    transaction_datetime          DATE "YYYY-MM-DD HH24:MI:SS",
    transaction_amount,
    merchant_category,
    merchant_country,
    transaction_hour,
    transaction_day_of_week,
    card_present,
    customer_age,
    customer_gender,
    customer_state,
    account_age_days,
    credit_limit,
    credit_score,
    num_cards_held,
    transactions_last_1h,
    transactions_last_24h,
    transactions_last_7d,
    amount_last_1h,
    amount_last_24h,
    days_since_last_transaction,
    distance_from_home_km,
    distance_from_last_tx_km,
    international_transaction,
    high_risk_country,
    amount_vs_avg_ratio,
    used_chip,
    used_pin,
    transaction_channel,
    device_type,
    browser,
    is_weekend,
    avg_transaction_amount_30d,
    std_transaction_amount_30d,
    num_declined_last_30d,
    num_chargebacks_ever,
    email_domain,
    is_fraud,
    fraud_type,
    fraud_amount_lost
)
