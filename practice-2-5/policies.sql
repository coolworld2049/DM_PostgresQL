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
        CREATE USER Bob WITH LOGIN ROLE manager IN GROUP staff;
        CREATE USER Tom WITH LOGIN ROLE manager IN GROUP staff;
        CREATE USER Alice WITH LOGIN ROLE manager IN GROUP staff;
        CREATE USER Jack WITH LOGIN ROLE ranker IN GROUP staff;
        CREATE USER Alex WITH LOGIN ROLE ranker IN GROUP staff;
    END IF;
END$$;

GRANT ALL PRIVILEGES ON SCHEMA company to admin; --Админ имеет доступ к специальным функциям, например, может изменить автора задания или внести изменения в завершенное задание.
GRANT SELECT, INSERT, UPDATE ON TABLE company.task to manager; --Менеджеры назначают задания себе или кому-либо из рядовых сотрудников
GRANT SELECT ON TABLE company.task to ranker; --Рядовые сотрудники не могут назначать задания

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