#!/bin/bash

# Define variables
VOLUME_NAME="cashkontrolleur-docker-client_postgres-data"
BACKUP_PATH="$(pwd)/postgres_backup"
BACKUP_FILE="$1"  # Expects the name of the backup file as the first parameter

# Check if the parameter was provided
if [ -z "$BACKUP_FILE" ]; then
  echo "Please provide the name of the backup file as the first parameter."
  exit 1
fi

# Stop container
docker-compose stop postgres
if [ $? -ne 0 ]; then
  echo "Error stopping the container"
  exit 1
fi

# Clear volume (Caution: deletes all existing data)
docker run --rm -v ${VOLUME_NAME}:/volume alpine sh -c "rm -rf /volume/*"
if [ $? -ne 0 ]; then
  echo "Error clearing the volume"
  exit 1
fi

# Restore backup
docker run --rm -v ${VOLUME_NAME}:/volume -v ${BACKUP_PATH}:/backup alpine sh -c "cd /volume && tar xzf /backup/${BACKUP_FILE}"
if [ $? -ne 0 ]; then
  echo "Error restoring the backup"
  exit 1
fi

# Start container again
docker-compose start postgres
if [ $? -ne 0 ]; then
  echo "Error starting the container"
  exit 1
fi

echo "Restoration completed: ${BACKUP_PATH}/${BACKUP_FILE}"
