#!/usr/bin/env bash
# =====================================================================
# Ejecuta SQL*Loader para cargar el CSV en la tabla CREDIT_CARD_FRAUD
#
# Uso:   ./03_run_loader.sh
#
# Requisitos:
#   - Cliente Oracle con sqlldr en el PATH (o ORACLE_HOME definido)
#   - Tabla creada con 01_ddl_credit_card_fraud.sql en el esquema HR
#   - Los archivos 02_load_credit_card_fraud.ctl y
#     credit_card_fraud_detection_2026.csv en la misma carpeta que este script
# =====================================================================
set -u

# ---------- Parametros de conexion (se pueden sobreescribir por entorno) ----------
DB_USER="${DB_USER:-hr}"
DB_PASS="${DB_PASS:-Oracle1}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-1521}"
DB_SERVICE="${DB_SERVICE:-ORCLPDB1}"     # ajuste al servicio de su instancia (p. ej. XEPDB1 en Express)

# ---------- Archivos ----------
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CTL_FILE="${BASE_DIR}/02_load_credit_card_fraud.ctl"
DATA_FILE="${BASE_DIR}/credit_card_fraud_detection_2026.csv"
LOG_DIR="${BASE_DIR}/logs"
TS="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${LOG_DIR}/credit_card_fraud_${TS}.log"
BAD_FILE="${LOG_DIR}/credit_card_fraud_${TS}.bad"
DSC_FILE="${LOG_DIR}/credit_card_fraud_${TS}.dsc"

# Punto como separador decimal y UTF-8, tal como viene el CSV
export NLS_LANG="AMERICAN_AMERICA.AL32UTF8"

# ---------- Validaciones previas ----------
if ! command -v sqlldr >/dev/null 2>&1; then
    echo "ERROR: no se encontro 'sqlldr'. Defina ORACLE_HOME y agregue \$ORACLE_HOME/bin al PATH." >&2
    exit 1
fi
for f in "${CTL_FILE}" "${DATA_FILE}"; do
    if [ ! -f "${f}" ]; then
        echo "ERROR: no existe el archivo ${f}" >&2
        exit 1
    fi
done
mkdir -p "${LOG_DIR}"

# ---------- Archivo de parametros temporal (evita exponer la clave en 'ps') ----------
PARFILE="$(mktemp)"
chmod 600 "${PARFILE}"
trap 'rm -f "${PARFILE}"' EXIT
echo "userid=${DB_USER}/${DB_PASS}@//${DB_HOST}:${DB_PORT}/${DB_SERVICE}" > "${PARFILE}"

# ---------- Ejecucion ----------
echo "Iniciando carga: ${DATA_FILE}"
echo "Destino: ${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}"

sqlldr parfile="${PARFILE}" \
       control="${CTL_FILE}" \
       data="${DATA_FILE}" \
       log="${LOG_FILE}" \
       bad="${BAD_FILE}" \
       discard="${DSC_FILE}"
RC=$?

# ---------- Resultado (codigos de salida de SQL*Loader) ----------
case ${RC} in
    0) echo "Carga finalizada correctamente." ;;
    2) echo "Carga finalizada con advertencias: algunas filas fueron rechazadas o descartadas." ;;
    1) echo "ERROR: la carga fallo." ;;
    3) echo "ERROR FATAL: SQL*Loader termino de forma anormal." ;;
    *) echo "SQL*Loader devolvio el codigo ${RC}." ;;
esac

echo "Log:        ${LOG_FILE}"
[ -s "${BAD_FILE}" ] && echo "Rechazadas: ${BAD_FILE}"
[ -s "${DSC_FILE}" ] && echo "Descartadas: ${DSC_FILE}"

exit ${RC}
