SET ROLE admin;
\connect client_management;
SET SCHEMA 'company';

--DROP FUNCTION delete_task_after_year();

CREATE OR REPLACE FUNCTION delete_task_after_year() RETURNS trigger AS
$BODY$
BEGIN
    DELETE FROM company.task
           WHERE current_timestamp >= (task.completion_date + make_interval(years := 1))
             and task.completion_date is not null ;
    RETURN NULL;
END
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER task_mgmt AFTER INSERT OR UPDATE ON company.task
    FOR EACH STATEMENT
    EXECUTE FUNCTION delete_task_after_year();