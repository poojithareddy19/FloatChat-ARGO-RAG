#!/bin/sh
# db/003_roles_password.sh
# Sets the read-only role's password from GDA_RO_PASSWORD, so that no password
# is committed.
#
# It creates the role too if it does not exist yet, because it cannot rely on
# running after 003_roles.sql: the image's entrypoint orders init files by the
# container's locale, which ignores punctuation and puts this file first.
# 003_roles.sql creates the role only if it is missing and grants the
# privileges, so either order ends in the same place.
#
# Like the other init files it runs only when the volume is first created. To
# change the password on an existing database, see docs/deployment.md.

: "${GDA_RO_PASSWORD:?GDA_RO_PASSWORD is not set; see .env.example}"

# Passed as a psql variable and quoted by psql (:'ro_pw'), so the value is
# never spliced into the SQL text by the shell.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
    -v ro_pw="$GDA_RO_PASSWORD" <<'SQL'
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'gda_ro'
    ) THEN
        CREATE ROLE gda_ro
            LOGIN;
    END IF;
END
$$;

ALTER ROLE gda_ro PASSWORD :'ro_pw';
SQL
