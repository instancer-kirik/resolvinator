defmodule Resolvinator.Repo.Migrations.SetupResolvinatorAccountsFdw do
  use Ecto.Migration

  def up do
    # Create the postgres_fdw extension if it doesn't exist
    execute "CREATE EXTENSION IF NOT EXISTS postgres_fdw;"

    # Create the foreign server pointing to the accounts database
    execute """
    CREATE SERVER IF NOT EXISTS accounts_server
      FOREIGN DATA WRAPPER postgres_fdw
      OPTIONS (
        host '#{Application.get_env(:accounts, Accounts.Repo)[:hostname]}',
        port '#{Application.get_env(:accounts, Accounts.Repo)[:port]}',
        dbname '#{Application.get_env(:accounts, Accounts.Repo)[:database]}'
      );
    """

    # Create the user mapping
    execute """
    CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER
      SERVER accounts_server
      OPTIONS (
        user '#{Application.get_env(:accounts, Accounts.Repo)[:username]}',
        password '#{Application.get_env(:accounts, Accounts.Repo)[:password]}'
      );
    """

    # Create schema for foreign tables
    execute "CREATE SCHEMA IF NOT EXISTS resolvinator_accounts_fdw;"

    # Import the users table from accounts database
    execute """
    IMPORT FOREIGN SCHEMA public
      LIMIT TO (users)
      FROM SERVER accounts_server
      INTO resolvinator_accounts_fdw;
    """
  end

  def down do
    execute "DROP SCHEMA IF EXISTS resolvinator_accounts_fdw CASCADE;"
    execute "DROP USER MAPPING IF EXISTS FOR CURRENT_USER SERVER accounts_server;"
    execute "DROP SERVER IF EXISTS accounts_server CASCADE;"
    execute "DROP EXTENSION IF EXISTS postgres_fdw CASCADE;"
  end
end
