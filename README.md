# 📝 Taller Práctico: Del Lenguaje Natural al Modelo de Datos (Caso: Mediaglob Inc.)
**Curso:** Oracle PL/SQL — Sesión 1: Normalización y Modelamiento Lógico

---

## 🏢 1. Descripción General del Caso de Estudio

La corporación multinacional **Mediaglob Inc.** ha experimentado un crecimiento masivo en sus operaciones. Actualmente, la información sobre sus sedes internacionales, la estructura de sus departamentos, las plazas de empleo y las nóminas del personal se gestionan mediante múltiples archivos de Excel aislados por país. Esto ha generado graves problemas de datos duplicados, pérdida de históricos laborales y falta de control centralizado.

Como Ingenieros de Datos y Desarrolladores PL/SQL, el equipo de TI les ha encomendado diseñar y normalizar una base de datos relacional robusta en **Oracle DB** (Esquema Corporativo HR) que actúe como la única fuente de verdad para la compañía a nivel global.

---

## 🧭 2. Guía Metodológica de Análisis Lingüístico

Para identificar metódicamente cómo interactúan los datos, analizaremos el negocio utilizando **Oraciones Simples Transitivas**. Su estructura gramatical se traduce directamente en componentes técnicos de una base de datos de la siguiente manera:

*   **Sustantivo del Sujeto:** Determina la entidad origen (**Tabla A**).
*   **Núcleo del Predicado (Verbo Transitivo):** Define la existencia y cardinalidad de la conexión (**Relación**).
*   **Complemento Directo (Sustantivo):** Determina la entidad destino (**Tabla B**).
*   **Complementos Circunstanciales de Modo:** Determinan la opcionalidad del campo de unión (**`NOT NULL`** si es obligatorio / **`NULL`** si es opcional).
*   **Complementos Circunstanciales de Tiempo o Lugar:** Justifican la existencia de **Llaves Primarias Compuestas** o **Llaves Foráneas (FK)**.

---

## 📝 3. Ejercicios de Análisis Gramatical y de Datos

Analiza detenidamente cada oración y el ejemplo con datos reales provisto. Completa los espacios en blanco técnicos según corresponda para deducir la estructura de la base de datos.

### 🌍 Bloque 1: Estructura Geográfica Global

#### Oración 1
> **"Una Región agrupa *obligatoriamente* (*Modo*) a múltiples Países dentro de sus límites continentales (*Lugar*)."**
*   **Ejemplo Real:** La región `2 (Americas)` agrupa al país `'CO' (Colombia)` y al país `'US' (United States)`.
*   **Análisis Técnico:**
    *   La tabla origen es: `REGIONS`
    *   La tabla destino es: `COUNTRIES`
    *   Debido al modo *obligatorio*, el campo de conexión (`region_id`) en la tabla de destino debe configurarse como: ____________________ (¿`NULL` o `NOT NULL`?)

