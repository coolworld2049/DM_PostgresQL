SET ROLE admin;
\connect client_management;
SET SCHEMA 'company';

--POLICES FUNCTIONS

CREATE OR REPLACE FUNCTION get_manager_passport_byCurrentUser(passp bigint) RETURNS boolean AS
$BODY$
BEGIN
    IF (SELECT 1 FROM company.employees
                            WHERE passport = passp and "role" = 'manager'::employee_role) is true THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
END
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_ranker_passport_byCurrentUser(passp bigint) RETURNS bigint AS
$BODY$
BEGIN
    IF (SELECT 1 FROM company.employees
                            WHERE passport = passp and "role" = 'ranker'::employee_role) is true THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
END
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION is_author(input_task_id bigint) RETURNS boolean AS
$BODY$
BEGIN
    IF (SELECT count(*) FROM company.task) > 0 THEN
        IF (SELECT 1 FROM company.task as ct1
                     WHERE (SELECT executor_passport
                                FROM company.task as ct2
                                    WHERE ct2.task_id = input_task_id) = ct1.author_passport) is true THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END IF;
END;
$BODY$
LANGUAGE plpgsql;

