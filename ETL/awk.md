# awk: procesamiento rápido de archivos de texto de gran volumen

**awk** es un lenguaje diseñado para procesar archivos de texto organizados en filas y columnas, como los archivos CSV, los logs o los reportes. Es una herramienta estándar en Linux y macOS, y permite filtrar, resumir y transformar millones de filas con una sola línea de comandos, sin cargar el archivo en una base de datos ni abrirlo en una hoja de cálculo.

Este documento presenta el lenguaje y lo aplica al archivo `credit_card_fraud_detection_2026.csv`, el dataset sintético de detección de fraude en tarjetas de crédito publicado en Kaggle y usado en el proceso ETL de este repositorio (ver [`ETL.md`](ETL.md)).

- Dataset: <https://www.kaggle.com/datasets/mohankrishnathalla/credit-card-fraud-detection-dataset-2026>
- Estructura: 43 columnas, separadas por coma, con una fila de encabezados. El dataset original tiene 100.000 transacciones.

---

## 1. ¿Qué es awk?

El nombre viene de las iniciales de sus autores: **A**ho, **W**einberger y **K**ernighan, quienes lo crearon en los laboratorios Bell a finales de los años setenta. Hoy existen varias implementaciones compatibles entre sí:

| Implementación | Comentario |
|----------------|------------|
| `gawk` | La versión de GNU, la más completa. Viene en la mayoría de distribuciones Linux. |
| `mawk` | Muy rápida y liviana. Es el `awk` por defecto en Debian y Ubuntu. |
| `awk` (BWK) | La versión original mantenida por Brian Kernighan. Es la que trae macOS. |

Todos los ejemplos de este documento usan solo características comunes, así que funcionan en cualquiera de ellas. Las excepciones se indican de forma explícita.

### El modelo mental

awk lee el archivo **línea por línea** (cada línea es un *registro*), la divide en **campos** y aplica reglas del tipo *patrón { acción }*:

```
awk 'patrón { acción }' archivo
```

- Si la línea cumple el **patrón**, se ejecuta la **acción**.
- Si se omite el patrón, la acción se ejecuta en todas las líneas.
- Si se omite la acción, se imprime la línea completa.

Como procesa una línea a la vez, awk no necesita cargar el archivo completo en memoria. Por eso es adecuado para archivos grandes.

### Variables y elementos clave

| Elemento | Significado |
|----------|-------------|
| `$0` | La línea completa |
| `$1`, `$2`, ... `$NF` | El campo 1, el campo 2, ... el último campo |
| `NR` | Número de la línea actual (acumulado entre archivos) |
| `NF` | Número de campos de la línea actual |
| `FS` / `-F` | Separador de campos de entrada (en CSV: `,`) |
| `OFS` | Separador de campos de salida |
| `BEGIN { ... }` | Se ejecuta **antes** de leer la primera línea |
| `END { ... }` | Se ejecuta **después** de leer la última línea |
| `arreglo[clave]` | Arreglos asociativos: permiten agrupar y contar (equivalente a un `GROUP BY`) |
| `-v var=valor` | Pasa una variable del shell a awk |

---

## 2. Columnas del archivo y su posición

awk identifica las columnas por su posición, empezando en 1. Estas son las columnas del dataset que se usan en los ejemplos:

| N.º | Columna | N.º | Columna |
|----:|---------|----:|---------|
| 1 | `transaction_id` | 27 | `international_transaction` |
| 2 | `customer_id` | 28 | `high_risk_country` |
| 5 | `transaction_datetime` | 30 | `used_chip` |
| 6 | `transaction_amount` | 31 | `used_pin` |
| 7 | `merchant_category` | 32 | `transaction_channel` |
| 8 | `merchant_country` | 35 | `is_weekend` |
| 9 | `transaction_hour` | 40 | `email_domain` |
| 11 | `card_present` | 41 | `is_fraud` |
| 12 | `customer_age` | 42 | `fraud_type` |
| 13 | `customer_gender` | 43 | `fraud_amount_lost` |

