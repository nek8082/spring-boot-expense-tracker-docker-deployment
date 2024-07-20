DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles 
      WHERE rolname = 'nek') THEN
      CREATE ROLE nek WITH LOGIN ENCRYPTED PASSWORD 'postgres';
   END IF;
END
$do$;

GRANT ALL PRIVILEGES ON DATABASE postgres TO nek;

DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT schema_name
      FROM information_schema.schemata
      WHERE schema_name = 'keycloak') THEN
      EXECUTE 'CREATE SCHEMA keycloak AUTHORIZATION nek';
   END IF;
END
$do$;

ALTER ROLE nek SET search_path TO keycloak,public;

GRANT ALL PRIVILEGES ON SCHEMA keycloak TO nek;
