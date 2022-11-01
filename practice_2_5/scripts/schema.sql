--SET ROLE postgres; ALTER ROLE postgres SUPERUSER LOGIN PASSWORD 'postgres' VALID UNTIL 'infinity';

------------------------------------------------------INIT--------------------------------------------------------------
CREATE ROLE admin LOGIN PASSWORD 'admin' VALID UNTIL 'infinity';
CREATE DATABASE client_management OWNER admin;
\connect client_management;
CREATE SCHEMA IF NOT EXISTS company;
SET SCHEMA 'company';

------------------------------------------------------TYPES-------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'employee_role') THEN
        CREATE TYPE company.employee_role as ENUM ('manager', 'ranker');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'priority') THEN
        CREATE TYPE company.priority as ENUM ('low', 'medium', 'high');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'equip_status') THEN
        CREATE TYPE company.equip_status as ENUM ('accepted', 'progress', 'completed', 'terminated');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'client_type') THEN
        CREATE TYPE company.client_type as ENUM ('current', 'potential');
    END IF;
END$$;


------------------------------------------------------TABLES------------------------------------------------------------
CREATE TABLE IF NOT EXISTS company.organization(
    ogrnip bigserial primary key UNIQUE NOT NULL,
    org_name varchar,
    type_activity varchar,
    address text
);

CREATE TABLE IF NOT EXISTS company.clients
(
    passport bigserial primary key UNIQUE NOT NULL,
    phone varchar NOT NULL,
    ogrnip bigserial references company.organization(ogrnip) NOT NULL,
    "type" client_type NOT NULL,
    username varchar NOT NULL,
    email varchar NOT NULL,
    "password" varchar NULL
);

CREATE TABLE IF NOT EXISTS company.employees (
    passport bigserial primary key UNIQUE NOT NULL,
    username varchar NOT NULL,
    "role" employee_role NOT NULL,
    phone varchar NOT NULL,
    email varchar NOT NULL,
    "password" varchar NULL
);

CREATE TABLE IF NOT EXISTS company.task (
    task_id bigserial primary key UNIQUE                               NOT NULL,

    customer_passport bigserial references company.clients(passport)   NOT NULL,
    author_passport bigserial references company.employees(passport)   NOT NULL,
    executor_passport bigserial references company.employees(passport),

    create_date timestamp without time zone                            NOT NULL,
    deadline_date timestamp without time zone,
    completion_date timestamp without time zone,

    priority priority                                                  NOT NULL,
    descriptions text
);

CREATE TABLE IF NOT EXISTS company.equipment (
    item_id bigserial primary key UNIQUE NOT NULL,
    "name" varchar NOT NULL,
    weight real,
    volume real,
    status equip_status NOT NULL
);

CREATE TABLE IF NOT EXISTS company.contract (
    contract_id bigserial primary key UNIQUE NOT NULL,
    task_id bigserial references company.task(task_id) NOT NULL,
    equipment_id bigserial references company.equipment(item_id) NOT NULL,
    create_date timestamp without time zone,
    completion_date timestamp without time zone NOT NULL
);

------------------------------------------------------POLICES-----------------------------------------------------------
CREATE USER alex LOGIN PASSWORD 'alex' VALID UNTIL 'infinity';
CREATE USER john LOGIN PASSWORD 'john' VALID UNTIL 'infinity';
CREATE USER sam LOGIN PASSWORD 'sam' VALID UNTIL 'infinity';

CREATE ROLE manager LOGIN PASSWORD '12345' VALID UNTIL 'infinity' INHERIT USER alex;
CREATE ROLE ranker LOGIN PASSWORD '12345' VALID UNTIL 'infinity' INHERIT USER john, sam;

ALTER TABLE company.task ENABLE ROW LEVEL SECURITY;

--Админ Может изменить автора задания или внести изменения в завершенное задание.
GRANT USAGE ON SCHEMA company to admin;
GRANT SELECT, UPDATE, DELETE ON company.task to admin;

--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников
GRANT USAGE ON SCHEMA company to manager;
GRANT SELECT, INSERT, UPDATE ON company.task to manager;
GRANT SELECT, INSERT, UPDATE ON company.contract to manager;
GRANT SELECT(passport, "role", username) ON company.employees to manager;

--Рядовые сотрудники не могут назначать задания
GRANT USAGE ON SCHEMA company to ranker;
GRANT SELECT, UPDATE ON TABLE company.task to ranker;
GRANT SELECT(passport, "role", username) ON company.employees to ranker;


--POLICES FUNCTIONS
CREATE OR REPLACE FUNCTION get_manager_passport_byCurrentUser(passp bigint) RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    IF (SELECT 1 FROM company.employees WHERE passport = passp
                                          and "role" = 'manager'::employee_role
                                          and username = current_user) = 1 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$BODY$;