> **Cómo verificar las posiciones.** Este comando muestra cada columna con su número:
> ```bash
> head -1 credit_card_fraud_detection_2026.csv | tr ',' '\n' | cat -n
> ```

---

## 3. Ejemplos básicos

Todos los ejemplos suponen que el archivo está en la carpeta actual. Se usa `-F','` para indicar que el separador es la coma.

### 3.1. Contar las transacciones (sin la fila de encabezados)

```bash
awk 'END { print NR - 1 }' credit_card_fraud_detection_2026.csv
```

### 3.2. Ver las primeras columnas de las primeras filas

```bash
awk -F',' 'NR <= 5 { print $1, $5, $6 }' credit_card_fraud_detection_2026.csv
```

### 3.3. Extraer algunas columnas a un archivo nuevo

`OFS` define el separador de la salida; con `-v OFS=,` el resultado sigue siendo un CSV.

```bash
awk -F',' -v OFS=',' '{ print $1, $5, $6, $41 }' credit_card_fraud_detection_2026.csv > resumen.csv
```

---

## 4. Filtros

En un filtro, el patrón va antes de las llaves. La condición `NR == 1 ||` conserva la fila de encabezados en la salida.

### 4.1. Solo las transacciones fraudulentas

```bash
awk -F',' 'NR == 1 || $41 == 1' credit_card_fraud_detection_2026.csv > fraudes.csv
```

### 4.2. Transacciones de más de 100 dólares

```bash
awk -F',' 'NR > 1 && $6 > 100 { print $1, $6, $7 }' credit_card_fraud_detection_2026.csv
```

### 4.3. Fraudes por robo de cuenta, mostrando el monto perdido

```bash
awk -F',' '$42 == "Account-Takeover" { print $1, $2, $43 }' credit_card_fraud_detection_2026.csv
```

### 4.4. Transacciones internacionales hechas sin PIN

```bash
awk -F',' 'NR > 1 && $27 == 1 && $31 == 0 { print $1, $8, $6 }' credit_card_fraud_detection_2026.csv
```

### 4.5. Transacciones de un mes (por prefijo de la fecha)

```bash
awk -F',' 'NR > 1 && substr($5, 1, 7) == "2026-01"' credit_card_fraud_detection_2026.csv
```

### 4.6. Con expresiones regulares

```bash
# Categorías de comercio que contienen la palabra "Retail"
awk -F',' '$7 ~ /Retail/ { print $1, $7, $6 }' credit_card_fraud_detection_2026.csv
```

### 4.7. Usar una variable del shell como umbral

```bash
awk -F',' -v min=500 'NR > 1 && $6 >= min { n++ } END { print n + 0, "transacciones >=", min }' credit_card_fraud_detection_2026.csv
```

---

## 5. Agregaciones (el equivalente a `GROUP BY`)

Los arreglos asociativos permiten agrupar sin necesidad de ordenar el archivo antes. Como awk no garantiza el orden en que recorre un arreglo, el resultado se ordena con `sort`.

### 5.1. Total, promedio, máximo y mínimo del monto

```bash
awk -F',' '
NR == 2 { max = min = $6 }
NR > 1  { suma += $6; if ($6 > max) max = $6; if ($6 < min) min = $6 }
END     { printf "total=%.2f promedio=%.2f maximo=%.2f minimo=%.2f\n",
                 suma, suma / (NR - 1), max, min }
' credit_card_fraud_detection_2026.csv
```

### 5.2. Tasa de fraude global

```bash
awk -F',' 'NR > 1 { n++; f += $41 } END { printf "%d fraudes de %d (%.2f%%)\n", f, n, 100 * f / n }' credit_card_fraud_detection_2026.csv
```

### 5.3. Cantidad de transacciones y monto total por categoría de comercio

```bash
awk -F',' '
NR > 1 { cant[$7]++; monto[$7] += $6 }
END    { for (k in cant) printf "%s,%d,%.2f\n", k, cant[k], monto[k] }
' credit_card_fraud_detection_2026.csv | sort -t',' -k3,3nr
```

