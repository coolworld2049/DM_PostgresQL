\connect client_management;
SET SCHEMA 'company';
SET ROLE sam;

--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников
--Исполнителем задания может быть сотрудник, не являющийся автором
    INSERT INTO company.task
    VALUES
        (4,

        1234567899, 1111111111, 2222222222,

        '2022-09-02 04:05:06'::timestamp,
        '2022-09-18 04:05:06'::timestamp,
        null,

        'low'::priority,
        'телефонный звонок'),

        (5,

        6548787454, 1111111111, 1111111111,

        '2022-09-08 04:05:06'::timestamp,
        '2022-09-25 04:05:06'::timestamp,
        null,

        'medium'::priority,
        'визит'),

        (6,

            6548787454, 1111111111, 3333333333,

            '2022-09-08 04:05:06'::timestamp,
            '2022-09-25 04:05:06'::timestamp,
            null,

            'high'::priority,
            'отправка оборудования'),
        (7,

            6548787454, 1111111111, 3333333333,

            '2022-09-08 04:05:06'::timestamp,
            '2022-09-25 04:05:06'::timestamp,
            null,

            'high'::priority,
            'отправка оборудования');

    INSERT INTO company.contract
    VALUES (147147147,
            4,
            7979797979,

            '2022-10-01 04:05:06'::timestamp,
            '2025-06-11 04:05:06'::timestamp),

           (789789789,
            5,
            1515151515,

            '2022-10-01 04:05:06'::timestamp,
            '2023-09-25 04:05:06'::timestamp);

--Помечать задание как выполненное и указывать дату завершения может ... исполнитель задания.
    UPDATE company.task SET completion_date = current_timestamp WHERE task_id = 4;
    UPDATE company.contract SET completion_date = current_timestamp WHERE task_id = 4;

--Просматривать задание, автором которого является менеджер, может либо автор, либо исполнитель задания
    SELECT * FROM company.task;
    SELECT * FROM company.task WHERE author_passport = 1111111111;
    SELECT * FROM company.task WHERE executor_passport = 1111111111;