#### Oración 2
> **"Un País alberga *en cualquier momento* (*Tiempo*) varias Ubicaciones en sus diferentes provincias o estados (*Lugar*)."**
*   **Ejemplo Real:** El país `'CO' (Colombia)` alberga la ubicación física con código `1700` (ubicada en *Calle 93 #11-20, Bogotá*).
*   **Análisis Técnico:**
    *   Para conectar estas dos entidades, la Llave Foránea (`country_id`) debe inyectarse físicamente dentro de la tabla: ____________________

---

### 🏢 Bloque 2: Estructura Organizacional y de Puestos

#### Oración 3
> **"Una Ubicación aloja *de forma opcional* (*Modo*) uno o más Departamentos en sus instalaciones físicas (*Lugar*)."**
*   **Ejemplo Real:** La ubicación `1700` en Bogotá aloja de forma opcional al departamento `60 (Ventas LATAM)`.
*   **Análisis Técnico:**
    *   Si compramos un edificio de oficinas nuevo pero aún no trasladamos ningún equipo allí, la ubicación no tendrá departamentos asociados todavía. Por lo tanto, el campo `location_id` en la tabla `DEPARTMENTS` debe aceptar valores: ____________________

#### Oración 4 (La paradoja circular)
> **"Un Departamento requiere *temporalmente* (*Tiempo*) un Empleado en calidad de jefe administrativo (*Modo*)."**
*   **Ejemplo Real:** El departamento `60 (Ventas LATAM)` requiere al empleado `103 (Alexander Hunold)` como su gerente.
*   **Análisis Técnico:**
    *   ¿A qué tabla pertenece originalmente el atributo que representa al jefe de un departamento? Tabla: ____________________
    *   ¿Cómo se llama la columna (Llave Foránea) que permite hacer este puente dentro de `DEPARTMENTS`?: ____________________

---

### 👥 Bloque 3: Operaciones y Control de Personal

#### Oración 5
> **"Un Puesto define *estrictamente* (*Modo*) las condiciones salariales de muchos Empleados durante su jornada laboral (*Tiempo*)."**
*   **Ejemplo Real:** El puesto `'IT_PROG' (Programador)` define el salario máximo y mínimo del empleado `105 (David Austin)`.
*   **Análisis Técnico:**
    *   Dado que el modo es *estricto*, ¿puede existir un empleado contratado en Mediaglob Inc. que no tenga asignado un puesto de trabajo en el sistema? _________ (¿Sí o No?)

#### Oración 6 (Relación Reflexiva)
> **"Un Empleado supervisa *directamente* (*Modo*) a varios Empleados bajo su estructura jerárquica (*Estructura*)."**
*   **Ejemplo Real:** El empleado `103 (Alexander Hunold)` supervisa directamente al empleado `105 (David Austin)`.
*   **Análisis Técnico:**
    *   Este requerimiento representa una relación reflexiva (una tabla conectada consigo misma). Para modelarlo, la columna `manager_id` se crea dentro de la tabla `EMPLOYEES` y apunta a la columna clave primaria de la tabla: ____________________
    *   El Presidente Ejecutivo de la corporación no reporta a nadie dentro de la empresa. Sabiendo esto, ¿la restricción de esta columna interna debe ser `NOT NULL` o `NULL`?: ____________________

---

### ⏳ Bloque 4: Trazabilidad Temporal e Historial

#### Oración 7
> **"El Historial Laboral registra *cronológicamente* (*Modo*) los antiguos Puestos y Departamentos desde la fecha de inicio hasta la fecha de finalización (*Tiempo*)."**
*   **Ejemplo Real:** El historial del empleado `102` registra cronológicamente que ocupó el puesto `'IT_PROG'` en el departamento `60` *desde el 13-Ene-2021 hasta el 24-Jul-2024*.
*   **Análisis Técnico:**
    *   A diferencia de las tablas operativas, en `JOB_HISTORY` un mismo empleado puede aparecer repetido múltiples veces en diferentes filas debido al factor tiempo (*desde/hasta*). 
    *   Para evitar registros duplicados idénticos y garantizar la integridad temporal, la **Llave Primaria** de esta tabla no puede ser solo el código de empleado. Debe ser una **Llave Primaria Compuesta** por dos campos. Escribe cuáles campos la integran:
        1. ____________________ 
        2. ____________________

---

## 🎯 4. Desafío de Retrospectiva de Normalización
*(Responde al respaldo de la hoja)*

Observa el flujo geográfico completo: **Regiones ➔ Países ➔ Ubicaciones ➔ Departamentos**. 
Si el dueño de la corporación te solicita añadir el nombre de la Región continental (`region_name`) directamente como una columna visible dentro de la tabla de empleados (`EMPLOYEES`) para "hacer las consultas más rápidas":

1. ¿Qué Forma Normal (1FN, 2FN o 3FN) estarías rompiendo al mezclar un dato macro-geográfico en la ficha de una persona?
2. Explica brevemente qué anomalía de datos (inserción, borrado o actualización) ocurriría si el día de mañana la empresa decide reestructurar el nombre de la región *"Americas"* a *"LATAM & AMER"*.
