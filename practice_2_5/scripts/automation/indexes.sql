SET ROLE admin;
SET SCHEMA 'company';

CREATE INDEX organization_address_index ON company.organization USING btree (address);
CREATE INDEX organization_org_name_index ON company.organization USING btree (org_name);
CREATE INDEX client_name_index ON company.clients USING btree ("name");
