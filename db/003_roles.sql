-- db/003_roles.sql
-- A user that can read and nothing else.
-- LLM-generated SQL runs as this user.

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'gda_ro'
    ) THEN
        -- No password here: db/003_roles_password.sh sets it from the
        -- environment, so none is committed. Run by hand, set one with
        -- ALTER ROLE gda_ro PASSWORD '...' before connecting as it.
        CREATE ROLE gda_ro
            LOGIN;
    END IF;
END
$$;

GRANT CONNECT
    ON DATABASE gda
    TO gda_ro;

GRANT USAGE
    ON SCHEMA public
    TO gda_ro;

GRANT SELECT
    ON ALL TABLES
    IN SCHEMA public
    TO gda_ro;

-- And for tables created later
ALTER DEFAULT PRIVILEGES
    IN SCHEMA public
    GRANT SELECT
    ON TABLES
    TO gda_ro;

-- Belt and braces: no writes, ever
REVOKE INSERT, UPDATE, DELETE, TRUNCATE
    ON ALL TABLES
    IN SCHEMA public
    FROM gda_ro;