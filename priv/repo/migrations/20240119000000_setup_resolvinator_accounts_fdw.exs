defmodule Resolvinator.Repo.Migrations.SetupResolvinatorAccountsFdw do
  use Ecto.Migration

  def up do
    # Create the postgres_fdw extension if it doesn't exist
    execute "CREATE EXTENSION IF NOT EXISTS postgres_fdw;"

    # Create the foreign server pointing to the acts database
    execute """
    CREATE SERVER IF NOT EXISTS acts_server
      FOREIGN DATA WRAPPER postgres_fdw
      OPTIONS (
        host '#{Application.get_env(:acts, Acts.Repo)[:hostname]}',
        port '#{Application.get_env(:acts, Acts.Repo)[:port] || 5432}',
        dbname '#{Application.get_env(:acts, Acts.Repo)[:database]}'
      );
    """

    # Create the user mapping
    execute """
    CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER
      SERVER acts_server
      OPTIONS (
        user '#{Application.get_env(:acts, Acts.Repo)[:username]}',
        password '#{Application.get_env(:acts, Acts.Repo)[:password]}'
      );
    """

    # Create schema for foreign tables
    execute "CREATE SCHEMA IF NOT EXISTS acts_fdw;"

    # Import the users table from acts database
    execute """
    IMPORT FOREIGN SCHEMA public
      LIMIT TO (users)
      FROM SERVER acts_server
      INTO acts_fdw;
    """
  end

  def down do
    execute "DROP SCHEMA IF EXISTS acts_fdw CASCADE;"
    execute "DROP USER MAPPING IF EXISTS FOR CURRENT_USER SERVER acts_server;"
    execute "DROP SERVER IF EXISTS acts_server CASCADE;"
    execute "DROP EXTENSION IF EXISTS postgres_fdw CASCADE;"
  end
end
