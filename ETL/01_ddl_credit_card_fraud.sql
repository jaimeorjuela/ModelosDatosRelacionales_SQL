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
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE credit_card_fraud PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN   -- ORA-00942: la tabla no existe
            RAISE;
        END IF;
END;
/

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
    fraud_amount_lost           NUMBER(14,2),

    -- ---------- Restricciones ----------
    CONSTRAINT pk_credit_card_fraud PRIMARY KEY (transaction_id),

    -- indicadores binarios 0/1
    CONSTRAINT ck_ccf_card_present  CHECK (card_present IN (0,1)),
    CONSTRAINT ck_ccf_intl          CHECK (international_transaction IN (0,1)),
    CONSTRAINT ck_ccf_high_risk     CHECK (high_risk_country IN (0,1)),
    CONSTRAINT ck_ccf_chip          CHECK (used_chip IN (0,1)),
    CONSTRAINT ck_ccf_pin           CHECK (used_pin IN (0,1)),
    CONSTRAINT ck_ccf_weekend       CHECK (is_weekend IN (0,1)),
    CONSTRAINT ck_ccf_is_fraud      CHECK (is_fraud IN (0,1)),

    -- dominios / rangos
    CONSTRAINT ck_ccf_hour          CHECK (transaction_hour BETWEEN 0 AND 23),
    CONSTRAINT ck_ccf_dow           CHECK (transaction_day_of_week IN
                                      ('Monday','Tuesday','Wednesday','Thursday',
                                       'Friday','Saturday','Sunday')),
    CONSTRAINT ck_ccf_score         CHECK (credit_score BETWEEN 300 AND 850),
    CONSTRAINT ck_ccf_amount        CHECK (transaction_amount >= 0),
    CONSTRAINT ck_ccf_limit         CHECK (credit_limit >= 0),
    CONSTRAINT ck_ccf_fraud_type    CHECK (fraud_type IN
                                      ('Legitimate','Card-Not-Present','Card-Present',
                                       'Account-Takeover','Synthetic-Identity'))
);

-- ---------------------------------------------------------------------
-- Comentarios de documentacion (tabla y columnas)
-- ---------------------------------------------------------------------
COMMENT ON TABLE  credit_card_fraud IS 'Transacciones de tarjeta de credito (sinteticas, 100K filas, 2026) para deteccion de fraude. Fuente: Kaggle, Mohan Krishna Thalla, CC0';

