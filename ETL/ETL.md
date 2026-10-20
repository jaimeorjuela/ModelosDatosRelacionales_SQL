# Proceso ETL en Oracle: carga de transacciones de tarjetas de crédito

Este documento explica qué es un proceso **ETL** (Extracción, Transformación y Carga), cómo se implementa con las herramientas de **Oracle Database 19c**, y cómo se aplica en el ejemplo de este repositorio: la carga de un dataset de detección de fraude en tarjetas de crédito descargado de Kaggle.

---

## 1. ¿Qué es un proceso ETL?

**ETL** son las siglas de *Extract, Transform, Load*. Es el proceso que mueve datos desde una o varias fuentes hasta un destino donde puedan consultarse y analizarse, generalmente una base de datos o un data warehouse.

| Fase | Qué hace | Ejemplo en este repositorio |
|------|----------|-----------------------------|
| **E - Extracción** | Obtiene los datos desde la fuente original. | Descarga del archivo CSV desde Kaggle. |
| **T - Transformación** | Limpia, valida, convierte tipos y enriquece los datos. | Conversión de fechas y números, validación de dominios (0/1, tipos de fraude), cálculos derivados. |
| **L - Carga** | Inserta los datos ya preparados en el destino. | Carga de las filas en la tabla `CREDIT_CARD_FRAUD` con SQL*Loader. |

```
 Fuente                   Área de trabajo / Oracle                 Destino final
┌──────────┐  Extracción  ┌──────────────────────┐  Transformación ┌─────────────────┐
│ CSV de   │ ───────────► │ Tabla CREDIT_CARD_   │ ──────────────► │ Tablas de       │
│ Kaggle   │              │ FRAUD (carga SQL*    │   (SQL/PL/SQL)  │ análisis, vistas│
└──────────┘              │ Loader)              │                 │ o reportes      │
                          └──────────────────────┘                 └─────────────────┘
```

> **Nota sobre ETL y ELT.** En este ejemplo los datos se cargan casi tal cual vienen (con conversión de tipos) y luego se validan y transforman dentro de Oracle con SQL y PL/SQL. Ese orden (cargar primero, transformar después) suele llamarse **ELT**. En la práctica ambos enfoques se agrupan bajo el nombre ETL y la elección depende del volumen de datos y de las herramientas disponibles.

---

## 2. Herramientas de Oracle para cada fase

| Fase | Herramienta | Uso típico |
|------|-------------|-----------|
| Extracción / Carga | **SQL\*Loader** | Carga masiva de archivos planos (CSV, TXT) en tablas. Es la que se usa en este ejemplo. |
| Extracción / Carga | **Tablas externas** (`ORGANIZATION EXTERNAL`) | Consultar un archivo plano con SQL como si fuera una tabla, sin cargarlo antes. |
| Extracción / Carga | **Oracle Data Pump** (`expdp` / `impdp`) | Mover datos y objetos entre bases de datos Oracle. |
| Transformación | **SQL** (`INSERT ... SELECT`, `MERGE`, funciones analíticas) | Transformaciones por conjuntos, rápidas y declarativas. |
| Transformación | **PL/SQL** (procedimientos, paquetes, `BULK COLLECT`, `FORALL`) | Lógica más compleja, validaciones y manejo de errores. |
| Orquestación | **DBMS_SCHEDULER** | Programar la ejecución periódica del proceso. |
| Plataformas completas | **Oracle Data Integrator (ODI)**, **GoldenGate** | ETL empresarial y replicación en tiempo real. |

---

## 3. El dataset de ejemplo

Los datos provienen del dataset **Credit Card Fraud Detection Dataset 2026**, publicado en Kaggle por Mohan Krishna Thalla:

- Enlace: <https://www.kaggle.com/datasets/mohankrishnathalla/credit-card-fraud-detection-dataset-2026>
- Licencia: CC0 (dominio público).

Según la documentación del autor, es un **dataset sintético** (no contiene datos reales de clientes ni de bancos) que simula transacciones de tarjetas de crédito para practicar análisis y modelos de detección de fraude:

