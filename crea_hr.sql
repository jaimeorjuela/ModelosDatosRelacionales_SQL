-- 1. REGIONS
CREATE TABLE hr.regions (
    region_id   NUMBER PRIMARY KEY,
    region_name VARCHAR2(25)
);

-- 2. COUNTRIES
CREATE TABLE hr.countries (
    country_id   CHAR(2) PRIMARY KEY,
    country_name VARCHAR2(40),
    region_id    NUMBER,
    CONSTRAINT fk_countries_regions FOREIGN KEY (region_id) REFERENCES hr.regions(region_id)
);

-- 3. LOCATIONS
CREATE TABLE hr.locations (
    location_id    NUMBER(4) PRIMARY KEY,
    street_address VARCHAR2(40),
    postal_code    VARCHAR2(12),
    city           VARCHAR2(30) NOT NULL,
    state_province VARCHAR2(25),
    country_id     CHAR(2),
    CONSTRAINT fk_locations_countries FOREIGN KEY (country_id) REFERENCES hr.countries(country_id)
);

-- 4. JOBS
CREATE TABLE hr.jobs (
    job_id     VARCHAR2(10) PRIMARY KEY,
    job_title  VARCHAR2(35) NOT NULL,
    min_salary NUMBER(6),
    max_salary NUMBER(6)
);

-- 5. DEPARTMENTS
CREATE TABLE hr.departments (
    department_id   NUMBER(4) PRIMARY KEY,
    department_name VARCHAR2(30) NOT NULL,
    manager_id      NUMBER(6),
    location_id     NUMBER(4),
    CONSTRAINT fk_departments_locations FOREIGN KEY (location_id) REFERENCES hr.locations(location_id)
);

-- 6. EMPLOYEES
CREATE TABLE hr.employees (
    employee_id    NUMBER(6) PRIMARY KEY,
    first_name     VARCHAR2(20),
    last_name      VARCHAR2(25) NOT NULL,
    email          VARCHAR2(25) NOT NULL,
    phone_number   VARCHAR2(20),
    hire_date      DATE NOT NULL,
    job_id         VARCHAR2(10) NOT NULL,
    salary         NUMBER(8,2),
    commission_pct NUMBER(2,2),
    manager_id     NUMBER(6),
    department_id  NUMBER(4),
    CONSTRAINT fk_employees_jobs FOREIGN KEY (job_id) REFERENCES hr.jobs(job_id),
    CONSTRAINT fk_employees_departments FOREIGN KEY (department_id) REFERENCES hr.departments(department_id),
    CONSTRAINT fk_employees_manager FOREIGN KEY (manager_id) REFERENCES hr.employees(employee_id)
);

-- Relación circular diferida: Conectar el Manager del departamento a Employees
ALTER TABLE hr.departments 
ADD CONSTRAINT fk_departments_employees FOREIGN KEY (manager_id) REFERENCES hr.employees(employee_id);

-- 7. JOB_HISTORY
CREATE TABLE hr.job_history (
    employee_id   NUMBER(6) NOT NULL,
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    job_id        VARCHAR2(10) NOT NULL,
    department_id NUMBER(4),
    CONSTRAINT pk_job_history PRIMARY KEY (employee_id, start_date),
    CONSTRAINT fk_job_history_employees FOREIGN KEY (employee_id) REFERENCES hr.employees(employee_id),
    CONSTRAINT fk_job_history_jobs FOREIGN KEY (job_id) REFERENCES hr.jobs(job_id),
    CONSTRAINT fk_job_history_departments FOREIGN KEY (department_id) REFERENCES hr.departments(department_id)
);
