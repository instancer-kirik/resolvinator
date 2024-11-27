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

    # Grant necessary permissions to FDW user
    execute """
    GRANT USAGE ON SCHEMA public TO resolvinator_fdw_user;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO resolvinator_fdw_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO resolvinator_fdw_user;
    """

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
    execute """
    DO $$
    BEGIN
      IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'resolvinator_fdw_user') THEN
        REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM resolvinator_fdw_user;
        REVOKE USAGE ON SCHEMA public FROM resolvinator_fdw_user;
        DROP ROLE IF EXISTS resolvinator_fdw_user;
      END IF;
    END
    $$;
    """
  end
end
