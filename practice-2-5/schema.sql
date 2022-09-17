CREATE SCHEMA IF NOT EXISTS company;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'employee_role') THEN
        CREATE TYPE employee_role as ENUM ('manager', 'ranker');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'priority') THEN
        CREATE TYPE priority as ENUM ('low', 'medium', 'high');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS company.organization(
    ogrnip bigserial primary key UNIQUE NOT NULL,
    org_name varchar,
    type_activity varchar,
    address text
);

CREATE TABLE IF NOT EXISTS company.organization_officials(
    passport bigserial primary key UNIQUE NOT NULL,
    phone varchar NOT NULL,
    ogrnip bigserial references company.organization(ogrnip) NOT NULL,
    "name" varchar,
    email varchar
);

CREATE TABLE IF NOT EXISTS company.employees (
    passport bigserial primary key UNIQUE NOT NULL,
    username varchar NOT NULL,
    "role" employee_role NOT NULL,
    phone varchar NOT NULL,
    email varchar
);

CREATE TABLE IF NOT EXISTS company.task (
    task_id bigserial primary key UNIQUE NOT NULL,
    customer bigserial references company.organization_officials (passport) NOT NULL,
    author bigserial references company.employees(passport) NOT NULL,
    executor bigserial references company.employees(passport) NOT NULL,
    create_date timestamp without time zone NOT NULL,
    deadline_date timestamp without time zone,
    completion_date timestamp without time zone,
    priority priority NOT NULL,
    descriptions text
);

CREATE TABLE IF NOT EXISTS company.contract (
    task_id integer references company.task(task_id) NOT NULL,
    equipment_serial_number varchar,
    details jsonb
);

CREATE TABLE IF NOT EXISTS company.client (
    tasks bigserial primary key references company.task(task_id)
);

CREATE TABLE IF NOT EXISTS company.potential_client (
    tasks bigserial primary key references company.task(task_id)
);