- **100.000 transacciones** del año 2026 (del 2026-01-01 al 2026-12-31).
- **43 columnas**: 40 variables descriptivas y 3 variables objetivo.
- Tasa de fraude aproximada del **2,06 %**, es decir, un conjunto desbalanceado, como ocurre en la realidad.

### Grupos de columnas

| Grupo | Columnas (ejemplos) |
|-------|---------------------|
| Identificadores | `transaction_id`, `customer_id`, `card_id`, `merchant_id` |
| Detalle de la transacción | `transaction_datetime`, `transaction_amount`, `merchant_category`, `merchant_country`, `card_present` |
| Perfil del cliente | `customer_age`, `customer_gender`, `customer_state`, `account_age_days`, `credit_limit`, `credit_score`, `num_cards_held` |
| Velocidad de uso | `transactions_last_1h`, `transactions_last_24h`, `transactions_last_7d`, `amount_last_1h`, `amount_last_24h` |
| Geografía y riesgo | `distance_from_home_km`, `international_transaction`, `high_risk_country`, `amount_vs_avg_ratio` |
| Canal y dispositivo | `transaction_channel`, `device_type`, `browser`, `used_chip`, `used_pin` |
| Histórico de 30 días | `avg_transaction_amount_30d`, `std_transaction_amount_30d`, `num_declined_last_30d`, `num_chargebacks_ever` |
| **Variables objetivo** | `is_fraud` (0/1), `fraud_type` (multiclase), `fraud_amount_lost` (USD perdidos) |

La variable `fraud_type` tiene cinco clases: `Legitimate`, `Card-Not-Present`, `Card-Present`, `Account-Takeover` y `Synthetic-Identity`.

> El archivo CSV incluido en este repositorio puede ser solo una muestra del dataset original (por ejemplo, con pocas filas). El proceso es el mismo para el archivo completo de Kaggle.

---

## 4. Archivos del proyecto

| Archivo | Fase | Descripción |
|---------|------|-------------|
| `credit_card_fraud_detection_2026.csv` | Extracción | Archivo de datos descargado de Kaggle. |
| `01_ddl_credit_card_fraud.sql` | Preparación del destino | Script DDL que crea la tabla `CREDIT_CARD_FRAUD`, con tipos de datos, restricciones, comentarios e índices. |
| `02_load_credit_card_fraud.ctl` | Carga | Archivo de control de SQL\*Loader que define cómo se lee el CSV. |
| `03_run_loader.sh` | Carga | Script de shell que ejecuta SQL\*Loader y guarda los logs. |

---

## 5. Paso a paso

### 5.1. Extracción

1. Descargar el dataset desde Kaggle (se requiere una cuenta gratuita).
2. Copiar el archivo `.csv` a la misma carpeta que los demás archivos del proyecto.

El archivo es de texto plano, con separador de coma, una fila de encabezados y fechas en formato `YYYY-MM-DD HH24:MI:SS`.

### 5.2. Preparación del destino (DDL)

Conectado como el usuario `kaggle/Oracle1`, ejecutar el script que crea la tabla:

```sql
@01_ddl_credit_card_fraud.sql
```

Decisiones de diseño relevantes:

- `transaction_id` es la **clave primaria**.
- Las columnas de tipo indicador (`is_fraud`, `card_present`, `used_chip`, etc.) tienen una restricción `CHECK` que solo permite 0 o 1.
- `fraud_type` solo acepta los cinco valores documentados.
- Cada columna tiene un comentario (`COMMENT ON COLUMN`) que se puede consultar en `USER_COL_COMMENTS`.

### 5.3. Carga con SQL\*Loader

El archivo de control `02_load_credit_card_fraud.ctl` indica:

- `SKIP=1`: omite la fila de encabezados.
- `FIELDS TERMINATED BY ','`: separador de campos.
- `transaction_datetime DATE "YYYY-MM-DD HH24:MI:SS"`: máscara de conversión de la fecha.
- `APPEND`: agrega las filas a la tabla (usar `TRUNCATE` para vaciarla antes).
- Archivos `.bad` (filas rechazadas) y `.dsc` (filas descartadas) para revisar errores.

