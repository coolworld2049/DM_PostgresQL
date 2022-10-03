CREATE ROLE admin SUPERUSER LOGIN PASSWORD 'admin' VALID UNTIL 'infinity';
SET ROLE admin;
CREATE DATABASE client_management OWNER admin;
ALTER DATABASE client_management SET timezone TO 'Europe/Moscow';
ALTER DATABASE client_management OWNER TO admin;



