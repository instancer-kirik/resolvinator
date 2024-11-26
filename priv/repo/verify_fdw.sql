-- Drop existing FDW objects to ensure clean setup
DROP SCHEMA IF EXISTS resolvinator_acts_fdw CASCADE;
DROP USER MAPPING IF EXISTS FOR CURRENT_USER SERVER acts_server;
DROP SERVER IF EXISTS acts_server CASCADE;
DROP EXTENSION IF EXISTS postgres_fdw CASCADE;

-- Create FDW extension
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Create foreign server
CREATE SERVER acts_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (
    host 'localhost',
    port '5432',
    dbname 'veix_acts_dev'
  );

-- Create user mapping
CREATE USER MAPPING FOR CURRENT_USER
  SERVER acts_server
  OPTIONS (
    user 'postgres',
    password 'root'
  );

-- Create schema for foreign tables
CREATE SCHEMA resolvinator_acts_fdw;

-- Import foreign schema
IMPORT FOREIGN SCHEMA public
  LIMIT TO (users)
  FROM SERVER acts_server
  INTO resolvinator_acts_fdw;

-- Verify the setup
SELECT schemaname, tablename, servername 
FROM pg_foreign_tables 
WHERE tablename = 'users';

-- Verify table structure
\d resolvinator_acts_fdw.users
