SET ROLE admin;
SET SCHEMA 'company';

-- общее количество заданий для данного сотрудника в указанный период
CREATE OR REPLACE FUNCTION total_number_employee_tasks_in_period
    (start_timestamp timestamp , end_timestamp timestamp , employee_passport bigint)
    RETURNS bigint AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                  and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$
LANGUAGE plpgsql;

-- сколько заданий завершено вовремя
CREATE OR REPLACE FUNCTION number_employee_tasks_completed_on_time
    (start_timestamp timestamp , end_timestamp timestamp , employee_passport bigint)
    RETURNS bigint AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                            and deadline_date::timestamp >= completion_date::timestamp
                                                            and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$
LANGUAGE plpgsql;

-- сколько заданий завершено с нарушением срока исполнения
CREATE OR REPLACE FUNCTION number_employee_tasks_not_completed_on_time
    (start_timestamp timestamp , end_timestamp timestamp , employee_passport bigint)
    RETURNS bigint AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                            and deadline_date::timestamp < completion_date::timestamp
                                                            and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$
LANGUAGE plpgsql;

-- сколько заданий с истекшим сроком исполнения не завершено
CREATE OR REPLACE FUNCTION number_employee_tasks_unfinished
    (start_timestamp timestamp , end_timestamp timestamp , employee_passport bigint)
    RETURNS bigint AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                            and current_timestamp > deadline_date::timestamp
                                                            and completion_date is null
                                                            and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$
LANGUAGE plpgsql;


-- сколько не завершенных заданий, срок исполнения которых не истек
CREATE OR REPLACE FUNCTION number_employee_tasks_unfinished_that_not_expired
    (start_timestamp timestamp , end_timestamp timestamp , employee_passport bigint)
    RETURNS bigint AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                            and current_timestamp < deadline_date::timestamp
                                                            and completion_date is null
                                                            and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$
LANGUAGE plpgsql;

-- Система генерирует отчет по исполнению заданий каким-либо сотрудником
-- в течение периода времени, указываемого в параметре отчета.
CREATE OR REPLACE FUNCTION generate_report
    (start_timestamp timestamp , end_timestamp timestamp , employee_passport bigint) RETURNS TABLE
        (report_id uuid,
            employee_id bigint,
            total_number_employee_tasks_in_period bigint,
            number_employee_tasks_completed_on_time bigint,
            number_employee_tasks_not_completed_on_time bigint,
            number_employee_tasks_unfinished bigint,
            number_employee_tasks_unfinished_that_not_expired bigint,
            start_period timestamp,
            end_period timestamp,
            create_date timestamp) AS
$BODY$
BEGIN
    RETURN QUERY (SELECT gen_random_uuid(),
                        "employee_passport",
                        total_number_employee_tasks_in_period(start_timestamp, end_timestamp, employee_passport),
                        number_employee_tasks_completed_on_time(start_timestamp, end_timestamp, employee_passport),
                        number_employee_tasks_not_completed_on_time(start_timestamp, end_timestamp, employee_passport),
                        number_employee_tasks_unfinished(start_timestamp, end_timestamp, employee_passport),
                        number_employee_tasks_unfinished_that_not_expired(start_timestamp, end_timestamp, employee_passport),
                        "start_timestamp",
                        "end_timestamp",
                        localtimestamp);

END;
$BODY$
LANGUAGE plpgsql;


INSERT INTO company.report
SELECT * FROM generate_report('2022-07-01 04:05:06'::timestamp , '2022-11-01 04:05:06'::timestamp , 1111111111);

INSERT INTO company.report
SELECT * FROM generate_report('2022-07-01 04:05:06'::timestamp , '2022-11-01 04:05:06'::timestamp , 3333333333);

