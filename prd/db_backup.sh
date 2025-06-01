#!/bin/bash

# Load environment variables from the .env file
export $(grep -v '^#' .env.be | xargs)

# Set up timestamp and backup file name
DATE=$(date +"%Y_%m_%d")
TIME=$(date +"%H_%M")
BACKUP_DIR="./backups"
BACKUP_FILE="$BACKUP_DIR/dump.sql.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Dump the PostgreSQL database to a gzip file
echo "Starting backup of database $POSTGRES_DB..."
PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -U "$POSTGRES_USER" -h "$DB_NAME" -p "$DB_PORT" "$POSTGRES_DB" | gzip >"$BACKUP_FILE"

# Check if the backup was successful
if [ -f "$BACKUP_FILE" ]; then
    echo "Database backup created successfully at $BACKUP_FILE"

    # Upload the backup file to S3
    echo "Uploading backup to S3 bucket: $AWS_STORAGE_BUCKET_NAME"
    aws s3 cp "$BACKUP_FILE" "s3://$AWS_STORAGE_BUCKET_NAME/db_snapshot/$DATE/$TIME/" --region "$AWS_S3_REGION_NAME"

    # Check if the upload was successful
    if [ $? -eq 0 ]; then
        echo "Backup uploaded to S3 successfully."
        # Optionally, remove the local backup file after successful upload
        rm -rf "$BACKUP_DIR"
    else
        echo "Failed to upload backup to S3."
    fi
else
    echo "Failed to create database backup."
fi
