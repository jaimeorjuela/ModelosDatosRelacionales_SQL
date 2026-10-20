-- =====================================================================
-- Script DDL - Oracle 19c  (version 2, complementada con la documentacion de Kaggle)
-- Tabla destino para el archivo credit_card_fraud_detection_2026-1.csv
--
-- Fuente: Kaggle - "Credit Card Fraud Detection Dataset 2026"
--         (Mohan Krishna Thalla), dataset sintetico, licencia CC0
--   * 100.000 transacciones, 43 columnas (40 variables + 3 variables objetivo)
--   * Rango de fechas: 2026-01-01 a 2026-12-31
--   * Tasa de fraude aproximada: 2,06 %
--   * Variables objetivo:
--       is_fraud           -> clasificacion binaria (0/1)
--       fraud_type         -> multiclase: Legitimate, Card-Not-Present,
--                             Card-Present, Account-Takeover, Synthetic-Identity
--       fraud_amount_lost  -> regresion, USD perdidos (0 si es legitima)
--   * Rangos documentados: credit_limit 500 a 36.670 (prom. ~10.083);
--                          credit_score 328 a 850 (prom. ~682)
--   * card_id: una tarjeta por cliente (permite agregacion por tarjeta)
-- =====================================================================

-- Eliminar la tabla si ya existe (util para re-ejecutar en clase)
CREATE TABLE credit_card_fraud (
    -- ---------- Identificadores ----------
    transaction_id              VARCHAR2(20)   NOT NULL,
    customer_id                 VARCHAR2(20)   NOT NULL,
    card_id                     VARCHAR2(20)   NOT NULL,
    merchant_id                 VARCHAR2(20)   NOT NULL,
    -- ---------- Detalle de la transaccion (6 variables + fecha) ----------
    transaction_datetime        DATE           NOT NULL,   -- origen: YYYY-MM-DD HH24:MI:SS
    transaction_amount          NUMBER(12,2),
    merchant_category           VARCHAR2(50),
    merchant_country            VARCHAR2(30),
    transaction_hour            NUMBER(2),
    transaction_day_of_week     VARCHAR2(10),
    card_present                NUMBER(1),
    -- ---------- Perfil del cliente (7 variables) ----------
    customer_age                NUMBER(3),
    customer_gender             VARCHAR2(10),
    customer_state              VARCHAR2(5),
    account_age_days            NUMBER(6),
    credit_limit                NUMBER(12,2),
    credit_score                NUMBER(3),
    num_cards_held              NUMBER(2),
    -- ---------- Velocidad / comportamiento reciente ----------
    transactions_last_1h        NUMBER(5),
    transactions_last_24h       NUMBER(5),
    transactions_last_7d        NUMBER(6),
    amount_last_1h              NUMBER(14,2),
    amount_last_24h             NUMBER(14,2),
    days_since_last_transaction NUMBER(10,2),
    -- ---------- Geografia y riesgo ----------
    distance_from_home_km       NUMBER(12,2),
    distance_from_last_tx_km    NUMBER(12,2),
    international_transaction   NUMBER(1),
    high_risk_country           NUMBER(1),
    amount_vs_avg_ratio         NUMBER(12,3),
    used_chip                   NUMBER(1),
    used_pin                    NUMBER(1),
    -- ---------- Canal y dispositivo ----------
    transaction_channel         VARCHAR2(20),
    device_type                 VARCHAR2(20),
    browser                     VARCHAR2(20),              -- incluye el valor 'N/A'
    is_weekend                  NUMBER(1),
    -- ---------- Historico 30 dias / cuenta ----------
    avg_transaction_amount_30d  NUMBER(14,2),
    std_transaction_amount_30d  NUMBER(14,2),
    num_declined_last_30d       NUMBER(4),
    num_chargebacks_ever        NUMBER(4),
    email_domain                VARCHAR2(30),
    -- ---------- Variables objetivo (3) ----------
    is_fraud                    NUMBER(1),
    fraud_type                  VARCHAR2(30),
    fraud_amount_lost           NUMBER(14,2)
    -- ---------- Restricciones ----------
    );
-- Indices de apoyo para consultas de analisis (opcionales)
-- ---------------------------------------------------------------------
CREATE INDEX ix_ccf_customer ON credit_card_fraud (customer_id);
CREATE INDEX ix_ccf_datetime ON credit_card_fraud (transaction_datetime);
CREATE INDEX ix_ccf_is_fraud ON credit_card_fraud (is_fraud);
CREATE INDEX ix_ccf_fraud_type ON credit_card_fraud (fraud_type);
