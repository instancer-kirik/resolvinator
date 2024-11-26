#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Checking PostgreSQL connection..."

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo -e "${RED}PostgreSQL client (psql) is not installed${NC}"
    exit 1
fi

# Database connection parameters
DB_NAME="veix_resolvinator_dev"
FDW_DB_NAME="veix_acts_dev"
DB_USER="postgres"
DB_PASSWORD="root"
DB_HOST="localhost"
DB_PORT="5432"

# Check if the acts database exists
echo "Checking if acts database exists..."
if ! psql -h $DB_HOST -p $DB_PORT -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $FDW_DB_NAME; then
    echo -e "${RED}Acts database '$FDW_DB_NAME' does not exist${NC}"
    echo "Creating acts database..."
    createdb -h $DB_HOST -p $DB_PORT -U $DB_USER $FDW_DB_NAME
fi

# Check if the resolvinator database exists
echo "Checking if resolvinator database exists..."
if ! psql -h $DB_HOST -p $DB_PORT -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo -e "${RED}Resolvinator database '$DB_NAME' does not exist${NC}"
    echo "Creating resolvinator database..."
    createdb -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME
fi

# Run the FDW setup script
echo "Setting up Foreign Data Wrapper..."
export PGPASSWORD=$DB_PASSWORD
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f verify_fdw.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}FDW setup completed successfully${NC}"
else
    echo -e "${RED}FDW setup failed${NC}"
    exit 1
fi

# Verify the FDW setup
echo "Verifying FDW setup..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\d resolvinator_acts_fdw.users"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}FDW verification completed successfully${NC}"
else
    echo -e "${RED}FDW verification failed${NC}"
    exit 1
fi
