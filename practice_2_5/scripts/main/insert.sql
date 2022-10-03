SET ROLE admin;
SET SCHEMA 'company';

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