### 5.4. Fraudes y dinero perdido por tipo de fraude

```bash
awk -F',' '
NR > 1 { n[$42]++; perdido[$42] += $43 }
END    { for (t in n) printf "%-20s %8d %12.2f\n", t, n[t], perdido[t] }
' credit_card_fraud_detection_2026.csv
```

### 5.5. Tasa de fraude por hora del día

```bash
awk -F',' '
NR > 1 { n[$9]++; f[$9] += $41 }
END    { for (h in n) printf "%02d %d %d %.2f%%\n", h, n[h], f[h], 100 * f[h] / n[h] }
' credit_card_fraud_detection_2026.csv | sort -n
```

### 5.6. Edad promedio por género

```bash
awk -F',' 'NR > 1 { n[$13]++; suma[$13] += $12 } END { for (g in n) print g, n[g], suma[g] / n[g] }' credit_card_fraud_detection_2026.csv
```

### 5.7. Los 10 clientes con mayor monto acumulado

```bash
awk -F',' 'NR > 1 { total[$2] += $6 } END { for (c in total) printf "%s\t%.2f\n", c, total[c] }' credit_card_fraud_detection_2026.csv \
  | sort -k2,2nr | head -10
```

### 5.8. Cantidad de valores distintos (por ejemplo, países de comercio)

```bash
awk -F',' 'NR > 1 && !($8 in visto) { visto[$8]; n++ } END { print n, "paises distintos" }' credit_card_fraud_detection_2026.csv
```

---

## 6. Referirse a las columnas por nombre

Contar posiciones es propenso a errores. Se puede leer la fila de encabezados y guardar la posición de cada columna en un arreglo:

```bash
awk -F',' '
NR == 1 { for (i = 1; i <= NF; i++) pos[$i] = i; next }
$pos["is_fraud"] == 1 { print $pos["transaction_id"], $pos["fraud_type"], $pos["fraud_amount_lost"] }
' credit_card_fraud_detection_2026.csv
```

Así el comando sigue funcionando aunque cambie el orden de las columnas.

---

## 7. Validación y preparación de datos para Oracle

awk es muy útil como paso previo a la carga con SQL\*Loader.

### 7.1. Detectar filas con un número de columnas incorrecto

Cada fila debe tener 43 campos. Este comando muestra los números de línea que no cumplen:

```bash
awk -F',' 'NF != 43 { print "Linea " NR ": " NF " campos" }' credit_card_fraud_detection_2026.csv
```

Si no imprime nada, todas las filas tienen la estructura esperada.

### 7.2. Buscar valores inválidos en indicadores 0/1

```bash
awk -F',' 'NR > 1 && $41 != 0 && $41 != 1 { print "Linea " NR ": is_fraud=" $41 }' credit_card_fraud_detection_2026.csv
```

### 7.3. Verificar que `fraud_type` solo tenga valores válidos

```bash
awk -F',' '
BEGIN { ok["Legitimate"]; ok["Card-Not-Present"]; ok["Card-Present"]; ok["Account-Takeover"]; ok["Synthetic-Identity"] }
NR > 1 && !($42 in ok) { print "Linea " NR ": fraud_type=" $42 }
' credit_card_fraud_detection_2026.csv
```

Los tres comandos anteriores comprueban lo mismo que las restricciones `CHECK` de `01_ddl_credit_card_fraud.sql`. Así se encuentran los problemas antes de que Oracle rechace las filas.

### 7.4. Quitar la fila de encabezados

```bash
awk 'NR > 1' credit_card_fraud_detection_2026.csv > sin_encabezado.csv
```

### 7.5. Extraer una muestra para pruebas (una de cada 100 filas)

```bash
awk 'NR == 1 || NR % 100 == 0' credit_card_fraud_detection_2026.csv > muestra.csv
```

### 7.6. Separar el archivo en fraudes y legítimas (una sola lectura)

