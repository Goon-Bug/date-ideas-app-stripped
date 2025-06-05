#!/bin/bash

echo "****************************************"
echo " Setting up Environment"
echo "****************************************"

# Update package lists and install Python 3.12 and virtual environment package
echo "Installing Python 3.12 and Virtual Environment"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3.12 python3.12-venv

# Check the Python version
echo "Checking the Python version..."
python3.12 --version

# Create a Python virtual environment
echo "Creating a Python virtual environment"
python3.12 -m venv venv

# Activate the virtual environment and install dependencies
echo "Configuring the developer environment..."
source venv/bin/activate
pip install --upgrade pip wheel
pip install -r requirements.txt

# echo "Initializing postgres test database...."
# make test_db

# function wait_for_postgres() {
#     local retries=30
#     local wait_time=5
#     echo "Waiting for PostgreSQL to become available..."

#     until docker exec test_users_db_container pg_isready -U testuser -d test_db > /dev/null 2>&1; do
#         if [ $retries -le 0 ]; then
#             echo "PostgreSQL is not available. Exiting."
#             exit 1
#         fi
#         echo "PostgreSQL is not ready yet. Retrying in $wait_time seconds..."
#         sleep $wait_time
#         retries=$((retries - 1))
#     done

#     echo "PostgreSQL is available."
# }

# wait_for_postgres

# # Initialize the database
# DB_FILE='database/db.sqlite3'
# INIT_SCRIPT='database/__init__.py'

# echo "Initializing database..."
# if [ -f "$DB_FILE" ]; then
#     echo "Removing existing database file: $DB_FILE"
#     rm "$DB_FILE"
# fi

# export PYTHONPATH=$(pwd)


# python3 "$INIT_SCRIPT"

# # Check SQLite Docker container (if applicable)
# echo "Checking the SQLite Docker container..."
# # Add any specific commands to check if the database container is running, if necessary

# echo "****************************************"
# echo " Date Ideas Environment Setup Complete"
# echo "****************************************"
# echo ""
# echo "Use 'exit' to close this terminal and open a new one to initialize the environment"
# echo ""
