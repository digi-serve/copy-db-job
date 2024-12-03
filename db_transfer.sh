#!/bin/bash

# Variables
DUMP_FILE="${SOURCE_DB}_backup.sql" # Temporary dump file location

# Step 1: Export database from Docker instance
echo "Exporting database from Docker container..."
mysqldump -h $LOCAL_DB_HOST -P $SOURCE_PORT -u$SOURCE_USER -p$SOURCE_PASSWORD $SOURCE_DB > $DUMP_FILE

if [ $? -ne 0 ]; then
    echo "Error: Database export failed."
    exit 1
fi

# Step 2: Drop the target database if it exists and create a new one
echo "Checking if target database exists..."
DB_EXISTS=$(mysql -u$TARGET_USER -p$TARGET_PASSWORD -h $LOCAL_DB_HOST -P $TARGET_PORT -e "SHOW DATABASES LIKE '$TARGET_DB';" | grep "$TARGET_DB")

if [ -n "$DB_EXISTS" ]; then
    echo "Target database exists. Dropping database: $TARGET_DB"
    mysql -u$TARGET_USER -p$TARGET_PASSWORD -h $LOCAL_DB_HOST -P $TARGET_PORT -e "DROP DATABASE \`$TARGET_DB\`;"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to drop the target database."
        exit 1
    fi
fi

echo "Creating new database: $TARGET_DB"
mysql -u$TARGET_USER -p$TARGET_PASSWORD -h $LOCAL_DB_HOST -P $TARGET_PORT -e "CREATE DATABASE \`$TARGET_DB\`;"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create target database."
    exit 1
fi

# Step 3: Import database into the target MySQL instance
echo "Importing database into the target MySQL instance..."
mysql -u$TARGET_USER -p$TARGET_PASSWORD -h $LOCAL_DB_HOST -P $TARGET_PORT $TARGET_DB < $DUMP_FILE

if [ $? -ne 0 ]; then
    echo "Error: Database import failed."
    exit 1
fi

# Step 4: Clean up
echo "Cleaning up temporary files..."
rm -f $DUMP_FILE

echo "Database transfer completed successfully."
