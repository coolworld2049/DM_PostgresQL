SET ROLE admin;
SET SCHEMA 'company';

-- общее количество заданий для данного сотрудника в указанный период
CREATE OR REPLACE FUNCTION total_number_employee_tasks_in_period(employee_passport bigint) RETURNS bigint AS
$BODY$
BEGIN
    RETURN employee_passport and (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport);
END
$BODY$
LANGUAGE plpgsql;

-- сколько заданий завершено вовремя
CREATE OR REPLACE FUNCTION number_employee_tasks_completed_on_time(employee_passport bigint) RETURNS bigint AS
$BODY$
BEGIN
    RETURN employee_passport and (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                            and deadline_date::timestamp >= completion_date::timestamp);
END
$BODY$
LANGUAGE plpgsql;

-- сколько заданий завершено с нарушением срока исполнения
CREATE OR REPLACE FUNCTION number_employee_tasks_completed_on_time(employee_passport bigint) RETURNS bigint AS
$BODY$
BEGIN
    RETURN employee_passport and (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                            and deadline_date::timestamp < completion_date::timestamp);
END
$BODY$
LANGUAGE plpgsql;

-- сколько заданий с истекшим сроком исполнения не завершено
CREATE OR REPLACE FUNCTION number_employee_tasks_unfinished(employee_passport bigint) RETURNS bigint AS
$BODY$
BEGIN
    RETURN employee_passport and (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                            and current_timestamp > deadline_date::timestamp
                                                            and completion_date is null);
END
$BODY$
LANGUAGE plpgsql;


-- сколько не завершенных заданий, срок исполнения которых не истек
CREATE OR REPLACE FUNCTION number_employee_tasks_unfinished_that_not_expired(employee_passport bigint) RETURNS bigint AS
$BODY$
BEGIN
    RETURN employee_passport and (SELECT count(*) FROM company.task
                                                  WHERE executor_passport = employee_passport
                                                     or author_passport = employee_passport
                                                            and current_timestamp < deadline_date::timestamp
                                                            and completion_date is null);
END
$BODY$
LANGUAGE plpgsql;