CREATE OR REPLACE FUNCTION get_ranker_passport_byCurrentUser(passp bigint) RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    IF (SELECT 1 FROM company.employees WHERE passport = passp
                                          and "role" = 'ranker'::employee_role
                                          and username = current_user) = 1 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$BODY$;


--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников. Исполнитель - сотрудник, не являющийся автором.
CREATE POLICY manager_insert_task_assign_self ON company.task AS PERMISSIVE FOR INSERT TO manager
    with check (get_manager_passport_bycurrentuser(executor_passport) = 1);

CREATE POLICY manager_insert_task_assign_ranker ON company.task AS PERMISSIVE FOR INSERT TO manager
    with check (get_manager_passport_bycurrentuser(author_passport) = 1 and executor_passport != author_passport);


--Помечать задание как выполненное и указывать дату завершения может ... автор, исполнитель задания.
CREATE POLICY manager_update_task_self ON company.task AS PERMISSIVE FOR UPDATE TO manager USING
    (get_manager_passport_bycurrentuser(author_passport) = 1);

CREATE POLICY manager_update_task_ranker ON company.task AS PERMISSIVE FOR UPDATE TO manager USING
    (get_manager_passport_bycurrentuser(executor_passport) = 1);

CREATE POLICY ranker_update_tasks ON company.task AS PERMISSIVE FOR UPDATE TO ranker USING
    (get_ranker_passport_bycurrentuser(executor_passport) = 1);


--Просматривать задание, автором которого является менеджер, может ... автор, исполнитель задания.
CREATE POLICY manager_select_task_self ON company.task AS PERMISSIVE FOR SELECT TO manager USING
    (get_manager_passport_bycurrentuser(author_passport) = 1);

CREATE POLICY manager_select_task_ranker ON company.task AS PERMISSIVE FOR SELECT TO manager USING
    (get_manager_passport_bycurrentuser(executor_passport) = 1);

CREATE POLICY ranker_select_tasks ON company.task AS PERMISSIVE FOR SELECT TO ranker USING
    (get_ranker_passport_bycurrentuser(executor_passport) = 1);


---------------------------------------------------INSERT_RANDOM_DATA---------------------------------------------------
INSERT INTO company.organization
VALUES (4565465468789, 'GroupIB', 'Информационная безопасность', 'г.Москва, чистые пруды 1'),
       (1232487855544, 'Kaspersky', 'ИнфоБез', 'г.Москва, ленинградское щоссе 1'),
       (4565712855898, 'Yandex', 'Разработка ИС', 'г.Москва, лубянка 20');

INSERT INTO company.clients
VALUES (1234567899, '+7456789451', 4565465468789, 'potential'::client_type, 'Иван Иванович', 'qwe@gmail.com'),
       (9874561233, '+7445289452', 4565465468789, 'potential'::client_type,'Сергей Петрович', 'ert@gmail.com'),
       (4567891322, '+7456799453', 4565465468789, 'potential'::client_type,'Алексей Николаевич', 'yui@gmail.com'),

       (8988798455, '+7456789451', 1232487855544, 'potential'::client_type,'Григорий Григорьевич', 'ryy@gmail.com'),
       (7897546455, '+7445289452', 1232487855544, 'current'::client_type,'Александр Александрович', 'lkl@gmail.com'),
       (6786431323, '+7891235458', 1232487855544, 'current'::client_type, 'Федор Федорович', 'zxc@gmail.com'),

       (6548787454, '+1235487899', 4565712855898, 'current'::client_type,'Егор Григорьевич', 'sdfskjl@gmail.com'),
       (1387861654, '+8779545457', 4565712855898, 'current'::client_type,'Ярослав Александрович', 'cvsdf@gmail.com'),
       (9879889846, '+1354578455', 4565712855898, 'current'::client_type,'Святослав Федорович', 'qwasdw@gmail.com');


INSERT INTO company.employees
VALUES (1111111111, 'alex', 'manager'::employee_role, '+7456789451', 'Bob@company.com'),
       (2222222222, 'john', 'ranker'::employee_role, '+7459898984', 'john@company.com'),
       (3333333333, 'sam', 'ranker'::employee_role, '+74564545477', 'sam@company.com');

INSERT INTO company.equipment
VALUES (7979797979, 'Сервер Dell PowerEdge R340', 50.5, 10, 'accepted'::equip_status),
       (1515151515, 'CD4532BE, Шифратор приоритетный', 0.01, 0.001, 'accepted'::equip_status),
       (4987497497, 'Crucial P2 2 ТБ SSD', 0.01, 0.01, 'progress'::equip_status);



