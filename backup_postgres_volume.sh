#!/bin/bash

# Define variables
# Docker derives volume name by default from the directory name
VOLUME_NAME="cashkontrolleur-docker-client_postgres-data"
BACKUP_PATH="$(pwd)/postgres_backup"
BACKUP_FILE="postgres_backup_$(date +%Y%m%d%H%M%S).tar.gz"

# Debugging outputs
echo "Backup directory: ${BACKUP_PATH}"
echo "Backup file: ${BACKUP_FILE}"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_PATH}"
if [ $? -ne 0 ]; then
  echo "Error creating backup directory"
  exit 1
fi

# Check if directory exists
if [ ! -d "${BACKUP_PATH}" ]; then
  echo "Backup directory was not created"
  exit 1
fi

# Stop container
docker-compose stop postgres
if [ $? -ne 0 ]; then
  echo "Error stopping container"
  exit 1
fi

# Create backup
docker run --rm -v ${VOLUME_NAME}:/volume -v "${BACKUP_PATH}:/backup" alpine sh -c "cd /volume && tar czf /backup/${BACKUP_FILE} ."
if [ $? -ne 0 ]; then
  echo "Error creating backup"
  exit 1
fi

# Check if backup was created
if [ ! -f "${BACKUP_PATH}/${BACKUP_FILE}" ]; then
  echo "Backup file was not created"
  exit 1
fi

# Start container again
docker-compose start postgres
if [ $? -ne 0 ]; then
  echo "Error starting container"
  exit 1
fi

echo "Backup created: ${BACKUP_PATH}/${BACKUP_FILE}"
