SET ROLE admin;
\connect client_management;
SET SCHEMA 'company';

CREATE USER alex LOGIN PASSWORD 'alex' VALID UNTIL 'infinity';
CREATE USER john LOGIN PASSWORD 'john' VALID UNTIL 'infinity';
CREATE USER sam LOGIN PASSWORD 'sam' VALID UNTIL 'infinity';

CREATE ROLE manager LOGIN PASSWORD '12345' VALID UNTIL 'infinity' INHERIT USER alex;
CREATE ROLE ranker LOGIN PASSWORD '12345' VALID UNTIL 'infinity' INHERIT USER john, sam;

ALTER TABLE company.task ENABLE ROW LEVEL SECURITY;

--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников
GRANT USAGE ON SCHEMA company to manager;
GRANT SELECT, INSERT, UPDATE ON company.task to manager;
GRANT SELECT, INSERT, UPDATE ON company.contract to manager;
GRANT SELECT ON company.employees to manager;

 --Рядовые сотрудники не могут назначать задания
GRANT USAGE ON SCHEMA company to ranker;
GRANT SELECT, UPDATE ON TABLE company.task to ranker;
GRANT SELECT ON company.employees to ranker;


--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников
--Исполнителем задания может быть сотрудник, не являющийся автором
CREATE POLICY manager_update_tasks ON company.task AS PERMISSIVE FOR UPDATE TO manager USING
    (get_manager_passport_bycurrentuser(executor_passport) is true
         or get_manager_passport_bycurrentuser(author_passport) is true)
    with check (completion_date is null and executor_passport != author_passport);

CREATE POLICY manager_insert_tasks ON company.task AS PERMISSIVE FOR INSERT TO manager USING
    (get_manager_passport_bycurrentuser(executor_passport) is true
         or get_manager_passport_bycurrentuser(author_passport) is true)
    with check (completion_date is null and executor_passport != author_passport);


--Помечать задание как выполненное и указывать дату завершения может ... исполнитель задания.
CREATE POLICY ranker_update_tasks ON company.task AS PERMISSIVE FOR UPDATE TO ranker USING
    (get_ranker_passport_bycurrentuser(executor_passport) is true
         or get_manager_passport_bycurrentuser(executor_passport) is true)
    with check (completion_date is null);


--Просматривать задание, автором которого является менеджер, может либо автор, либо исполнитель задания
CREATE POLICY manager_select_tasks ON company.task AS PERMISSIVE FOR SELECT TO manager USING
    (get_manager_passport_bycurrentuser(executor_passport) is true
         or get_manager_passport_bycurrentuser(author_passport) is true);

CREATE POLICY ranker_select_tasks ON company.task AS PERMISSIVE FOR SELECT TO ranker USING
    (get_ranker_passport_bycurrentuser(executor_passport) is true);