```bash
awk -F',' '
NR == 1 { encabezado = $0; next }
{
  salida = ($41 == 1) ? "fraudes.csv" : "legitimas.csv"
  if (!(salida in creado)) { print encabezado > salida; creado[salida] = 1 }
  print > salida
}
' credit_card_fraud_detection_2026.csv
```

### 7.7. Generar sentencias INSERT de ejemplo

Para una carga masiva se debe usar SQL\*Loader, pero para mostrar cómo se genera SQL con awk basta un ejemplo con pocas columnas (aquí, las 5 primeras filas de datos):

```bash
awk -F',' 'NR > 1 && NR <= 6 {
  printf "INSERT INTO credit_card_fraud (transaction_id, transaction_amount, is_fraud) VALUES (\047%s\047, %s, %s);\n", $1, $6, $41
}' credit_card_fraud_detection_2026.csv
```

(`\047` es el código de la comilla simple.)

### 7.8. Archivos con saltos de línea de Windows (CRLF)

Si el archivo viene de Windows, cada línea termina en `\r`, que queda pegado al último campo. Se elimina así:

```bash
awk -F',' '{ sub(/\r$/, "") } NF == 43 { print $1, $43 }' credit_card_fraud_detection_2026.csv
```

---

## 8. Un reporte completo en un archivo `.awk`

Cuando la lógica crece, conviene guardarla en un archivo. Crear `reporte_fraude.awk`:

```awk
# reporte_fraude.awk - resumen del dataset de fraude
BEGIN { FS = "," }

NR > 1 {
    total++
    monto_total += $6
    if ($41 == 1) {
        fraudes++
        perdido += $43
        por_tipo[$42]++
    }
}

END {
    printf "Transacciones:      %d\n", total
    printf "Monto total (USD):  %.2f\n", monto_total
    printf "Fraudes:            %d (%.2f%%)\n", fraudes, 100 * fraudes / total
    printf "Perdido (USD):      %.2f\n", perdido
    print  "Fraudes por tipo:"
    for (t in por_tipo) printf "  %-20s %d\n", t, por_tipo[t]
}
```

Se ejecuta con:

```bash
awk -f reporte_fraude.awk credit_card_fraud_detection_2026.csv
```

---

## 9. Limitaciones y buenas prácticas

- **Campos entre comillas con comas.** awk separa por cada coma, por lo que un campo como `"Pérez, Juan"` se partiría en dos. En este dataset no se esperan campos con comas internas, pero conviene comprobarlo con el comando de la sección 7.1. Si algún día aparecen, `gawk` ofrece la variable `FPAT` para manejar campos entre comillas.
- **Los arreglos viven en memoria.** Agrupar por una columna con pocos valores distintos (categoría, país, hora) es muy liviano. Agrupar por una columna con millones de valores distintos (por ejemplo, `transaction_id`) consume memoria proporcional.
- **Los números se comparan como números solo si lo parecen.** Si una columna trae valores como `N/A`, la comparación puede dar resultados inesperados. Valide primero los datos.
- **Probar con una muestra.** Antes de lanzar un comando sobre el archivo completo, pruébelo con el archivo de muestra de la sección 7.5.
- **Combinar con otras herramientas.** awk funciona muy bien junto con `sort`, `uniq`, `head`, `wc` y `cut` mediante tuberías (`|`).
- **Cuándo usar Oracle.** awk resuelve consultas rápidas sobre un archivo. Cuando se necesitan joins, índices, concurrencia o consultas repetidas, el lugar adecuado es la base de datos (ver `ETL.md`).

---

## 10. Referencias

- Manual de GNU awk: <https://www.gnu.org/software/gawk/manual/>
- Libro *The AWK Programming Language*, de Aho, Kernighan y Weinberger.
- Kaggle: [Credit Card Fraud Detection Dataset 2026](https://www.kaggle.com/datasets/mohankrishnathalla/credit-card-fraud-detection-dataset-2026)
