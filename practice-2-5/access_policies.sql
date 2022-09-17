DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'manager') THEN
        CREATE ROLE manager NOLOGIN NOSUPERUSER;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ranker') THEN
        CREATE ROLE ranker NOLOGIN NOSUPERUSER;
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_group WHERE groname = 'staff') THEN
        CREATE GROUP staff;
        CREATE USER Bob NOLOGIN ROLE manager IN GROUP staff;
        CREATE USER Tom NOLOGIN ROLE manager IN GROUP staff;
        CREATE USER Alice NOLOGIN ROLE manager IN GROUP staff;
        CREATE USER Jack NOLOGIN ROLE ranker IN GROUP staff;
        CREATE USER Alex NOLOGIN ROLE ranker IN GROUP staff;
    END IF;
END$$;

GRANT ALL PRIVILEGES ON SCHEMA company to admin;
GRANT SELECT, INSERT, UPDATE ON TABLE company.task to manager;
GRANT SELECT, UPDATE ON TABLE company.task to ranker;


CREATE POLICY select_tasks ON company.task AS PERMISSIVE FOR SELECT TO manager;

CREATE POLICY update_tasks ON company.task AS PERMISSIVE FOR UPDATE TO manager, ranker USING
    (executor = (SELECT passport FROM company.employees as ce WHERE ce.username = current_user)
         or author = (SELECT passport FROM company.employees as ce WHERE ce.username = current_user)) with check (completion_date is null);

CREATE POLICY ranker_select_tasks ON company.task AS PERMISSIVE FOR SELECT TO ranker USING
    (executor = (SELECT passport FROM company.employees as ce WHERE ce.username = current_user and role = 'ranker'));

CREATE POLICY update_ranker_tasks ON company.task AS PERMISSIVE FOR UPDATE TO ranker USING
    (executor = (SELECT passport FROM company.employees as ce WHERE ce.username = current_user and role = 'ranker')) with check (completion_date is null);
