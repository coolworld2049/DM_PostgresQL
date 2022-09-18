INSERT INTO company.organization
VALUES (4565465468789, 'GroupIB', 'Информационная безопасность', 'г.Москва, чистые пруды 1'),
       (1232487855544, 'Kaspersky', 'ИнфоБез', 'г.Москва, ленинградское щоссе 1'),
       (4565712855898, 'Yandex', 'Разработка ИС', 'г.Москва, лубянка 20');

INSERT INTO company.clients
VALUES (1234567899, '+7456789451', 4565465468789, 'Иван Иванович', 'qwe@gmail.com'),
       (9874561233, '+7445289452', 4565465468789, 'Сергей Петрович', 'ert@gmail.com'),
       (4567891322, '+7456799453', 4565465468789, 'Алексей Николаевич', 'yui@gmail.com'),

       (8988798455, '+7456789451', 1232487855544, 'Григорий Григорьевич', 'ryy@gmail.com'),
       (7897546455, '+7445289452', 1232487855544, 'Александр Александрович', 'lkl@gmail.com'),
       (6786431323, '+7891235458', 1232487855544, 'Федор Федорович', 'zxc@gmail.com'),

       (6548787454, '+1235487899', 4565712855898, 'Егор Григорьевич', 'sdfskjl@gmail.com'),
       (1387861654, '+8779545457', 4565712855898, 'Ярослав Александрович', 'cvsdf@gmail.com'),
       (9879889846, '+1354578455', 4565712855898, 'Святослав Федорович', 'qwasdw@gmail.com');


INSERT INTO company.employees
VALUES (1111111111, 'Bob', 'manager'::employee_role, '+7456789451', 'Bob@gmail.com'),
       (2222222222, 'Tom', 'manager'::employee_role, '+7165464575', 'Tom@gmail.com'),

       (3333333333, 'Alice', 'ranker'::employee_role, '+7456789457', 'Alice@gmail.com'),
       (4444444444, 'Jack', 'ranker'::employee_role, '+5464484615', 'Jack@gmail.com'),
       (5555555555, 'Alex', 'ranker'::employee_role, '+7167846512', 'Alex@gmail.com');

INSERT INTO company.employees
VALUES (6666666666, 'postgres', 'manager'::employee_role, '+7456789451', 'postgres@gmail.com');

INSERT INTO company.task
VALUES (0, 1234567899, 3333333333, 1111111111, '2022-09-02 04:05:06'::timestamp,
        '2022-09-18 04:05:06'::timestamp, null, 'low'::priority, 'телефонный звонок'),
       (1, 9874561233, 4444444444, 2222222222, '2022-09-08 04:05:06'::timestamp,
        '2022-09-25 04:05:06'::timestamp, null, 'high'::priority, 'визит');

INSERT INTO company.current_client
    (SELECT * FROM company.clients as ccl
              WHERE (SELECT ct.customer_passport
                     FROM company.task as ct
                     WHERE customer_passport =
                           ccl.passport and
                           deadline_date > LOCALTIMESTAMP or
                         deadline_date is null) = ccl.passport);

INSERT INTO company.potential_client
    (SELECT * FROM company.clients as ccl
              WHERE (SELECT ct.customer_passport
                     FROM company.task as ct
                     WHERE customer_passport = ccl.passport and
                           deadline_date < LOCALTIMESTAMP or
                         completion_date < LOCALTIMESTAMP) = ccl.passport);