Para ejecutar la carga:

```bash
chmod +x 03_run_loader.sh
./03_run_loader.sh
```

El script se conecta a la instancia en `localhost`, ejecuta `sqlldr` y deja el log y los archivos de errores en la carpeta `logs/`. Los parámetros de conexión pueden sobrescribirse con variables de entorno:

```bash
DB_SERVICE=XEPDB1 ./03_run_loader.sh
```

> **Importante:** el script usa un usuario y una contraseña de ejemplo para fines didácticos. En un entorno real no se deben guardar credenciales en texto plano ni subirlas a un repositorio.

### 5.4. Validación de la carga

Después de cargar, conviene comprobar que el proceso fue correcto:

```sql
-- Total de filas cargadas
SELECT COUNT(*) AS total_filas FROM credit_card_fraud;

-- Distribución de transacciones legítimas y fraudulentas
SELECT is_fraud, COUNT(*) AS cantidad,
       ROUND(100 * RATIO_TO_REPORT(COUNT(*)) OVER (), 2) AS porcentaje
FROM   credit_card_fraud
GROUP  BY is_fraud;

-- Rango de fechas cargado
SELECT MIN(transaction_datetime) AS desde,
       MAX(transaction_datetime) AS hasta
FROM   credit_card_fraud;
```

Además, hay que revisar el log de SQL\*Loader: debe indicar el número de filas cargadas y cuántas fueron rechazadas.

### 5.5. Transformación

Con los datos ya en Oracle, la transformación se hace con SQL o PL/SQL. Algunos ejemplos aplicables a este dataset:

```sql
-- Resumen de fraude por tipo y categoría de comercio
SELECT fraud_type,
       merchant_category,
       COUNT(*)                         AS transacciones,
       ROUND(SUM(fraud_amount_lost), 2) AS monto_perdido
FROM   credit_card_fraud
WHERE  is_fraud = 1
GROUP  BY fraud_type, merchant_category
ORDER  BY monto_perdido DESC;

-- Fraude por hora del día
SELECT transaction_hour,
       COUNT(*)                                       AS transacciones,
       SUM(is_fraud)                                  AS fraudes,
       ROUND(100 * SUM(is_fraud) / COUNT(*), 2)       AS tasa_fraude_pct
FROM   credit_card_fraud
GROUP  BY transaction_hour
ORDER  BY transaction_hour;
```

Otras transformaciones posibles para practicar:

- Crear una tabla de resumen mensual con `CREATE TABLE ... AS SELECT`.
- Cargar el resultado en una tabla de hechos usando `MERGE` para evitar duplicados.
- Encapsular el proceso en un procedimiento PL/SQL con manejo de excepciones y registro en una tabla de auditoría.
- Programar la ejecución periódica con `DBMS_SCHEDULER`.

---

## 6. Buenas prácticas

- **Validar antes de cargar:** revisar el formato del archivo (separador, codificación, fechas) antes de definir el archivo de control.
- **Usar restricciones:** las claves primarias y las restricciones `CHECK` detectan datos erróneos desde el momento de la carga.
- **Conservar los logs:** los archivos `.log`, `.bad` y `.dsc` permiten auditar el proceso.
- **Hacer el proceso repetible:** el script de DDL elimina y recrea la tabla, y los parámetros del script de carga se pueden cambiar sin editar el código.
- **Separar datos crudos y datos transformados:** conservar la tabla original facilita volver a ejecutar las transformaciones.
- **Proteger las credenciales:** usar variables de entorno, un *wallet* de Oracle o un gestor de secretos.

---

## 7. Referencias

- Kaggle: [Credit Card Fraud Detection Dataset 2026](https://www.kaggle.com/datasets/mohankrishnathalla/credit-card-fraud-detection-dataset-2026)
- Documentación de Oracle Database 19c: *Utilities – SQL\*Loader* y *PL/SQL Language Reference* (<https://docs.oracle.com/en/database/oracle/oracle-database/19/>)