COMMENT ON COLUMN credit_card_fraud.transaction_id              IS 'Identificador unico de la transaccion (PK), formato TXN-00000001';
COMMENT ON COLUMN credit_card_fraud.customer_id                 IS 'Identificador del cliente, formato CUS-00000000';
COMMENT ON COLUMN credit_card_fraud.card_id                     IS 'Tarjeta usada; una tarjeta por cliente en este dataset';
COMMENT ON COLUMN credit_card_fraud.merchant_id                 IS 'Identificador del comercio, formato MER-00000000';
COMMENT ON COLUMN credit_card_fraud.transaction_datetime        IS 'Fecha y hora de la transaccion';
COMMENT ON COLUMN credit_card_fraud.transaction_amount          IS 'Monto de la transaccion en USD';
COMMENT ON COLUMN credit_card_fraud.merchant_category           IS 'Categoria del comercio (p. ej. Online Retail, Gas Station)';
COMMENT ON COLUMN credit_card_fraud.merchant_country            IS 'Pais del comercio';
COMMENT ON COLUMN credit_card_fraud.transaction_hour            IS 'Hora de la transaccion (0-23)';
COMMENT ON COLUMN credit_card_fraud.transaction_day_of_week     IS 'Dia de la semana (en ingles)';
COMMENT ON COLUMN credit_card_fraud.card_present                IS '1 = tarjeta presente, 0 = tarjeta no presente';
COMMENT ON COLUMN credit_card_fraud.customer_age                IS 'Edad del cliente';
COMMENT ON COLUMN credit_card_fraud.customer_gender             IS 'Genero del cliente';
COMMENT ON COLUMN credit_card_fraud.customer_state              IS 'Estado de residencia del cliente (codigo de 2 letras)';
COMMENT ON COLUMN credit_card_fraud.account_age_days            IS 'Antiguedad de la cuenta en dias';
COMMENT ON COLUMN credit_card_fraud.credit_limit                IS 'Limite de credito en USD (rango documentado 500 a 36.670)';
COMMENT ON COLUMN credit_card_fraud.credit_score                IS 'Puntaje crediticio (rango documentado 328 a 850)';
COMMENT ON COLUMN credit_card_fraud.num_cards_held              IS 'Numero de tarjetas que posee el cliente';
COMMENT ON COLUMN credit_card_fraud.transactions_last_1h        IS 'Numero de transacciones en la ultima hora';
COMMENT ON COLUMN credit_card_fraud.transactions_last_24h       IS 'Numero de transacciones en las ultimas 24 horas';
COMMENT ON COLUMN credit_card_fraud.transactions_last_7d        IS 'Numero de transacciones en los ultimos 7 dias';
COMMENT ON COLUMN credit_card_fraud.amount_last_1h              IS 'Monto acumulado en la ultima hora';
COMMENT ON COLUMN credit_card_fraud.amount_last_24h             IS 'Monto acumulado en las ultimas 24 horas';
COMMENT ON COLUMN credit_card_fraud.days_since_last_transaction IS 'Dias transcurridos desde la transaccion anterior';
COMMENT ON COLUMN credit_card_fraud.distance_from_home_km       IS 'Distancia al domicilio del cliente (km)';
COMMENT ON COLUMN credit_card_fraud.distance_from_last_tx_km    IS 'Distancia a la transaccion anterior (km)';
COMMENT ON COLUMN credit_card_fraud.international_transaction   IS '1 = transaccion internacional';
COMMENT ON COLUMN credit_card_fraud.high_risk_country           IS '1 = pais considerado de alto riesgo';
COMMENT ON COLUMN credit_card_fraud.amount_vs_avg_ratio         IS 'Relacion entre el monto y el promedio historico del cliente';
COMMENT ON COLUMN credit_card_fraud.used_chip                   IS '1 = se uso chip';
COMMENT ON COLUMN credit_card_fraud.used_pin                    IS '1 = se uso PIN';
COMMENT ON COLUMN credit_card_fraud.transaction_channel         IS 'Canal (Online, In-store, ATM, Mobile App, ...)';
COMMENT ON COLUMN credit_card_fraud.device_type                 IS 'Tipo de dispositivo (Mobile, Desktop, POS Terminal, ATM, ...)';
COMMENT ON COLUMN credit_card_fraud.browser                     IS 'Navegador; "N/A" cuando no aplica (POS, ATM)';
COMMENT ON COLUMN credit_card_fraud.is_weekend                  IS '1 = fin de semana';
COMMENT ON COLUMN credit_card_fraud.avg_transaction_amount_30d  IS 'Monto promedio de transacciones de los ultimos 30 dias';
COMMENT ON COLUMN credit_card_fraud.std_transaction_amount_30d  IS 'Desviacion estandar del monto en los ultimos 30 dias';
COMMENT ON COLUMN credit_card_fraud.num_declined_last_30d       IS 'Transacciones declinadas en los ultimos 30 dias';
COMMENT ON COLUMN credit_card_fraud.num_chargebacks_ever        IS 'Contracargos historicos del cliente';
COMMENT ON COLUMN credit_card_fraud.email_domain                IS 'Tipo de dominio de correo (gmail, yahoo, hotmail, corporate, ...)';
COMMENT ON COLUMN credit_card_fraud.is_fraud                    IS 'OBJETIVO 1 (binario): 1 = fraude, 0 = legitima';
COMMENT ON COLUMN credit_card_fraud.fraud_type                  IS 'OBJETIVO 2 (multiclase): Legitimate, Card-Not-Present, Card-Present, Account-Takeover, Synthetic-Identity';
COMMENT ON COLUMN credit_card_fraud.fraud_amount_lost           IS 'OBJETIVO 3 (regresion): USD perdidos por fraude; 0 si es legitima';

-- ---------------------------------------------------------------------
-- Indices de apoyo para consultas de analisis (opcionales)
-- ---------------------------------------------------------------------
CREATE INDEX ix_ccf_customer ON credit_card_fraud (customer_id);
CREATE INDEX ix_ccf_datetime ON credit_card_fraud (transaction_datetime);
CREATE INDEX ix_ccf_is_fraud ON credit_card_fraud (is_fraud);
CREATE INDEX ix_ccf_fraud_type ON credit_card_fraud (fraud_type);
