defmodule Resolvinator.Repo.Migrations.SetupFdwUserForTimetracker do
  use Ecto.Migration

  def up do
    # Create FDW user role if it doesn't exist
    execute """
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'resolvinator_fdw_user') THEN
        CREATE ROLE resolvinator_fdw_user WITH LOGIN PASSWORD '#{System.get_env("APP_FDW_RESOLVINATOR_PASSWORD") || "secure_fdw_password_123"}';
      END IF;
    END
    $$;
    """

    # Grant necessary permissions to FDW user - one at a time
    execute "GRANT USAGE ON SCHEMA public TO resolvinator_fdw_user;"
    execute "GRANT SELECT ON ALL TABLES IN SCHEMA public TO resolvinator_fdw_user;"
    execute "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO resolvinator_fdw_user;"

    # Ensure permissions are applied to existing tables
    execute """
    DO $$
    DECLARE
      r RECORD;
    BEGIN
      FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
      LOOP
        EXECUTE 'GRANT SELECT ON ' || quote_ident(r.tablename) || ' TO resolvinator_fdw_user';
      END LOOP;
    END
    $$;
    """
  end

  def down do
    # Revoke permissions from FDW user - one at a time
    execute "REVOKE USAGE ON SCHEMA public FROM resolvinator_fdw_user;"
    execute "REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM resolvinator_fdw_user;"
    execute "ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT ON TABLES FROM resolvinator_fdw_user;"

    # Drop the FDW user role
    execute """
    DO $$
    BEGIN
      IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'resolvinator_fdw_user') THEN
        DROP ROLE resolvinator_fdw_user;
      END IF;
    END
    $$;
    """
  end
end
