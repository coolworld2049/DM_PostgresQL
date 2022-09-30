SET SCHEMA 'company';

--Админ имеет доступ к специальным функциям, например, может изменить автора задания или внести изменения в завершенное задание.
ALTER ROLE admin SUPERUSER LOGIN PASSWORD '12345' VALID UNTIL 'infinity';
ALTER DATABASE client_management OWNER TO admin;
ALTER SCHEMA company OWNER TO admin;

CREATE ROLE manager LOGIN PASSWORD '12345' VALID UNTIL 'infinity';
CREATE ROLE ranker LOGIN PASSWORD '12345' VALID UNTIL 'infinity';

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA company to admin;

--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников
GRANT USAGE ON SCHEMA company to manager;
GRANT SELECT, INSERT, UPDATE ON company.task to manager;

 --Рядовые сотрудники не могут назначать задания
GRANT USAGE ON SCHEMA company to ranker;
GRANT SELECT, UPDATE ON TABLE company.task to ranker;

--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников
--Исполнителем задания может быть сотрудник, не являющийся автором: is_not_author(input_task_id)
CREATE POLICY manager_update_tasks ON company.task AS PERMISSIVE FOR UPDATE TO manager USING
    (executor_passport = get_manager_passport_bycurrentuser()
         or author_passport = get_manager_passport_bycurrentuser())
    with check (completion_date is null and is_not_author(task_id) is true);


--Помечать задание как выполненное и указывать дату завершения может ... исполнитель задания.
CREATE POLICY ranker_update_tasks ON company.task AS PERMISSIVE FOR UPDATE TO ranker USING
    (executor_passport = get_ranker_passport_bycurrentuser()) with check (completion_date is null);


--Просматривать задание, автором которого является менеджер, может либо автор, либо исполнитель задания
CREATE POLICY manager_select_tasks ON company.task AS PERMISSIVE FOR SELECT TO manager USING
    (executor_passport = get_manager_passport_bycurrentuser()
         or author_passport = get_manager_passport_bycurrentuser());

CREATE POLICY ranker_select_tasks ON company.task AS PERMISSIVE FOR SELECT TO ranker USING
    (executor_passport = get_ranker_passport_bycurrentuser());
