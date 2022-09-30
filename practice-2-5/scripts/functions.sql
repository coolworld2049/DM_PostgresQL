SET SCHEMA 'company';

CREATE OR REPLACE FUNCTION get_passport_byCurrentUser() RETURNS bigint AS
$BODY$
BEGIN
    RETURN (SELECT passport FROM company.employees WHERE passport = current_user);
END
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_manager_passport_byCurrentUser() RETURNS bigint AS
$BODY$
BEGIN
    RETURN (SELECT passport FROM company.employees WHERE passport = current_user and role = 'manager');
END
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_ranker_passport_byCurrentUser() RETURNS bigint AS
$BODY$
BEGIN
    RETURN (SELECT passport FROM company.employees WHERE passport = current_user and role = 'ranker');
END
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION is_not_author(input_task_id bigint) RETURNS boolean AS
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

