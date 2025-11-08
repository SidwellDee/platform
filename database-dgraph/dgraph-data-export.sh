#!/bin/bash

#==========================================================================
# EXPORT DGRAPH ALPHA DATA
#==========================================================================
LOG_DIR="/home/$USER/eswatini_hie/backups/dgraph_export_logs"
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/dgraph_export_$TIMESTAMP.log"
CONTAINER_EXPORT_DIR="/dgraph/exports/$TIMESTAMP"

# Function to log messages with timestamp
log_message() {
  local MESSAGE="$1"
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $MESSAGE" >> "$LOG_FILE"
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $MESSAGE"
}

# Create log directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
  log_message "Log directory does not exist. Creating directory: $LOG_DIR"
  mkdir -p "$LOG_DIR"
  log_message "Log directory created successfully."
else
  log_message "Log directory already exists: $LOG_DIR"
fi

# Start logging
log_message "Starting Dgraph export process."

# Send the export request
log_message "Sending export request to Dgraph Alpha..."
EXPORT_RESPONSE=$(curl -s -X POST http://localhost:8070/admin \
  -H "Content-Type: application/json" \
  -d "{\"query\":\"mutation { export(input: {format: \\\"rdf\\\",destination: \\\"$CONTAINER_EXPORT_DIR\\\"}) { response { message code } } }\"}")

# Check if the request was successful
if [[ $? -eq 0 ]]; then
  log_message "Export request sent successfully."
else
  log_message "Error: Failed to send export request."
  exit 1
fi

# Log the response from Dgraph Alpha
log_message "Dgraph Alpha response: $EXPORT_RESPONSE"

# Log completion
log_message "Dgraph export process completed."

# End logging
log_message "Dgraph export process finished."
